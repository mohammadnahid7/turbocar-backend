-- =====================================================
-- Populate Database with 20 Dummy Car Listings
-- Usage: cat scripts/populate_cars.sql | docker exec -i car-reselling-postgres psql -U postgres -d car_reselling_db
-- =====================================================

-- 1. Ensure Dummy User Exists
INSERT INTO users (id, email, phone, password_hash, full_name, is_verified, is_active)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'dummy_seller@example.com',
    '+15550001111',
    'hash_placeholder',
    'Premium Auto Sales',
    TRUE,
    TRUE
)
ON CONFLICT (email) DO NOTHING;

-- 2. Insert 20 Dummy Cars
INSERT INTO cars (id, seller_id, title, description, make, model, year, mileage, price, condition, transmission, fuel_type, color, vin, images, city, state, coordinates, status, is_featured, views_count, expires_at)
VALUES
-- 1. Tesla Model S (Electric/Luxury)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2022 Tesla Model S Plaid', 
 'Incredible acceleration and range. Tri-motor all-wheel drive. Yoke steering.', 
 'Tesla', 'Model S', 2022, 15000, 89900.00, 
 'excellent', 'automatic', 'electric', 'Red', '5YJSA1E23NF123456', 
 ARRAY['https://placehold.co/800x600/b91c1c/white?text=Tesla+Model+S'], 
 'San Francisco', 'CA', ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326),
 'active', TRUE, 450, NOW() + INTERVAL '90 days'),

-- 2. Ford F-150 (Truck/Work)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2021 Ford F-150 Lariat', 
 'Powerful work truck with luxury features. 3.5L EcoBoost V6.', 
 'Ford', 'F-150', 2021, 28000, 45500.00, 
 'good', 'automatic', 'petrol', 'Blue', '1FTEW1E51MF234567', 
 ARRAY['https://placehold.co/800x600/1e3a8a/white?text=Ford+F-150'], 
 'Dallas', 'TX', ST_SetSRID(ST_MakePoint(-96.7970, 32.7767), 4326),
 'active', FALSE, 120, NOW() + INTERVAL '90 days'),

-- 3. Toyota RAV4 (SUV/Family)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2020 Toyota RAV4 Hybrid XSE', 
 'Fuel efficient and spacious. Perfect family SUV with sporty styling.', 
 'Toyota', 'RAV4', 2020, 35000, 31200.00, 
 'excellent', 'automatic', 'hybrid', 'White', 'JTMWA1FV5LD345678', 
 ARRAY['https://placehold.co/800x600/f3f4f6/black?text=Toyota+RAV4'], 
 'Seattle', 'WA', ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326),
 'active', TRUE, 210, NOW() + INTERVAL '90 days'),

-- 4. Porsche 911 (Sports/Classic)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2019 Porsche 911 Carrera S', 
 'The quintessential sports car. PDK transmission, Sport Chrono package.', 
 'Porsche', '911', 2019, 12000, 105000.00, 
 'excellent', 'automatic', 'petrol', 'Silver', 'WP0AB2A91KS456789', 
 ARRAY['https://placehold.co/800x600/9ca3af/black?text=Porsche+911'], 
 'Miami', 'FL', ST_SetSRID(ST_MakePoint(-80.1918, 25.7617), 4326),
 'active', TRUE, 890, NOW() + INTERVAL '90 days'),

-- 5. Honda Civic (Sedan/Value)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2018 Honda Civic EX', 
 'Reliable daily driver with great gas mileage. Sunroof and lane watch camera.', 
 'Honda', 'Civic', 2018, 55000, 18500.00, 
 'good', 'automatic', 'petrol', 'Black', '19XFC1F52JE567890', 
 ARRAY['https://placehold.co/800x600/000000/white?text=Honda+Civic'], 
 'Chicago', 'IL', ST_SetSRID(ST_MakePoint(-87.6298, 41.8781), 4326),
 'active', FALSE, 95, NOW() + INTERVAL '90 days'),

-- 6. BMW X5 (Luxury SUV)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2023 BMW X5 xDrive40i', 
 'Luxury midsize SUV with advanced tech. Panoramic roof, heated seats.', 
 'BMW', 'X5', 2023, 8000, 62000.00, 
 'excellent', 'automatic', 'petrol', 'Grey', '5UXCR6C05P9678901', 
 ARRAY['https://placehold.co/800x600/4b5563/white?text=BMW+X5'], 
 'New York', 'NY', ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326),
 'active', TRUE, 340, NOW() + INTERVAL '90 days'),

