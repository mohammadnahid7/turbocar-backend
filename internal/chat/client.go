package chat

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

const (
	// Time allowed to write a message to the peer
	writeWait = 10 * time.Second

	// Time allowed to read the next pong message from the peer
	pongWait = 60 * time.Second

	// Send pings to peer with this period (must be less than pongWait)
	pingPeriod = (pongWait * 9) / 10

	// Maximum message size allowed from peer
	maxMessageSize = 8192
)

// Client represents a single WebSocket connection
type Client struct {
	UserID uuid.UUID
	hub    *Hub
	conn   *websocket.Conn
	send   chan *WSMessage
}

// NewClient creates a new client instance
func NewClient(hub *Hub, conn *websocket.Conn, userID uuid.UUID) *Client {
	return &Client{
		UserID: userID,
		hub:    hub,
		conn:   conn,
		send:   make(chan *WSMessage, 256),
	}
}

// ReadPump pumps messages from the WebSocket connection to the hub
func (c *Client) ReadPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket error: %v", err)
			}
			break
		}

		var wsMsg WSMessage
		if err := json.Unmarshal(message, &wsMsg); err != nil {
			log.Printf("Invalid message format: %v", err)
			continue
		}

		// Set sender and timestamp
		wsMsg.SenderID = c.UserID
		wsMsg.Timestamp = time.Now()

		// Handle different message types
		switch wsMsg.Type {
		case "message":
			// Persist the message to database
			if err := c.hub.service.SaveMessage(&wsMsg); err != nil {
				log.Printf("Failed to save message: %v", err)
				continue
			}
			// Broadcast to recipients
			c.hub.broadcast <- &wsMsg

		case "typing":
			// Typing indicators are ephemeral, just broadcast
			c.hub.broadcast <- &wsMsg

		case "read_receipt":
			// Update read status in DB
			if err := c.hub.service.MarkAsRead(c.UserID, wsMsg.ConversationID, wsMsg.Content); err != nil {
				log.Printf("Failed to mark as read: %v", err)
			}
			c.hub.broadcast <- &wsMsg

		case "message:delivered":
			// Client confirms message was delivered
			// wsMsg.Content contains the message ID
			messageID, err := uuid.Parse(wsMsg.Content)
			if err != nil {
				log.Printf("Invalid message ID for delivery: %v", err)
				continue
			}
			if err := c.hub.service.MarkMessageDelivered(messageID); err != nil {
				log.Printf("Failed to mark message as delivered: %v", err)
				continue
			}
			// Notify sender about delivery status
			c.hub.broadcast <- &wsMsg

		case "messages:seen":
			// Client marks all messages in conversation as seen
			affected, err := c.hub.service.MarkConversationSeen(wsMsg.ConversationID, c.UserID)
			if err != nil {
				log.Printf("Failed to mark messages as seen: %v", err)
				continue
			}
			if affected > 0 {
				// Notify sender that messages were seen
				wsMsg.Content = c.UserID.String() // Include who saw the messages
				c.hub.broadcast <- &wsMsg
			}
			// Send unread update to this user
			c.sendUnreadUpdate()

		case "unread:get":
			// Client requests total unread count
			c.sendUnreadUpdate()
		}
	}
}

// sendUnreadUpdate sends the user's total unread count
func (c *Client) sendUnreadUpdate() {
	total, err := c.hub.service.GetTotalUnreadCount(c.UserID)
	if err != nil {
		log.Printf("Failed to get total unread count: %v", err)
		return
	}
	unreadMsg := &WSMessage{
		Type:      "unread:update",
		Content:   fmt.Sprintf("%d", total),
		Timestamp: time.Now(),
	}
	c.send <- unreadMsg
}

// WritePump pumps messages from the hub to the WebSocket connection
func (c *Client) WritePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				// Hub closed the channel
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}

			data, err := json.Marshal(message)
			if err != nil {
				log.Printf("Failed to marshal message: %v", err)
				continue
			}
			w.Write(data)

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
