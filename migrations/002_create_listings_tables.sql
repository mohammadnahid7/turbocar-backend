-- Create listings tables

-- Enable PostGIS if not already enabled (for location search)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create ENUM types
CREATE TYPE car_status AS ENUM ('active', 'sold', 'expired', 'flagged', 'deleted');
CREATE TYPE car_condition AS ENUM ('excellent', 'good', 'fair');
CREATE TYPE car_transmission AS ENUM ('automatic', 'manual');
CREATE TYPE car_fuel_type AS ENUM ('petrol', 'diesel', 'electric', 'hybrid');

-- Create cars table
CREATE TABLE IF NOT EXISTS cars (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INT NOT NULL,
    mileage INT NOT NULL CHECK (mileage >= 0),
    price DECIMAL(12, 2) NOT NULL CHECK (price > 0),
    condition car_condition,
    transmission car_transmission,
    fuel_type car_fuel_type NOT NULL,
    color VARCHAR(30),
    vin VARCHAR(17),
    images TEXT[] DEFAULT '{}',
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    coordinates GEOMETRY(POINT, 4326),
    status car_status NOT NULL DEFAULT 'active',
    is_featured BOOLEAN DEFAULT FALSE,
    views_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes
CREATE INDEX idx_cars_seller ON cars(seller_id);
CREATE INDEX idx_cars_status ON cars(status);
CREATE INDEX idx_cars_price ON cars(price);
CREATE INDEX idx_cars_created_at ON cars(created_at);
-- GIST index for location search
CREATE INDEX idx_cars_location ON cars USING GIST (coordinates);
-- Composite indexes for common filters
CREATE INDEX idx_cars_make_model ON cars(make, model);
CREATE INDEX idx_cars_year ON cars(year);

-- Create favorites table
CREATE TABLE IF NOT EXISTS favorites (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    car_id UUID NOT NULL REFERENCES cars(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, car_id)
);

-- Create car_views table for analytics (to prevent duplicate view counts from same user/ip if needed, or just log)
CREATE TABLE IF NOT EXISTS car_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    car_id UUID NOT NULL REFERENCES cars(id) ON DELETE CASCADE,
    viewer_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Nullable for guest views
    ip_address VARCHAR(45),
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_car_views_car_id ON car_views(car_id);
