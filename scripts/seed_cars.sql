-- =====================================================
-- Seed 10 Dummy Car Listings for PgAdmin4
-- =====================================================

-- Insert 10 dummy cars
INSERT INTO cars (id, seller_id, title, description, make, model, year, mileage, price, condition, transmission, fuel_type, color, vin, images, city, state, status, is_featured, views_count, expires_at)
VALUES
-- Car 1: Toyota Camry
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Toyota Camry 2020 - Excellent Condition', 'Well maintained Toyota Camry with full service history. Single owner, no accidents.', 'Toyota', 'Camry', 2020, 25000, 28500.00, 'excellent', 'automatic', 'petrol', 'White', 'JTD56WFBXR3012345', ARRAY['https://placehold.co/800x600/2563eb/white?text=Camry'], 'New York', 'NY', 'active', TRUE, 150, NOW() + INTERVAL '90 days'),

-- Car 2: Honda Accord
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Honda Accord 2019 - Low Mileage', 'Reliable Honda Accord in great condition. Low mileage, excellent fuel economy.', 'Honda', 'Accord', 2019, 32000, 24000.00, 'good', 'automatic', 'petrol', 'Silver', 'HMXG45RABK805432', ARRAY['https://placehold.co/800x600/dc2626/white?text=Accord'], 'Los Angeles', 'CA', 'active', FALSE, 85, NOW() + INTERVAL '90 days'),

-- Car 3: BMW 330i
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'BMW 330i 2021 - Sporty Sedan', 'Luxury BMW 330i with M Sport package. Turbocharged engine, premium sound system.', 'BMW', '330i', 2021, 18000, 42000.00, 'excellent', 'automatic', 'petrol', 'Black', 'BMWM3SPORT2021AB', ARRAY['https://placehold.co/800x600/1e3a8a/white?text=BMW'], 'Chicago', 'IL', 'active', TRUE, 220, NOW() + INTERVAL '90 days'),

-- Car 4: Tesla Model 3
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Tesla Model 3 Long Range 2022', 'All-electric Tesla Model 3 with Autopilot. 350 miles range.', 'Tesla', 'Model 3', 2022, 12000, 48000.00, 'excellent', 'automatic', 'electric', 'Red', 'TSLA3LR2022XY78', ARRAY['https://placehold.co/800x600/b91c1c/white?text=Tesla'], 'San Francisco', 'CA', 'active', TRUE, 310, NOW() + INTERVAL '90 days'),

-- Car 5: Ford Mustang
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Ford Mustang GT 2018 - V8 Power', 'Iconic American muscle car. 5.0L V8 engine with 460 horsepower.', 'Ford', 'Mustang GT', 2018, 45000, 35000.00, 'good', 'manual', 'petrol', 'Blue', 'FORDGT5L2018MUS', ARRAY['https://placehold.co/800x600/1d4ed8/white?text=Mustang'], 'Houston', 'TX', 'active', FALSE, 175, NOW() + INTERVAL '90 days'),

-- Car 6: Mercedes C300
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Mercedes-Benz C300 2020 - Luxury Sedan', 'Elegant Mercedes C300 with AMG styling package.', 'Mercedes-Benz', 'C300', 2020, 28000, 38500.00, 'excellent', 'automatic', 'petrol', 'Grey', 'MBZC300AMG2020Q', ARRAY['https://placehold.co/800x600/374151/white?text=Mercedes'], 'Miami', 'FL', 'active', FALSE, 95, NOW() + INTERVAL '90 days'),

-- Car 7: Chevrolet Silverado
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Chevrolet Silverado 1500 2019', 'Heavy-duty Chevrolet Silverado perfect for work and recreation.', 'Chevrolet', 'Silverado 1500', 2019, 55000, 32000.00, 'good', 'automatic', 'diesel', 'White', 'CHVSILV1500WRK1', ARRAY['https://placehold.co/800x600/166534/white?text=Silverado'], 'Denver', 'CO', 'active', FALSE, 60, NOW() + INTERVAL '90 days'),

-- Car 8: Nissan Leaf
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Nissan Leaf Plus 2021 - Eco Friendly', 'Zero emissions Nissan Leaf Plus with extended range.', 'Nissan', 'Leaf Plus', 2021, 15000, 26000.00, 'excellent', 'automatic', 'electric', 'Green', 'NLEFPLUS2021ECO', ARRAY['https://placehold.co/800x600/15803d/white?text=Leaf'], 'Seattle', 'WA', 'active', FALSE, 45, NOW() + INTERVAL '90 days'),

-- Car 9: Audi A4
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Audi A4 Quattro 2020 - All Wheel Drive', 'Premium Audi A4 with Quattro AWD system.', 'Audi', 'A4 Quattro', 2020, 22000, 36000.00, 'excellent', 'automatic', 'petrol', 'Blue', 'AUDIA4QUAT2020B', ARRAY['https://placehold.co/800x600/1e40af/white?text=Audi'], 'Boston', 'MA', 'active', TRUE, 130, NOW() + INTERVAL '90 days'),

-- Car 10: Toyota Prius
(uuid_generate_v4(), '531d8696-140a-4c76-b7d0-8e49f09520b9', 'Toyota Prius 2017 - Hybrid Economy', 'Fuel-efficient Toyota Prius hybrid. Over 50 MPG combined.', 'Toyota', 'Prius', 2017, 65000, 18500.00, 'fair', 'automatic', 'hybrid', 'Silver', 'TYPRIUS2017HYB0', ARRAY['https://placehold.co/800x600/6b7280/white?text=Prius'], 'Portland', 'OR', 'active', FALSE, 40, NOW() + INTERVAL '90 days');

-- Verify the data was inserted
SELECT id, title, make, model, year, price, city, status FROM cars ORDER BY created_at DESC LIMIT 10;
