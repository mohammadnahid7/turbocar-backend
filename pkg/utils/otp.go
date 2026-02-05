package utils

import (
	"crypto/rand"
	"fmt"
	"math/big"

	"github.com/twilio/twilio-go"
	twilioApi "github.com/twilio/twilio-go/rest/api/v2010"
)

// GenerateOTP generates a random 6-digit OTP code
func GenerateOTP() string {
	code := ""
	for i := 0; i < 6; i++ {
		num, _ := rand.Int(rand.Reader, big.NewInt(10))
		code += fmt.Sprintf("%d", num.Int64())
	}
	return code
}

// SendOTP sends an OTP code via Twilio SMS
func SendOTP(phone, code, accountSID, authToken, twilioPhoneNumber string) error {
	client := twilio.NewRestClientWithParams(twilio.ClientParams{
		Username: accountSID,
		Password: authToken,
	})

	params := &twilioApi.CreateMessageParams{}
	params.SetTo(phone)
	params.SetFrom(twilioPhoneNumber)
	params.SetBody(fmt.Sprintf("Your verification code is: %s. Valid for 10 minutes.", code))

	_, err := client.Api.CreateMessage(params)
	if err != nil {
		return fmt.Errorf("failed to send OTP: %w", err)
	}

	return nil
}

