package chat

import (
	"log"
	"sync"

	"github.com/google/uuid"
)

// Hub maintains the set of active clients and broadcasts messages
type Hub struct {
	// Registered clients by user ID
	clients map[uuid.UUID]*Client

	// Register requests from clients
	register chan *Client

	// Unregister requests from clients
	unregister chan *Client

	// Inbound messages from clients
	broadcast chan *WSMessage

	// Mutex for thread-safe operations
	mu sync.RWMutex

	// Chat service for persistence and notifications
	service *Service
}

// NewHub creates a new Hub instance
func NewHub(service *Service) *Hub {
	return &Hub{
		clients:    make(map[uuid.UUID]*Client),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan *WSMessage),
		service:    service,
	}
}

// Run starts the hub's main loop
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client.UserID] = client
			h.mu.Unlock()
			log.Printf("Client registered: %s", client.UserID)

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.UserID]; ok {
				delete(h.clients, client.UserID)
				close(client.send)
			}
			h.mu.Unlock()
			log.Printf("Client unregistered: %s", client.UserID)

		case message := <-h.broadcast:
			h.handleBroadcast(message)
		}
	}
}

// handleBroadcast routes a message to appropriate recipients
func (h *Hub) handleBroadcast(msg *WSMessage) {
	// Get conversation participants
	participants, err := h.service.GetParticipantIDs(msg.ConversationID)
	if err != nil {
		log.Printf("Error getting participants: %v", err)
		return
	}

	// Track who received the message in real-time
	var offlineUsers []uuid.UUID

	h.mu.RLock()
	for _, userID := range participants {
		if userID == msg.SenderID {
			continue // Don't send to sender
		}

		if client, ok := h.clients[userID]; ok {
			select {
			case client.send <- msg:
				// Message sent successfully
			default:
				// Client buffer full, consider them offline
				offlineUsers = append(offlineUsers, userID)
			}
		} else {
			// User not connected
			offlineUsers = append(offlineUsers, userID)
		}
	}
	h.mu.RUnlock()

	// Send push notifications to offline users
	if len(offlineUsers) > 0 {
		go h.service.SendPushNotifications(offlineUsers, msg)
	}
}

// IsUserOnline checks if a user is currently connected
func (h *Hub) IsUserOnline(userID uuid.UUID) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	_, ok := h.clients[userID]
	return ok
}

// GetOnlineCount returns the number of connected clients
func (h *Hub) GetOnlineCount() int {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return len(h.clients)
}
