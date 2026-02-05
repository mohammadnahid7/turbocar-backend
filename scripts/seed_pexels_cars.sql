-- =====================================================
-- Populate Database with 100 Pexels Car Listings
-- Usage: cat scripts/seed_pexels_cars.sql | docker exec -i car-reselling-postgres psql -U postgres -d car_reselling_db
-- =====================================================

-- 1. Clear existing cars and related data
TRUNCATE TABLE cars CASCADE;

-- 2. Ensure Dummy User Exists
INSERT INTO users (id, email, phone, password_hash, full_name, is_verified, is_active)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'premium_autos@example.com',
    '+15550001111',
    '$2a$10$dummyhashfordev',
    'Premium Auto Sales',
    TRUE,
    TRUE
)
ON CONFLICT (id) DO NOTHING;

-- 3. Generate 100 Cars using PL/pgSQL
DO $$
DECLARE
    dummy_user_id UUID := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
    
    -- Data Arrays
    makes TEXT[] := ARRAY['Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes', 'Audi', 'Tesla', 'Chevrolet', 'Nissan', 'Hyundai'];
    models TEXT[] := ARRAY['Camry', 'Civic', 'F-150', '3 Series', 'C-Class', 'A4', 'Model 3', 'Silverado', 'Altima', 'Elantra'];
    colors TEXT[] := ARRAY['Black', 'White', 'Silver', 'Red', 'Blue', 'Gray', 'Green'];
    fuel_types text[] := ARRAY['petrol', 'hybrid', 'electric', 'diesel'];
    
    -- Image Pool
    image_pool TEXT[] := ARRAY[
        'https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg',
        'https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg',
        'https://images.pexels.com/photos/18382225/pexels-photo-18382225.png',
        'https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg',
        'https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg',
        'https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg',
        'https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg',
        'https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg',
        'https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg',
        'https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg',
        'https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg',
        'https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg',
        'https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg',
        'https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg',
        'https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg',
        'https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg',
        'https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg',
        'https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg',
        'https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg'
    ];

    i INT;
    make_idx INT;
    model_idx INT;
    img_start_idx INT;
    current_images TEXT[];
    
BEGIN
    FOR i IN 1..100 LOOP
        -- Generate random indices
        make_idx := 1 + floor(random() * array_length(makes, 1))::int;
        model_idx := 1 + floor(random() * array_length(models, 1))::int;
        
        -- Create a rotated slice of images
        
        INSERT INTO cars (
            id, seller_id, title, description, make, model, year, mileage, price, 
            condition, transmission, fuel_type, color, vin, images, 
            city, state, coordinates, status, is_featured, views_count, expires_at, created_at, updated_at
        )
        VALUES (
            uuid_generate_v4(),
            dummy_user_id,
            makes[make_idx] || ' ' || models[model_idx] || ' #' || i,
            'This is a generated listing for car #' || i || '. Features premium interior and low mileage.',
            makes[make_idx],
            models[model_idx],
            2015 + floor(random() * 10)::int, -- 2015-2024
            floor(random() * 100000)::int,
            (10000 + floor(random() * 90000))::numeric(10,2),
            'excellent',
            'automatic',
            fuel_types[1 + floor(random() * array_length(fuel_types, 1))::int]::car_fuel_type,
            colors[1 + floor(random() * array_length(colors, 1))::int],
            'VIN' || i || floor(random() * 1000000)::text,
            -- Take 8 images from pool. We simply rotate the array.
            ARRAY[
                image_pool[1 + (i % 19)],
                image_pool[1 + ((i+1) % 19)],
                image_pool[1 + ((i+2) % 19)],
                image_pool[1 + ((i+3) % 19)],
                image_pool[1 + ((i+4) % 19)],
                image_pool[1 + ((i+5) % 19)],
                image_pool[1 + ((i+6) % 19)],
                image_pool[1 + ((i+7) % 19)]
            ],
            'City ' || i,
            'State',
            ST_SetSRID(ST_MakePoint(-90 + random()*40, 30 + random()*20), 4326),
            'active',
            (random() > 0.9), -- 10% featured
            floor(random() * 500)::int,
            NOW() + INTERVAL '90 days',
            NOW() - ((100 - i) * INTERVAL '1 minute'),
            NOW() - ((100 - i) * INTERVAL '1 minute')
        );
    END LOOP;
END $$;