-- 7. Chevrolet Corvette (Sports/American)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2021 Chevrolet Corvette Stingray', 
 'Mid-engine supercar performance for a fraction of the price. 3LT trim.', 
 'Chevrolet', 'Corvette', 2021, 15000, 75000.00, 
 'excellent', 'automatic', 'petrol', 'Red', '1G1YB2D93M5789012', 
 ARRAY['https://placehold.co/800x600/ef4444/white?text=Corvette'], 
 'Los Angeles', 'CA', ST_SetSRID(ST_MakePoint(-118.2437, 34.0522), 4326),
 'active', TRUE, 560, NOW() + INTERVAL '90 days'),

-- 8. Jeep Wrangler (Off-road)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2020 Jeep Wrangler Unlimited Rubicon', 
 'Ready for any adventure. Lifted, 35-inch tires, winch.', 
 'Jeep', 'Wrangler', 2020, 42000, 41000.00, 
 'good', 'automatic', 'petrol', 'Green', '1C4HJXFG4LW890123', 
 ARRAY['https://placehold.co/800x600/166534/white?text=Jeep+Wrangler'], 
 'Denver', 'CO', ST_SetSRID(ST_MakePoint(-104.9903, 39.7392), 4326),
 'active', FALSE, 180, NOW() + INTERVAL '90 days'),

-- 9. Hyundai Sonata (Sedan/Value)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2021 Hyundai Sonata SEL', 
 'Stylish reliable sedan. Packed with safety features.', 
 'Hyundai', 'Sonata', 2021, 30000, 21500.00, 
 'excellent', 'automatic', 'petrol', 'Blue', '5NPPE4JA2MH901234', 
 ARRAY['https://placehold.co/800x600/2563eb/white?text=Hyundai+Sonata'], 
 'Phoenix', 'AZ', ST_SetSRID(ST_MakePoint(-112.0740, 33.4484), 4326),
 'active', FALSE, 75, NOW() + INTERVAL '90 days'),

-- 10. Audi Q7 (Luxury SUV/Family)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2019 Audi Q7 Premium Plus', 
 '7-seater luxury SUV. Virtual cockpit, leather interior.', 
 'Audi', 'Q7', 2019, 48000, 39900.00, 
 'good', 'automatic', 'petrol', 'Black', 'WA1VAAF75KD012345', 
 ARRAY['https://placehold.co/800x600/000000/white?text=Audi+Q7'], 
 'Boston', 'MA', ST_SetSRID(ST_MakePoint(-71.0589, 42.3601), 4326),
 'active', FALSE, 110, NOW() + INTERVAL '90 days'),

-- 11. Nissan Altima (Sedan)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2020 Nissan Altima SR', 
 'Sporty sedan with comfortable seats. AWD available.', 
 'Nissan', 'Altima', 2020, 38000, 19800.00, 
 'good', 'automatic', 'petrol', 'Orange', '1N4BL4BV6LC123456', 
 ARRAY['https://placehold.co/800x600/f97316/white?text=Nissan+Altima'], 
 'Atlanta', 'GA', ST_SetSRID(ST_MakePoint(-84.3879, 33.7490), 4326),
 'active', FALSE, 65, NOW() + INTERVAL '90 days'),

-- 12. Mazda CX-5 (Crossover)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2022 Mazda CX-5 Grand Touring', 
 'Fun to drive crossover with premium interior feel.', 
 'Mazda', 'CX-5', 2022, 18000, 29500.00, 
 'excellent', 'automatic', 'petrol', 'Red', 'JM3KFBDM8N0234567', 
 ARRAY['https://placehold.co/800x600/991b1b/white?text=Mazda+CX-5'], 
 'San Diego', 'CA', ST_SetSRID(ST_MakePoint(-117.1611, 32.7157), 4326),
 'active', TRUE, 195, NOW() + INTERVAL '90 days'),

-- 13. Lexus RX350 (Luxury Crossover)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2018 Lexus RX 350', 
 'Smooth, quiet, and reliable luxury utility vehicle.', 
 'Lexus', 'RX 350', 2018, 52000, 33000.00, 
 'excellent', 'automatic', 'petrol', 'White', '2T2ZZMCA7JC345678', 
 ARRAY['https://placehold.co/800x600/f3f4f6/black?text=Lexus+RX350'], 
 'Austin', 'TX', ST_SetSRID(ST_MakePoint(-97.7431, 30.2672), 4326),
 'active', FALSE, 135, NOW() + INTERVAL '90 days'),

