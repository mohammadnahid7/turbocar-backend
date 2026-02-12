package notification

import (
	"context"
	"fmt"
	"log"
	"time"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/google/uuid"
	"github.com/yourusername/car-reselling-backend/internal/config"
	"google.golang.org/api/option"
	"gorm.io/gorm"
)

// WebSocketBroadcaster interface for sending real-time notifications via WebSocket
type WebSocketBroadcaster interface {
	SendNotification(userID uuid.UUID, notificationID string, notificationType string, title string, body string, data map[string]interface{}, createdAt time.Time) error
}

// Service handles push notifications via Firebase Cloud Messaging
type Service struct {
	client        *messaging.Client
	db            *gorm.DB
	wsBroadcaster WebSocketBroadcaster
}

// NewService creates a new notification service
func NewService(cfg *config.Config) (*Service, error) {
	ctx := context.Background()

	// Check if Firebase credentials are configured
	if cfg.FirebaseCredentialsJSON == "" && cfg.FirebaseCredentialsPath == "" {
		return nil, fmt.Errorf("Firebase credentials not configured (set FIREBASE_CREDENTIALS_JSON or FIREBASE_CREDENTIALS_PATH)")
	}

	var app *firebase.App
	var err error

	if cfg.FirebaseCredentialsJSON != "" {
		// Use JSON string from environment variable
		opt := option.WithCredentialsJSON([]byte(cfg.FirebaseCredentialsJSON))
		app, err = firebase.NewApp(ctx, nil, opt)
	} else {
		// Use file path
		opt := option.WithCredentialsFile(cfg.FirebaseCredentialsPath)
		app, err = firebase.NewApp(ctx, nil, opt)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to initialize Firebase app: %w", err)
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get Firebase messaging client: %w", err)
	}

	log.Println("✓ Firebase Cloud Messaging initialized successfully")
	return &Service{client: client}, nil
}

// Notification model (matches DB schema)
type Notification struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	UserID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	Type      string         `gorm:"type:varchar(50);not null" json:"type"`
	Title     string         `gorm:"type:varchar(255);not null" json:"title"`
	Body      string         `gorm:"type:text;not null" json:"body"`
	Data      map[string]any `gorm:"type:jsonb;serializer:json" json:"data"`
	IsRead    bool           `gorm:"default:false;index" json:"is_read"`
	CreatedAt time.Time      `gorm:"default:now();index" json:"created_at"`
}

// SetDB sets the database connection
func (s *Service) SetDB(db *gorm.DB) {
	s.db = db
}

// SetWebSocketBroadcaster sets the WebSocket broadcaster for real-time notifications
func (s *Service) SetWebSocketBroadcaster(broadcaster WebSocketBroadcaster) {
	s.wsBroadcaster = broadcaster
}

// Create saves a notification to the database
func (s *Service) Create(ctx context.Context, n *Notification) error {
	if s.db == nil {
		return fmt.Errorf("database connection not set")
	}
	return s.db.WithContext(ctx).Create(n).Error
}

// List returns a paginated list of notifications for a user
func (s *Service) List(ctx context.Context, userID uuid.UUID, page, limit int) ([]Notification, int64, error) {
	if s.db == nil {
		return nil, 0, fmt.Errorf("database connection not set")
	}

	var notifications []Notification
	var total int64
	offset := (page - 1) * limit

	// Count total
	if err := s.db.WithContext(ctx).Model(&Notification{}).Where("user_id = ?", userID).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Fetch page
	err := s.db.WithContext(ctx).
		Where("user_id = ?", userID).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&notifications).Error

	return notifications, total, err
}

// GetUnreadCount returns the number of unread notifications for a user
func (s *Service) GetUnreadCount(ctx context.Context, userID uuid.UUID) (int64, error) {
	if s.db == nil {
		return 0, fmt.Errorf("database connection not set")
	}
	var count int64
	err := s.db.WithContext(ctx).
		Model(&Notification{}).
		Where("user_id = ? AND is_read = ?", userID, false).
		Count(&count).Error
	return count, err
}

// MarkAsRead marks a specific notification as read
func (s *Service) MarkAsRead(ctx context.Context, userID, notificationID uuid.UUID) error {
	if s.db == nil {
		return fmt.Errorf("database connection not set")
	}
	return s.db.WithContext(ctx).
		Model(&Notification{}).
		Where("id = ? AND user_id = ?", notificationID, userID).
		Update("is_read", true).Error
}

// MarkAllAsRead marks all notifications for a user as read
func (s *Service) MarkAllAsRead(ctx context.Context, userID uuid.UUID) error {
	if s.db == nil {
		return fmt.Errorf("database connection not set")
	}
	return s.db.WithContext(ctx).
		Model(&Notification{}).
		Where("user_id = ? AND is_read = ?", userID, false).
		Update("is_read", true).Error
}

