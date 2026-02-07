package notification

import (
	"context"
	"fmt"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/google/uuid"
	"github.com/yourusername/car-reselling-backend/internal/config"
	"google.golang.org/api/option"
	"gorm.io/gorm"
)

// Service handles push notifications via Firebase Cloud Messaging
type Service struct {
	client *messaging.Client
	db     *gorm.DB
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

// SetDB sets the database connection for device token lookups
func (s *Service) SetDB(db *gorm.DB) {
	s.db = db
}

// SendToUsers sends a notification to multiple users by looking up their FCM tokens
func (s *Service) SendToUsers(userIDs []uuid.UUID, title, body string, data map[string]string) error {
	if s.client == nil {
		return fmt.Errorf("FCM client not initialized")
	}

	if s.db == nil {
		return fmt.Errorf("database connection not set")
	}

	// Get FCM tokens for these users
	var tokens []string
	err := s.db.Table("user_devices").
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

	// Send multicast message
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

	ctx := context.Background()
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