-- 14. Volkswagen Golf GTI (Hatchback/Sport)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2021 Volkswagen Golf GTI Autobahn', 
 'The original hot hatch. Fun, practical, and fast.', 
 'Volkswagen', 'Golf GTI', 2021, 23000, 28000.00, 
 'excellent', 'manual', 'petrol', 'Grey', '3VW5T7AU2MM456789', 
 ARRAY['https://placehold.co/800x600/374151/white?text=Golf+GTI'], 
 'Portland', 'OR', ST_SetSRID(ST_MakePoint(-122.6765, 45.5231), 4326),
 'active', TRUE, 220, NOW() + INTERVAL '90 days'),

-- 15. Subaru Outback (Wagon/Adventure)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2020 Subaru Outback Limited', 
 'Standard AWD, spacious interior, great for outdoors.', 
 'Subaru', 'Outback', 2020, 40000, 26500.00, 
 'good', 'automatic', 'petrol', 'Green', '4S4BSANC3L3567890', 
 ARRAY['https://placehold.co/800x600/15803d/white?text=Subaru+Outback'], 
 'Salt Lake City', 'UT', ST_SetSRID(ST_MakePoint(-111.8910, 40.7608), 4326),
 'active', FALSE, 115, NOW() + INTERVAL '90 days'),

-- 16. Rivian R1T (Electric Truck)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2022 Rivian R1T Launch Edition', 
 'Revolutionary electric adventure truck. Quad-motor, 0-60 in 3s.', 
 'Rivian', 'R1T', 2022, 11000, 72000.00, 
 'excellent', 'automatic', 'electric', 'Green', '7FCTGAAA3NN678901', 
 ARRAY['https://placehold.co/800x600/14532d/white?text=Rivian+R1T'], 
 'San Francisco', 'CA', ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326),
 'active', TRUE, 600, NOW() + INTERVAL '90 days'),

-- 17. Dodge Challenger (Muscle Car)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2019 Dodge Challenger R/T Scat Pack', 
 'Modern muscle. 6.4L Hemi V8, aggressive styling.', 
 'Dodge', 'Challenger', 2019, 29000, 38000.00, 
 'good', 'manual', 'petrol', 'Black', '2C3CDZFJ5KH789012', 
 ARRAY['https://placehold.co/800x600/000000/white?text=Challenger'], 
 'Las Vegas', 'NV', ST_SetSRID(ST_MakePoint(-115.1398, 36.1699), 4326),
 'active', TRUE, 275, NOW() + INTERVAL '90 days'),

-- 18. Kia Telluride (SUV/Family)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2022 Kia Telluride SX', 
 'Award-winning 3-row SUV. Upscale design and features.', 
 'Kia', 'Telluride', 2022, 22000, 44500.00, 
 'excellent', 'automatic', 'petrol', 'White', '5XYP34HC1NG890123', 
 ARRAY['https://placehold.co/800x600/f3f4f6/black?text=Kia+Telluride'], 
 'Nashville', 'TN', ST_SetSRID(ST_MakePoint(-86.7816, 36.1627), 4326),
 'active', TRUE, 210, NOW() + INTERVAL '90 days'),

-- 19. Lucid Air (Luxury Electric)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2022 Lucid Air Grand Touring', 
 'Luxury electric sedan with over 500 miles of range.', 
 'Lucid', 'Air', 2022, 9000, 115000.00, 
 'excellent', 'automatic', 'electric', 'Gold', '50EA2D998NA901234', 
 ARRAY['https://placehold.co/800x600/ca8a04/white?text=Lucid+Air'], 
 'San Jose', 'CA', ST_SetSRID(ST_MakePoint(-121.8863, 37.3382), 4326),
 'active', TRUE, 250, NOW() + INTERVAL '90 days'),

-- 20. Acura MDX (SUV)
(uuid_generate_v4(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 
 '2022 Acura MDX A-Spec', 
 'Sporty luxury SUV. Sharp handling and tech-forward interior.', 
 'Acura', 'MDX', 2022, 25000, 48000.00, 
 'excellent', 'automatic', 'petrol', 'Blue', '5J8YD4H84NL012345', 
 ARRAY['https://placehold.co/800x600/1d4ed8/white?text=Acura+MDX'], 
 'Columbus', 'OH', ST_SetSRID(ST_MakePoint(-82.9988, 39.9612), 4326),
 'active', FALSE, 90, NOW() + INTERVAL '90 days');

-- Verifying insertion
SELECT count(*) as total_cars FROM cars;
