package auth

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/yourusername/car-reselling-backend/internal/config"
	"github.com/yourusername/car-reselling-backend/internal/database"
	appErrors "github.com/yourusername/car-reselling-backend/pkg/errors"
	"github.com/yourusername/car-reselling-backend/pkg/utils"
)

// OptionalAuthMiddleware attempts to validate JWT tokens and set user context,
// but allows the request to proceed even without a valid token.
// This is useful for public endpoints that need to know if a user is logged in.
func OptionalAuthMiddleware(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		var token string

		// First, try Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader != "" {
			// Extract token from "Bearer <token>"
			parts := strings.Split(authHeader, " ")
			if len(parts) == 2 && parts[0] == "Bearer" {
				token = parts[1]
			}
		}

		// If no header token, try query parameter (for WebSocket connections)
		if token == "" {
			token = c.Query("token")
		}

		// If no token, just continue without setting user context
		if token == "" {
			c.Next()
			return
		}

		// Validate token (if present)
		claims, err := utils.ValidateToken(token, cfg.JWTSecret)
		if err != nil {
			// Invalid token, but still allow request to proceed (as unauthenticated)
			c.Next()
			return
		}

		// Set user ID in context
		c.Set("userID", claims.UserID)
		c.Set("email", claims.Email)

		c.Next()
	}
}

// AuthMiddleware validates JWT tokens and sets user context
func AuthMiddleware(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		var token string

		// First, try Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader != "" {
			// Extract token from "Bearer <token>"
			parts := strings.Split(authHeader, " ")
			if len(parts) == 2 && parts[0] == "Bearer" {
				token = parts[1]
			}
		}

		// If no header token, try query parameter (for WebSocket connections)
		if token == "" {
			token = c.Query("token")
		}

		// If still no token, unauthorized
		if token == "" {
			appErrors.HandleError(c, appErrors.ErrUnauthorized)
			c.Abort()
			return
		}

		// Validate token
		claims, err := utils.ValidateToken(token, cfg.JWTSecret)
		if err != nil {
			appErrors.HandleError(c, appErrors.ErrInvalidToken)
			c.Abort()
			return
		}

		// Set user ID in context
		c.Set("userID", claims.UserID)
		c.Set("email", claims.Email)

		c.Next()
	}
}

// RateLimitMiddleware implements rate limiting using Redis
func RateLimitMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get client IP
		clientIP := c.ClientIP()

		// Rate limit key
		rateLimitKey := "rate_limit:" + clientIP

		// Check current count
		ctx := c.Request.Context()
		count, err := database.Get(ctx, rateLimitKey)
		if err != nil {
			// First request, set count to 1
			database.Set(ctx, rateLimitKey, "1", time.Minute)
			c.Next()
			return
		}

		var requestCount int
		fmt.Sscanf(count, "%d", &requestCount)

		// Limit: 100 requests per minute (increased for testing)
		if requestCount >= 100 {
			appErrors.HandleErrorWithMessage(c, http.StatusTooManyRequests, "Too many requests. Please try again later.")
			c.Abort()
			return
		}

		// Increment count
		database.Increment(ctx, rateLimitKey)
		c.Next()
	}
}
