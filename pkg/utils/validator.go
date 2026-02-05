package utils

import (
	"errors"
	"regexp"
	"strings"
	"unicode"
)

var (
	ErrInvalidEmail    = errors.New("invalid email format")
	ErrInvalidPhone    = errors.New("invalid phone format (must be E.164 format, e.g., +1234567890)")
	ErrInvalidPassword = errors.New("password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, and one number")
)

var (
	emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	phoneRegex = regexp.MustCompile(`^\+[1-9]\d{1,14}$`) // E.164 format
)

// ValidateEmail validates an email address format
func ValidateEmail(email string) bool {
	if len(email) == 0 || len(email) > 255 {
		return false
	}
	return emailRegex.MatchString(email)
}

// ValidatePhone validates a phone number in E.164 format
func ValidatePhone(phone string) bool {
	return phoneRegex.MatchString(phone)
}

// ValidatePassword validates password strength
// Requirements: min 8 chars, 1 uppercase, 1 lowercase, 1 number
func ValidatePassword(password string) error {
	if len(password) < 8 {
		return ErrInvalidPassword
	}

	var (
		hasUpper   = false
		hasLower   = false
		hasNumber  = false
	)

	for _, char := range password {
		switch {
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsNumber(char):
			hasNumber = true
		}
	}

	if !hasUpper || !hasLower || !hasNumber {
		return ErrInvalidPassword
	}

	return nil
}

// SanitizeString removes leading/trailing whitespace
func SanitizeString(s string) string {
	return strings.TrimSpace(s)
}

