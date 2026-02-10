-- Drop the coordinates column if it exists
ALTER TABLE cars DROP COLUMN IF EXISTS coordinates;

-- Drop the PostGIS extension if it exists
DROP EXTENSION IF EXISTS postgis;

-- Drop any other PostGIS related schemas or tables if they persist
DROP SCHEMA IF EXISTS topology CASCADE;
DROP SCHEMA IF EXISTS tiger CASCADE;
