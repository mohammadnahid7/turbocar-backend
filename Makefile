.PHONY: build run test clean docker-build docker-up docker-down migrate

# Build the application
build:
	go build -o bin/main cmd/api/main.go

# Run the application
run:
	go run cmd/api/main.go

# Run tests
test:
	go test -v ./...

# Run tests with coverage
test-coverage:
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Clean build artifacts
clean:
	rm -rf bin/
	rm -f coverage.out

# Build Docker image
docker-build:
	docker-compose build

# Start Docker services
docker-up:
	docker-compose up -d

# Stop Docker services
docker-down:
	docker-compose down

# Development with hot reload (uses docker-compose.dev.yml)
dev-up:
	docker-compose -f docker-compose.dev.yml up --build

# Development in background
dev-up-d:
	docker-compose -f docker-compose.dev.yml up -d --build

# Stop development services
dev-down:
	docker-compose -f docker-compose.dev.yml down

# View development logs
dev-logs:
	docker-compose -f docker-compose.dev.yml logs -f api

# Restart just the API service (useful after dependency changes)
dev-restart:
	docker-compose -f docker-compose.dev.yml restart api

# Run database migrations
migrate:
	psql -U postgres -d car_reselling_db -f migrations/001_create_users_table.sql
	psql -U postgres -d car_reselling_db -f migrations/002_create_listings_tables.sql
	psql -U postgres -d car_reselling_db -f migrations/003_make_fields_optional.sql
	psql -U postgres -d car_reselling_db -f migrations/004_add_chat_only_column.sql
	psql -U postgres -d car_reselling_db -f migrations/005_create_chat_tables.sql

# Format code
fmt:
	go fmt ./...

# Lint code
lint:
	golangci-lint run

# Install dependencies
deps:
	go mod download
	go mod tidy