// SendToUsers sends a notification to multiple users via FCM, WebSocket, and persists to DB
func (s *Service) SendToUsers(userIDs []uuid.UUID, title, body string, data map[string]string) error {
	ctx := context.Background()

	// Prepare notification data for DB
	jsonInitData := make(map[string]any)
	for k, v := range data {
		jsonInitData[k] = v
	}

	notificationType := data["type"]
	if notificationType == "" {
		notificationType = "system"
	}

	// 1. Persist notifications to database and send via WebSocket
	notifications := make([]Notification, len(userIDs))
	for i, uid := range userIDs {
		notifications[i] = Notification{
			UserID: uid,
			Type:   notificationType,
			Title:  title,
			Body:   body,
			Data:   jsonInitData,
			IsRead: false,
		}
	}

	if s.db != nil {
		if err := s.db.WithContext(ctx).Create(&notifications).Error; err != nil {
			log.Printf("Error persisting notifications: %v", err)
			// Continue to send push even if persistence fails
		}
	}

	// 2. Send via WebSocket for real-time delivery (fire and forget)
	if s.wsBroadcaster != nil {
		for i := range notifications {
			go func(n Notification) {
				// Convert map[string]any to map[string]interface{}
				data := make(map[string]interface{})
				for k, v := range n.Data {
					data[k] = v
				}
				if err := s.wsBroadcaster.SendNotification(n.UserID, n.ID.String(), n.Type, n.Title, n.Body, data, n.CreatedAt); err != nil {
					log.Printf("Failed to send WebSocket notification to user %s: %v", n.UserID, err)
				}
			}(notifications[i])
		}
	}

	// 3. Send via FCM for push notifications (background/terminated apps)
	if s.client == nil {
		log.Printf("FCM client not initialized, skipping push notifications")
		return nil
	}

	if s.db == nil {
		return fmt.Errorf("database connection not set")
	}

	// 4. Get FCM tokens for these users
	var tokens []string
	err := s.db.WithContext(ctx).Table("user_devices").
		Select("fcm_token").
		Where("user_id IN ?", userIDs).
		Pluck("fcm_token", &tokens).Error
	if err != nil {
		return fmt.Errorf("failed to get FCM tokens: %w", err)
	}

	if len(tokens) == 0 {
		log.Printf("No FCM tokens found for users: %v", userIDs)
		return nil
	}

	// 5. Send multicast message
	message := &messaging.MulticastMessage{
		Tokens: tokens,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: data,
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				ClickAction: "FLUTTER_NOTIFICATION_CLICK",
				ChannelID:   "chat_messages",
			},
		},
		APNS: &messaging.APNSConfig{
			Headers: map[string]string{
				"apns-priority": "10",
			},
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Alert: &messaging.ApsAlert{
						Title: title,
						Body:  body,
					},
					Sound: "default",
					Badge: func() *int { i := 1; return &i }(),
				},
			},
		},
	}

	response, err := s.client.SendEachForMulticast(ctx, message)
	if err != nil {
		return fmt.Errorf("failed to send multicast message: %w", err)
	}

	log.Printf("FCM: Sent %d/%d notifications successfully", response.SuccessCount, len(tokens))

	// Log failures for debugging
	if response.FailureCount > 0 {
		for i, resp := range response.Responses {
			if resp.Error != nil {
				log.Printf("FCM: Failed to send to token[%d]: %v", i, resp.Error)
			}
		}
	}

	return nil
}

// SendToToken sends a notification to a single FCM token
func (s *Service) SendToToken(token, title, body string, data map[string]string) error {
	if s.client == nil {
		return fmt.Errorf("FCM client not initialized")
	}

	message := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: data,
		Android: &messaging.AndroidConfig{
			Priority: "high",
		},
	}

	ctx := context.Background()
	_, err := s.client.Send(ctx, message)
	if err != nil {
		return fmt.Errorf("failed to send message: %w", err)
	}

	return nil
}

// CreateInternalNotification creates an internal notification without sending a push notification (but saves to DB)
func (s *Service) CreateInternalNotification(ctx context.Context, userID uuid.UUID, title, body, notifType string, data map[string]string) error {
	if s.db == nil {
		return fmt.Errorf("database connection not set")
	}

	// Convert map[string]string to map[string]any for JSONB
	jsonInitData := make(map[string]any)
	for k, v := range data {
		jsonInitData[k] = v
	}

	notification := Notification{
		UserID: userID,
		Type:   notifType,
		Title:  title,
		Body:   body,
		Data:   jsonInitData,
		IsRead: false,
	}

	return s.db.WithContext(ctx).Create(&notification).Error
}
