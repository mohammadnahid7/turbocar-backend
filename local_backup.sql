--
-- PostgreSQL database dump
--

\restrict gIQEO99e0YycejhjByn5IGSfLjhTRrdghmOhkrpSBqvAq1y51w36UcllnBUNH1u

-- Dumped from database version 15.8
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.user_devices DROP CONSTRAINT IF EXISTS user_devices_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.messages DROP CONSTRAINT IF EXISTS messages_sender_id_fkey;
ALTER TABLE IF EXISTS ONLY public.messages DROP CONSTRAINT IF EXISTS messages_conversation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.favorites DROP CONSTRAINT IF EXISTS favorites_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.favorites DROP CONSTRAINT IF EXISTS favorites_car_id_fkey;
ALTER TABLE IF EXISTS ONLY public.conversation_participants DROP CONSTRAINT IF EXISTS conversation_participants_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.conversation_participants DROP CONSTRAINT IF EXISTS conversation_participants_conversation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cars DROP CONSTRAINT IF EXISTS cars_seller_id_fkey;
ALTER TABLE IF EXISTS ONLY public.car_views DROP CONSTRAINT IF EXISTS car_views_viewer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.car_views DROP CONSTRAINT IF EXISTS car_views_car_id_fkey;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_user_devices_updated_at ON public.user_devices;
DROP TRIGGER IF EXISTS update_conversations_updated_at ON public.conversations;
DROP INDEX IF EXISTS public.idx_verification_codes_phone;
DROP INDEX IF EXISTS public.idx_verification_codes_expires_at;
DROP INDEX IF EXISTS public.idx_users_phone;
DROP INDEX IF EXISTS public.idx_users_is_verified;
DROP INDEX IF EXISTS public.idx_users_is_active;
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_user_devices_user_id;
DROP INDEX IF EXISTS public.idx_messages_status;
DROP INDEX IF EXISTS public.idx_messages_sender_id;
DROP INDEX IF EXISTS public.idx_messages_created_at;
DROP INDEX IF EXISTS public.idx_messages_conversation_status;
DROP INDEX IF EXISTS public.idx_messages_conversation_id;
DROP INDEX IF EXISTS public.idx_conversations_last_message_at;
DROP INDEX IF EXISTS public.idx_conversations_car_seller_id;
DROP INDEX IF EXISTS public.idx_conversations_car_id;
DROP INDEX IF EXISTS public.idx_conversation_participants_user_id;
DROP INDEX IF EXISTS public.idx_conversation_participants_unread;
DROP INDEX IF EXISTS public.idx_cars_year;
DROP INDEX IF EXISTS public.idx_cars_status;
DROP INDEX IF EXISTS public.idx_cars_seller;
DROP INDEX IF EXISTS public.idx_cars_price;
DROP INDEX IF EXISTS public.idx_cars_make_model;
DROP INDEX IF EXISTS public.idx_cars_location;
DROP INDEX IF EXISTS public.idx_cars_created_at;
DROP INDEX IF EXISTS public.idx_car_views_car_id;
ALTER TABLE IF EXISTS ONLY public.verification_codes DROP CONSTRAINT IF EXISTS verification_codes_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_phone_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.user_devices DROP CONSTRAINT IF EXISTS user_devices_user_id_fcm_token_key;
ALTER TABLE IF EXISTS ONLY public.user_devices DROP CONSTRAINT IF EXISTS user_devices_pkey;
ALTER TABLE IF EXISTS ONLY public.schema_migrations DROP CONSTRAINT IF EXISTS schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.messages DROP CONSTRAINT IF EXISTS messages_pkey;
ALTER TABLE IF EXISTS ONLY public.favorites DROP CONSTRAINT IF EXISTS favorites_pkey;
ALTER TABLE IF EXISTS ONLY public.conversations DROP CONSTRAINT IF EXISTS conversations_pkey;
ALTER TABLE IF EXISTS ONLY public.conversation_participants DROP CONSTRAINT IF EXISTS conversation_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.cars DROP CONSTRAINT IF EXISTS cars_pkey;
ALTER TABLE IF EXISTS ONLY public.car_views DROP CONSTRAINT IF EXISTS car_views_pkey;
DROP TABLE IF EXISTS public.verification_codes;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_devices;
DROP TABLE IF EXISTS public.schema_migrations;
DROP TABLE IF EXISTS public.messages;
DROP TABLE IF EXISTS public.favorites;
DROP TABLE IF EXISTS public.conversations;
DROP TABLE IF EXISTS public.conversation_participants;
DROP TABLE IF EXISTS public.cars;
DROP TABLE IF EXISTS public.car_views;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP TYPE IF EXISTS public.car_transmission;
DROP TYPE IF EXISTS public.car_status;
DROP TYPE IF EXISTS public.car_fuel_type;
DROP TYPE IF EXISTS public.car_condition;
DROP EXTENSION IF EXISTS "uuid-ossp";
DROP EXTENSION IF EXISTS postgis;
--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: car_condition; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.car_condition AS ENUM (
    'excellent',
    'good',
    'fair'
);


--
-- Name: car_fuel_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.car_fuel_type AS ENUM (
    'petrol',
    'diesel',
    'electric',
    'hybrid'
);


--
-- Name: car_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.car_status AS ENUM (
    'active',
    'sold',
    'expired',
    'flagged',
    'deleted'
);


--
-- Name: car_transmission; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.car_transmission AS ENUM (
    'automatic',
    'manual'
);


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: car_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.car_views (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    car_id uuid NOT NULL,
    viewer_id uuid,
    ip_address character varying(45),
    viewed_at timestamp with time zone DEFAULT now()
);


--
-- Name: cars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cars (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    seller_id uuid NOT NULL,
    title character varying(100) NOT NULL,
    description text,
    make character varying(50) NOT NULL,
    model character varying(50) NOT NULL,
    year integer NOT NULL,
    mileage integer NOT NULL,
    price numeric(12,2) NOT NULL,
    condition public.car_condition,
    transmission public.car_transmission,
    fuel_type public.car_fuel_type NOT NULL,
    color character varying(30),
    vin character varying(17),
    images text[] DEFAULT '{}'::text[],
    city character varying(100) NOT NULL,
    state character varying(100),
    coordinates public.geometry(Point,4326),
    status public.car_status DEFAULT 'active'::public.car_status NOT NULL,
    is_featured boolean DEFAULT false,
    views_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone,
    chat_only boolean DEFAULT false,
    CONSTRAINT cars_mileage_check CHECK ((mileage >= 0)),
    CONSTRAINT cars_price_check CHECK ((price > (0)::numeric))
);


--
-- Name: conversation_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversation_participants (
    conversation_id uuid NOT NULL,
    user_id uuid NOT NULL,
    last_read_message_id uuid,
    joined_at timestamp with time zone DEFAULT now(),
    unread_count integer DEFAULT 0
);


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    car_id uuid,
    car_title character varying(255),
    car_seller_id uuid,
    last_message_at timestamp with time zone
);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    user_id uuid NOT NULL,
    car_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid,
    sender_id uuid,
    content text,
    message_type character varying(20) DEFAULT 'text'::character varying,
    media_url text,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    status character varying(20) DEFAULT 'sent'::character varying,
    delivered_at timestamp with time zone,
    seen_at timestamp with time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: user_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_devices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    fcm_token character varying(512) NOT NULL,
    device_type character varying(20) DEFAULT 'android'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text NOT NULL,
    phone character varying(20) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    profile_photo_url character varying(500),
    is_verified boolean DEFAULT false,
    is_dealer boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login_at timestamp without time zone,
    gender character varying(20),
    dob date
);


--
-- Name: verification_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verification_codes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    phone character varying(20) NOT NULL,
    code character varying(10) NOT NULL,
    attempts integer DEFAULT 0,
    is_verified boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone NOT NULL
);


--
-- Data for Name: car_views; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.car_views (id, car_id, viewer_id, ip_address, viewed_at) FROM stdin;
\.


--
-- Data for Name: cars; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cars (id, seller_id, title, description, make, model, year, mileage, price, condition, transmission, fuel_type, color, vin, images, city, state, coordinates, status, is_featured, views_count, created_at, updated_at, expires_at, chat_only) FROM stdin;
e2dd20ef-4570-4e1b-a863-fd43afdbdb25	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW 3 Series #1	This is a generated listing for car #1. Features premium interior and low mileage.	BMW	3 Series	2015	73332	38092.00	excellent	automatic	diesel	Blue	VIN1169064	{https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg}	City 1	State	0101000020E6100000EE3CF935E02254C0161849AEE87B4340	active	t	147	2026-01-31 06:44:37.478184+00	2026-01-31 06:44:37.478184+00	2026-05-01 08:23:37.478184+00	f
cf40fa34-9049-476b-aa92-f74aea916cd1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi Altima #2	This is a generated listing for car #2. Features premium interior and low mileage.	Audi	Altima	2023	34954	42236.00	excellent	automatic	diesel	Red	VIN231114	{https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg}	City 2	State	0101000020E61000007B83A630602354C0F8831E2EA2E04240	active	f	55	2026-01-31 06:45:37.478184+00	2026-01-31 06:45:37.478184+00	2026-05-01 08:23:37.478184+00	f
5ddf17fb-0124-42a8-8d46-3c909f182ca1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes F-150 #3	This is a generated listing for car #3. Features premium interior and low mileage.	Mercedes	F-150	2016	93912	66543.00	excellent	automatic	hybrid	White	VIN3896157	{https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg}	City 3	State	0101000020E6100000A3CC0DB3EE6655C02059BAE060994840	active	f	40	2026-01-31 06:46:37.478184+00	2026-01-31 06:46:37.478184+00	2026-05-01 08:23:37.478184+00	f
f9501a9d-af36-4f71-a00a-7632ba5a60a2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla Model 3 #4	This is a generated listing for car #4. Features premium interior and low mileage.	Tesla	Model 3	2018	88339	84351.00	excellent	automatic	diesel	Blue	VIN4686994	{https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg}	City 4	State	0101000020E61000008EEE78881C2055C04620A64E0F644340	active	f	0	2026-01-31 06:47:37.478184+00	2026-01-31 06:47:37.478184+00	2026-05-01 08:23:37.478184+00	f
239f8226-9969-45ee-8cc8-404e9665f451	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet C-Class #5	This is a generated listing for car #5. Features premium interior and low mileage.	Chevrolet	C-Class	2024	64860	79050.00	excellent	automatic	petrol	Black	VIN5158194	{https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg}	City 5	State	0101000020E61000001E6A5A38BF7851C0A868E5846A854140	active	f	124	2026-01-31 06:48:37.478184+00	2026-01-31 06:48:37.478184+00	2026-05-01 08:23:37.478184+00	f
8846ac15-e5f6-42ad-8e2f-64f028596de5	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Ford Silverado #6	This is a generated listing for car #6. Features premium interior and low mileage.	Ford	Silverado	2019	45017	70879.00	excellent	automatic	petrol	Gray	VIN62075	{https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg}	City 6	State	0101000020E610000073B1B19B432653C06736873FF9364640	active	f	149	2026-01-31 06:49:37.478184+00	2026-01-31 06:49:37.478184+00	2026-05-01 08:23:37.478184+00	f
b3ca264a-6522-480f-b624-d081083f0866	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda Silverado #7	This is a generated listing for car #7. Features premium interior and low mileage.	Honda	Silverado	2024	87465	82103.00	excellent	automatic	petrol	White	VIN7298256	{https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg}	City 7	State	0101000020E6100000248EB2FDB23A51C0B9F6978F96EC4540	active	f	253	2026-01-31 06:50:37.478184+00	2026-01-31 06:50:37.478184+00	2026-05-01 08:23:37.478184+00	f
bce216cd-bbbc-4ad4-b688-676737ee3dbf	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai 3 Series #8	This is a generated listing for car #8. Features premium interior and low mileage.	Hyundai	3 Series	2015	91015	85091.00	excellent	automatic	electric	Gray	VIN8130668	{https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg}	City 8	State	0101000020E610000062B6B103C1A54AC02E0813D7B0964540	active	f	63	2026-01-31 06:51:37.478184+00	2026-01-31 06:51:37.478184+00	2026-05-01 08:23:37.478184+00	f
09b3cc23-8ce9-49e9-90da-01bcbae3a862	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW Camry #9	This is a generated listing for car #9. Features premium interior and low mileage.	BMW	Camry	2021	45422	16584.00	excellent	automatic	electric	Red	VIN952231	{https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg}	City 9	State	0101000020E6100000E674837F349553C0CE4635DF4C1E4040	active	f	482	2026-01-31 06:52:37.478184+00	2026-01-31 06:52:37.478184+00	2026-05-01 08:23:37.478184+00	f
921c8ecd-76ce-4720-96e2-aa237e5eae81	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet C-Class #10	This is a generated listing for car #10. Features premium interior and low mileage.	Chevrolet	C-Class	2024	44841	48522.00	excellent	automatic	hybrid	Red	VIN10927976	{https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg}	City 10	State	0101000020E61000004294C6A6798C53C0035B79283A434540	active	f	371	2026-01-31 06:53:37.478184+00	2026-01-31 06:53:37.478184+00	2026-05-01 08:23:37.478184+00	f
6ecc07e4-8a18-48c6-800c-657e8c4af284	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Model 3 #11	This is a generated listing for car #11. Features premium interior and low mileage.	Mercedes	Model 3	2018	76287	17140.00	excellent	automatic	electric	Red	VIN11182736	{https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg}	City 11	State	0101000020E6100000BEFBDD26199755C0966BEB0D45174340	active	f	36	2026-01-31 06:54:37.478184+00	2026-01-31 06:54:37.478184+00	2026-05-01 08:23:37.478184+00	f
91165ea8-b0ad-4fd1-9001-3e2dfc6cc47c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda Elantra #12	This is a generated listing for car #12. Features premium interior and low mileage.	Honda	Elantra	2019	6959	94462.00	excellent	automatic	electric	Blue	VIN12139955	{https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg}	City 12	State	0101000020E61000004D20D3E413014CC0611D03DED0383E40	active	f	113	2026-01-31 06:55:37.478184+00	2026-01-31 06:55:37.478184+00	2026-05-01 08:23:37.478184+00	f
7d571e7b-ecf5-41a1-9495-797ba0cafb18	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes F-150 #13	This is a generated listing for car #13. Features premium interior and low mileage.	Mercedes	F-150	2015	11182	49989.00	excellent	automatic	hybrid	Green	VIN13941922	{https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg}	City 13	State	0101000020E610000083DFB788FFCD52C0EC289B47C2F94540	active	f	102	2026-01-31 06:56:37.478184+00	2026-01-31 06:56:37.478184+00	2026-05-01 08:23:37.478184+00	f
014ab726-c554-45d2-b870-32b4c7d9e632	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla C-Class #14	This is a generated listing for car #14. Features premium interior and low mileage.	Tesla	C-Class	2023	7226	58193.00	excellent	automatic	hybrid	Blue	VIN14893683	{https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png}	City 14	State	0101000020E61000009671C904DD5A49C0F2A00569DA0A4040	active	f	365	2026-01-31 06:57:37.478184+00	2026-01-31 06:57:37.478184+00	2026-05-01 08:23:37.478184+00	f
996c1471-3277-42b6-aa07-9155416a3ddc	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Ford 3 Series #15	This is a generated listing for car #15. Features premium interior and low mileage.	Ford	3 Series	2015	93666	82009.00	excellent	automatic	hybrid	Silver	VIN15204700	{https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg}	City 15	State	0101000020E6100000BD13EA51763951C0D033E742EDAD4140	active	f	395	2026-01-31 06:58:37.478184+00	2026-01-31 06:58:37.478184+00	2026-05-01 08:23:37.478184+00	f
9927ef88-50b5-469d-85ab-4b92940b1b8b	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda A4 #16	This is a generated listing for car #16. Features premium interior and low mileage.	Honda	A4	2016	66707	17526.00	excellent	automatic	petrol	Red	VIN16914101	{https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg}	City 16	State	0101000020E6100000CCFCBC30343D56C0504EBDFF75624840	active	f	392	2026-01-31 06:59:37.478184+00	2026-01-31 06:59:37.478184+00	2026-05-01 08:23:37.478184+00	f
b9998fea-4f4a-4423-a952-3f55a14097f2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Ford A4 #17	This is a generated listing for car #17. Features premium interior and low mileage.	Ford	A4	2015	17977	91610.00	excellent	automatic	hybrid	Gray	VIN17200101	{https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg}	City 17	State	0101000020E61000004CD9EAD3C37E4FC0F462168FF6FA4640	active	f	461	2026-01-31 07:00:37.478184+00	2026-01-31 07:00:37.478184+00	2026-05-01 08:23:37.478184+00	f
9d17db55-af6b-4969-9f09-ef8f3dc81c61	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes C-Class #18	This is a generated listing for car #18. Features premium interior and low mileage.	Mercedes	C-Class	2019	71501	51971.00	excellent	automatic	petrol	Green	VIN18859881	{https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg}	City 18	State	0101000020E61000002994E8616FE14EC09AC854CFD9F84640	active	f	465	2026-01-31 07:01:37.478184+00	2026-01-31 07:01:37.478184+00	2026-05-01 08:23:37.478184+00	f
707c36f3-9dcd-4d7e-a5a9-097988a4447c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Civic #19	This is a generated listing for car #19. Features premium interior and low mileage.	Mercedes	Civic	2021	18166	85197.00	excellent	automatic	petrol	White	VIN19478451	{https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg}	City 19	State	0101000020E6100000BEC85C51901E51C0F87B5A07AFB04640	active	f	455	2026-01-31 07:02:37.478184+00	2026-01-31 07:02:37.478184+00	2026-05-01 08:23:37.478184+00	f
c447af31-5200-4d5e-b22e-5f56bb83a1c4	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi Silverado #20	This is a generated listing for car #20. Features premium interior and low mileage.	Audi	Silverado	2024	36573	53680.00	excellent	automatic	hybrid	Black	VIN20583466	{https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg}	City 20	State	0101000020E610000054C7B121EE7751C0A7D994D2A02F4740	active	f	27	2026-01-31 07:03:37.478184+00	2026-01-31 07:03:37.478184+00	2026-05-01 08:23:37.478184+00	f
f083a6b1-5d88-40b4-b9ed-fe9fb203e88c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan Elantra #21	This is a generated listing for car #21. Features premium interior and low mileage.	Nissan	Elantra	2020	70654	90826.00	excellent	automatic	petrol	Green	VIN21975839	{https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg}	City 21	State	0101000020E610000064D832DC058153C08B40E71E40CA4040	active	f	249	2026-01-31 07:04:37.478184+00	2026-01-31 07:04:37.478184+00	2026-05-01 08:23:37.478184+00	f
64cf2cef-a10f-4860-94b5-7bacbea092fe	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Ford Camry #22	This is a generated listing for car #22. Features premium interior and low mileage.	Ford	Camry	2017	32894	21536.00	excellent	automatic	electric	Silver	VIN22215397	{https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg}	City 22	State	0101000020E6100000F3666667C5214AC0C24B7DE93D234440	active	f	151	2026-01-31 07:05:37.478184+00	2026-01-31 07:05:37.478184+00	2026-05-01 08:23:37.478184+00	f
96fad830-a3f1-419c-99e4-c1ec21381868	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla Elantra #23	This is a generated listing for car #23. Features premium interior and low mileage.	Tesla	Elantra	2022	11039	58393.00	excellent	automatic	diesel	Silver	VIN23866475	{https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg}	City 23	State	0101000020E610000043DD3A863E2F4AC09C39DACF464E4740	active	f	94	2026-01-31 07:06:37.478184+00	2026-01-31 07:06:37.478184+00	2026-05-01 08:23:37.478184+00	f
9decb1bf-01ef-4d99-ab3f-3da43f982adb	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet A4 #24	This is a generated listing for car #24. Features premium interior and low mileage.	Chevrolet	A4	2017	74169	44696.00	excellent	automatic	hybrid	Green	VIN24264019	{https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg}	City 24	State	0101000020E6100000D6D919C3B0544FC0E11AF561ADCA4840	active	f	424	2026-01-31 07:07:37.478184+00	2026-01-31 07:07:37.478184+00	2026-05-01 08:23:37.478184+00	f
b0cdf8ae-7585-4612-9a2c-fa924524f53c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda Model 3 #25	This is a generated listing for car #25. Features premium interior and low mileage.	Honda	Model 3	2015	91952	43438.00	excellent	automatic	hybrid	Blue	VIN25435843	{https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg}	City 25	State	0101000020E61000007ABD837E974C4AC068504E407CBE4540	active	f	283	2026-01-31 07:08:37.478184+00	2026-01-31 07:08:37.478184+00	2026-05-01 08:23:37.478184+00	f
145749de-f1a6-4adf-bac3-832d7cc11751	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Model 3 #26	This is a generated listing for car #26. Features premium interior and low mileage.	Toyota	Model 3	2021	95973	78377.00	excellent	automatic	electric	Gray	VIN26729210	{https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg}	City 26	State	0101000020E6100000233D023E1E7C56C07803743AD2114040	active	f	427	2026-01-31 07:09:37.478184+00	2026-01-31 07:09:37.478184+00	2026-05-01 08:23:37.478184+00	f
f145a186-0ef7-4968-9d0a-3fc8582dfac9	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda Altima #27	This is a generated listing for car #27. Features premium interior and low mileage.	Honda	Altima	2018	47108	66688.00	excellent	automatic	hybrid	Blue	VIN27572112	{https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg}	City 27	State	0101000020E6100000F957F7B6F79F54C02C7CCCBC94164840	active	f	133	2026-01-31 07:10:37.478184+00	2026-01-31 07:10:37.478184+00	2026-05-01 08:23:37.478184+00	f
8d76409f-f9e0-4060-a262-779265389cd7	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW Model 3 #28	This is a generated listing for car #28. Features premium interior and low mileage.	BMW	Model 3	2017	70569	90694.00	excellent	automatic	hybrid	Gray	VIN28387115	{https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg}	City 28	State	0101000020E6100000AFA0AEF3394C4AC02B30848BB50B4840	active	f	344	2026-01-31 07:11:37.478184+00	2026-01-31 07:11:37.478184+00	2026-05-01 08:23:37.478184+00	f
81247a43-4a54-474a-8820-f11a3bb88252	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW Silverado #29	This is a generated listing for car #29. Features premium interior and low mileage.	BMW	Silverado	2018	25894	89144.00	excellent	automatic	electric	White	VIN29258043	{https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg}	City 29	State	0101000020E6100000D5C1ECACC6D64DC0483A77A456884840	active	f	66	2026-01-31 07:12:37.478184+00	2026-01-31 07:12:37.478184+00	2026-05-01 08:23:37.478184+00	f
4273c637-f0ce-4410-9448-62e6549ac632	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai Silverado #30	This is a generated listing for car #30. Features premium interior and low mileage.	Hyundai	Silverado	2023	92776	47551.00	excellent	automatic	diesel	Blue	VIN30383231	{https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg}	City 30	State	0101000020E61000006087A2498D3951C0B70427296C4E4540	active	f	114	2026-01-31 07:13:37.478184+00	2026-01-31 07:13:37.478184+00	2026-05-01 08:23:37.478184+00	f
9228d7f6-a5c3-4ece-8136-3f63bb1fcc62	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW C-Class #31	This is a generated listing for car #31. Features premium interior and low mileage.	BMW	C-Class	2017	20606	28114.00	excellent	automatic	petrol	Red	VIN31787312	{https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg}	City 31	State	0101000020E61000003441C27CAA5A4EC055A83BD8E3033F40	active	f	486	2026-01-31 07:14:37.478184+00	2026-01-31 07:14:37.478184+00	2026-05-01 08:23:37.478184+00	f
2fcbd146-a98e-473b-9a70-d0b8aebe82d9	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi A4 #32	This is a generated listing for car #32. Features premium interior and low mileage.	Audi	A4	2018	47939	27935.00	excellent	automatic	diesel	Black	VIN32597556	{https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg}	City 32	State	0101000020E6100000B93B4877B0E055C044A4D3F5017A4140	active	t	436	2026-01-31 07:15:37.478184+00	2026-01-31 07:15:37.478184+00	2026-05-01 08:23:37.478184+00	f
cbf6660d-1219-4190-89d9-f5d89f113134	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Altima #33	This is a generated listing for car #33. Features premium interior and low mileage.	Toyota	Altima	2020	45776	62042.00	excellent	automatic	petrol	Green	VIN33431527	{https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png}	City 33	State	0101000020E61000005B9D74AE936C4CC02DA6B66B30D24140	active	f	131	2026-01-31 07:16:37.478184+00	2026-01-31 07:16:37.478184+00	2026-05-01 08:23:37.478184+00	f
30951396-02c8-4971-b8e3-6ce9a3535c20	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Camry #34	This is a generated listing for car #34. Features premium interior and low mileage.	Mercedes	Camry	2021	91899	73372.00	excellent	automatic	hybrid	White	VIN34940675	{https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg}	City 34	State	0101000020E6100000AF70B0102F7054C0FD60731EBB9F4140	active	f	349	2026-01-31 07:17:37.478184+00	2026-01-31 07:17:37.478184+00	2026-05-01 08:23:37.478184+00	f
0f33e615-5be1-485b-82dc-a7232ddd0500	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet Elantra #35	This is a generated listing for car #35. Features premium interior and low mileage.	Chevrolet	Elantra	2023	52032	89775.00	excellent	automatic	electric	Gray	VIN35178694	{https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg}	City 35	State	0101000020E6100000C8D2D747EAC352C046EBBA2AB2124340	active	f	62	2026-01-31 07:18:37.478184+00	2026-01-31 07:18:37.478184+00	2026-05-01 08:23:37.478184+00	f
a573f832-7cae-4557-a60d-c80c37348570	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai Camry #36	This is a generated listing for car #36. Features premium interior and low mileage.	Hyundai	Camry	2024	88744	34119.00	excellent	automatic	hybrid	White	VIN36457833	{https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg}	City 36	State	0101000020E61000001781211792BC4BC08214CC7ED2643E40	active	f	7	2026-01-31 07:19:37.478184+00	2026-01-31 07:19:37.478184+00	2026-05-01 08:23:37.478184+00	f
a5ada692-3b4a-4023-bd3e-02f4278e2a52	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan C-Class #37	This is a generated listing for car #37. Features premium interior and low mileage.	Nissan	C-Class	2017	68559	40524.00	excellent	automatic	diesel	Black	VIN37474522	{https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg}	City 37	State	0101000020E610000097EA1DCFA08F4AC01A144F21748A4040	active	t	367	2026-01-31 07:20:37.478184+00	2026-01-31 07:20:37.478184+00	2026-05-01 08:23:37.478184+00	f
a36cf705-605c-40dd-b138-41fce41f0941	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla 3 Series #38	This is a generated listing for car #38. Features premium interior and low mileage.	Tesla	3 Series	2016	39347	11493.00	excellent	automatic	electric	Red	VIN382909	{https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg}	City 38	State	0101000020E61000009EF3955ABA9949C0FA2D403D33684640	active	f	447	2026-01-31 07:21:37.478184+00	2026-01-31 07:21:37.478184+00	2026-05-01 08:23:37.478184+00	f
d65e2432-94b3-489f-ba26-2e4fa7c595c2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet A4 #39	This is a generated listing for car #39. Features premium interior and low mileage.	Chevrolet	A4	2022	57790	85783.00	excellent	automatic	electric	Black	VIN3924941	{https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg}	City 39	State	0101000020E610000034D8F7F03FEE49C0980D07BA032C4840	active	f	327	2026-01-31 07:22:37.478184+00	2026-01-31 07:22:37.478184+00	2026-05-01 08:23:37.478184+00	f
5f675fc6-7bf6-4d5f-bd4a-419fa1967da6	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet Elantra #40	This is a generated listing for car #40. Features premium interior and low mileage.	Chevrolet	Elantra	2022	58146	70465.00	excellent	automatic	petrol	Gray	VIN40741679	{https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg}	City 40	State	0101000020E6100000E80C262B29F554C09CCF807330414140	active	f	61	2026-01-31 07:23:37.478184+00	2026-01-31 07:23:37.478184+00	2026-05-01 08:23:37.478184+00	f
12b85562-ce76-4569-a238-98d10502b447	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda Silverado #41	This is a generated listing for car #41. Features premium interior and low mileage.	Honda	Silverado	2022	65681	49082.00	excellent	automatic	hybrid	Black	VIN41926001	{https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg}	City 41	State	0101000020E6100000A8D3746979484EC018DB687313074540	active	f	315	2026-01-31 07:24:37.478184+00	2026-01-31 07:24:37.478184+00	2026-05-01 08:23:37.478184+00	f
a88f0cb7-02dc-42ef-a8f7-c76d7b024326	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes C-Class #42	This is a generated listing for car #42. Features premium interior and low mileage.	Mercedes	C-Class	2021	43693	71671.00	excellent	automatic	hybrid	Red	VIN42124918	{https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg}	City 42	State	0101000020E6100000AE16A3E234D754C0D8D1EFE1B2733E40	active	f	138	2026-01-31 07:25:37.478184+00	2026-01-31 07:25:37.478184+00	2026-05-01 08:23:37.478184+00	f
f3795295-7d16-45c0-a9f9-b9d82ca6b00c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Ford F-150 #43	This is a generated listing for car #43. Features premium interior and low mileage.	Ford	F-150	2015	19493	50255.00	excellent	automatic	diesel	Black	VIN43776581	{https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg}	City 43	State	0101000020E6100000B2B68D06700356C02C8FB0453A0C4340	active	t	111	2026-01-31 07:26:37.478184+00	2026-01-31 07:26:37.478184+00	2026-05-01 08:23:37.478184+00	f
36170e40-bcb5-4fae-b373-cb6c4bce55a7	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda 3 Series #44	This is a generated listing for car #44. Features premium interior and low mileage.	Honda	3 Series	2016	56376	13834.00	excellent	automatic	diesel	Gray	VIN44226718	{https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg}	City 44	State	0101000020E610000046A092B2FD6850C07DBF3238CAF34040	active	f	280	2026-01-31 07:27:37.478184+00	2026-01-31 07:27:37.478184+00	2026-05-01 08:23:37.478184+00	f
69848481-9421-4b49-a675-a013373cd68c	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi Civic #63	This is a generated listing for car #63. Features premium interior and low mileage.	Audi	Civic	2019	53188	84372.00	excellent	automatic	diesel	Black	VIN63132778	{https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg}	City 63	State	0101000020E61000008AA75C3B36A855C002B45B5EA2813F40	active	f	335	2026-01-31 07:46:37.478184+00	2026-01-31 07:46:37.478184+00	2026-05-01 08:23:37.478184+00	f
61c41103-6ff0-4ebd-ab76-7156f3757daf	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW Silverado #45	This is a generated listing for car #45. Features premium interior and low mileage.	BMW	Silverado	2018	11939	57497.00	excellent	automatic	electric	White	VIN45189980	{https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg}	City 45	State	0101000020E610000063CBC6E86F7653C01CE56E53553F3E40	active	f	306	2026-01-31 07:28:37.478184+00	2026-01-31 07:28:37.478184+00	2026-05-01 08:23:37.478184+00	f
c9093210-5f93-4b6c-97d2-739267b1f297	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW 3 Series #46	This is a generated listing for car #46. Features premium interior and low mileage.	BMW	3 Series	2015	93802	63217.00	excellent	automatic	hybrid	Black	VIN4655967	{https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg}	City 46	State	0101000020E61000003F9A967467F955C0C5F63706C0934540	active	f	484	2026-01-31 07:29:37.478184+00	2026-01-31 07:29:37.478184+00	2026-05-01 08:23:37.478184+00	f
2a822666-63c7-4adf-bc79-9b67b3ae02b0	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi F-150 #47	This is a generated listing for car #47. Features premium interior and low mileage.	Audi	F-150	2020	77561	25006.00	excellent	automatic	electric	Black	VIN47927301	{https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg}	City 47	State	0101000020E610000018C838ED5EF452C0A3340AE65B104240	active	f	39	2026-01-31 07:30:37.478184+00	2026-01-31 07:30:37.478184+00	2026-05-01 08:23:37.478184+00	f
97730831-2ae8-43a4-9f00-51e98d895850	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla Civic #48	This is a generated listing for car #48. Features premium interior and low mileage.	Tesla	Civic	2016	65324	13409.00	excellent	automatic	electric	Blue	VIN48526801	{https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg}	City 48	State	0101000020E6100000CBB6C000E5EF4DC0EB2875958AA43F40	active	f	110	2026-01-31 07:31:37.478184+00	2026-01-31 07:31:37.478184+00	2026-05-01 08:23:37.478184+00	f
f1c75801-4112-4f66-bc6a-3c87ad73ab53	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan C-Class #49	This is a generated listing for car #49. Features premium interior and low mileage.	Nissan	C-Class	2015	89468	16267.00	excellent	automatic	diesel	Silver	VIN49386590	{https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg}	City 49	State	0101000020E61000005F1A2DAA0AA84AC084ED9091550B4640	active	f	491	2026-01-31 07:32:37.478184+00	2026-01-31 07:32:37.478184+00	2026-05-01 08:23:37.478184+00	f
9c3ab920-63ad-4db2-9d4e-dcfd697da2ee	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla Altima #50	This is a generated listing for car #50. Features premium interior and low mileage.	Tesla	Altima	2020	80923	22933.00	excellent	automatic	electric	Gray	VIN5073921	{https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg}	City 50	State	0101000020E61000009DE1EB0975AD54C0A67DFF2F14914540	active	f	492	2026-01-31 07:33:37.478184+00	2026-01-31 07:33:37.478184+00	2026-05-01 08:23:37.478184+00	f
17621eda-a025-4e30-bd18-33fe591089ec	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Civic #51	This is a generated listing for car #51. Features premium interior and low mileage.	Toyota	Civic	2018	92720	71705.00	excellent	automatic	electric	Black	VIN51264465	{https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg}	City 51	State	0101000020E6100000F00ED0EA74CD4FC01025A5C3F73F4740	active	f	413	2026-01-31 07:34:37.478184+00	2026-01-31 07:34:37.478184+00	2026-05-01 08:23:37.478184+00	f
f4f8ac18-de23-4131-9067-d7ebbd21e45f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan Altima #52	This is a generated listing for car #52. Features premium interior and low mileage.	Nissan	Altima	2021	94146	26386.00	excellent	automatic	electric	Green	VIN5278989	{https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png}	City 52	State	0101000020E6100000A4F425F36D2254C045511E5A17634140	active	f	140	2026-01-31 07:35:37.478184+00	2026-01-31 07:35:37.478184+00	2026-05-01 08:23:37.478184+00	f
df16e0da-fd0c-41f3-b7a7-f2131c4de458	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi Civic #53	This is a generated listing for car #53. Features premium interior and low mileage.	Audi	Civic	2017	29220	22891.00	excellent	automatic	petrol	Black	VIN53998248	{https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg}	City 53	State	0101000020E61000002424B61947A651C061243028E56D4740	active	f	321	2026-01-31 07:36:37.478184+00	2026-01-31 07:36:37.478184+00	2026-05-01 08:23:37.478184+00	f
796dc3ea-c011-4dc2-898c-da0be79b98b9	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Civic #54	This is a generated listing for car #54. Features premium interior and low mileage.	Mercedes	Civic	2023	62298	55499.00	excellent	automatic	diesel	Green	VIN54467333	{https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg}	City 54	State	0101000020E6100000EA34671EC1674AC0146888A63BAF4440	active	f	320	2026-01-31 07:37:37.478184+00	2026-01-31 07:37:37.478184+00	2026-05-01 08:23:37.478184+00	f
3cb624a0-5041-48f7-810d-b06aa9f85b06	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan Altima #55	This is a generated listing for car #55. Features premium interior and low mileage.	Nissan	Altima	2019	50692	38354.00	excellent	automatic	hybrid	Green	VIN55594143	{https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg}	City 55	State	0101000020E6100000F55BB717092B51C084C54E43199C4740	active	f	243	2026-01-31 07:38:37.478184+00	2026-01-31 07:38:37.478184+00	2026-05-01 08:23:37.478184+00	f
1b6276c2-aa5b-4bef-85ef-0be691951a03	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi 3 Series #56	This is a generated listing for car #56. Features premium interior and low mileage.	Audi	3 Series	2024	82894	35204.00	excellent	automatic	hybrid	Silver	VIN56283010	{https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg}	City 56	State	0101000020E6100000C9965A850AEC4AC0905DCD934C5D4840	active	f	156	2026-01-31 07:39:37.478184+00	2026-01-31 07:39:37.478184+00	2026-05-01 08:23:37.478184+00	f
da182b12-4820-4043-b150-75a1f27ed0bb	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes F-150 #57	This is a generated listing for car #57. Features premium interior and low mileage.	Mercedes	F-150	2016	7148	90780.00	excellent	automatic	diesel	White	VIN57467140	{https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg}	City 57	State	0101000020E610000057E3403399F74EC04606C140F13C4740	active	f	289	2026-01-31 07:40:37.478184+00	2026-01-31 07:40:37.478184+00	2026-05-01 08:23:37.478184+00	f
5f441d04-3c96-480c-a40e-1451e8b78114	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Camry #58	This is a generated listing for car #58. Features premium interior and low mileage.	Toyota	Camry	2019	99126	49556.00	excellent	automatic	diesel	Black	VIN58821332	{https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg}	City 58	State	0101000020E6100000A20AA7C65F2254C0FB75B0D5D01F4340	active	f	95	2026-01-31 07:41:37.478184+00	2026-01-31 07:41:37.478184+00	2026-05-01 08:23:37.478184+00	f
68b68466-3756-47fb-9f50-7bfa2631cf89	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda F-150 #59	This is a generated listing for car #59. Features premium interior and low mileage.	Honda	F-150	2022	26013	74802.00	excellent	automatic	electric	Blue	VIN59394505	{https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg}	City 59	State	0101000020E6100000BA60066468794AC0D3C55C4B53474740	active	f	210	2026-01-31 07:42:37.478184+00	2026-01-31 07:42:37.478184+00	2026-05-01 08:23:37.478184+00	f
2e0d53b3-4d94-4224-9828-f6c9f367f341	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi F-150 #60	This is a generated listing for car #60. Features premium interior and low mileage.	Audi	F-150	2023	51655	72707.00	excellent	automatic	diesel	Blue	VIN60267272	{https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg}	City 60	State	0101000020E6100000BEE390673F8D51C0BC4972AF2EC34540	active	f	106	2026-01-31 07:43:37.478184+00	2026-01-31 07:43:37.478184+00	2026-05-01 08:23:37.478184+00	f
8df5a722-7cc1-4c6c-b0a1-6fe0857b8442	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai Altima #61	This is a generated listing for car #61. Features premium interior and low mileage.	Hyundai	Altima	2017	65333	98665.00	excellent	automatic	diesel	Gray	VIN6177448	{https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg}	City 61	State	0101000020E610000004F5430A2D1052C0996904674D754740	active	f	410	2026-01-31 07:44:37.478184+00	2026-01-31 07:44:37.478184+00	2026-05-01 08:23:37.478184+00	f
12704a37-b8ee-4d09-96ff-6237a849e049	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan F-150 #62	This is a generated listing for car #62. Features premium interior and low mileage.	Nissan	F-150	2023	4558	11728.00	excellent	automatic	diesel	Blue	VIN62707599	{https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg}	City 62	State	0101000020E610000006EFD4C990FB55C0EED8C974B2834540	active	f	227	2026-01-31 07:45:37.478184+00	2026-01-31 07:45:37.478184+00	2026-05-01 08:23:37.478184+00	f
f5ab1298-2dd7-4857-9c21-f5e053aab0dc	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Elantra #64	This is a generated listing for car #64. Features premium interior and low mileage.	Toyota	Elantra	2015	3257	32328.00	excellent	automatic	diesel	Black	VIN64410697	{https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg}	City 64	State	0101000020E61000000691029803E949C023EF7A96A99C4840	active	f	278	2026-01-31 07:47:37.478184+00	2026-01-31 07:47:37.478184+00	2026-05-01 08:23:37.478184+00	f
5bb30b3d-5464-4759-b038-a7f0d42d8099	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW 3 Series #65	This is a generated listing for car #65. Features premium interior and low mileage.	BMW	3 Series	2017	57622	39626.00	excellent	automatic	petrol	Silver	VIN6535889	{https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg}	City 65	State	0101000020E6100000C096AB3E2B0351C0ED1097F401793F40	active	f	437	2026-01-31 07:48:37.478184+00	2026-01-31 07:48:37.478184+00	2026-05-01 08:23:37.478184+00	f
1ca3c4cd-3fc8-4c2b-83ee-8089e8fd5605	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan Camry #66	This is a generated listing for car #66. Features premium interior and low mileage.	Nissan	Camry	2017	81857	45120.00	excellent	automatic	petrol	Silver	VIN66762761	{https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg}	City 66	State	0101000020E6100000C7685DE705B152C0AF88AA73A6094040	active	f	210	2026-01-31 07:49:37.478184+00	2026-01-31 07:49:37.478184+00	2026-05-01 08:23:37.478184+00	f
d5fa3aa7-a0c7-4518-8ea4-e2d8c7680fd0	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai F-150 #67	This is a generated listing for car #67. Features premium interior and low mileage.	Hyundai	F-150	2019	73569	65371.00	excellent	automatic	petrol	Red	VIN67466741	{https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg}	City 67	State	0101000020E6100000C0EB75E5DCF752C0F664C7B258564740	active	f	200	2026-01-31 07:50:37.478184+00	2026-01-31 07:50:37.478184+00	2026-05-01 08:23:37.478184+00	f
daecce8f-63d5-4b85-a0e4-dd8be30e9ada	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Ford C-Class #68	This is a generated listing for car #68. Features premium interior and low mileage.	Ford	C-Class	2020	30951	35990.00	excellent	automatic	hybrid	Black	VIN68151858	{https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg}	City 68	State	0101000020E6100000C743571353DF55C043D26745BD154340	active	f	467	2026-01-31 07:51:37.478184+00	2026-01-31 07:51:37.478184+00	2026-05-01 08:23:37.478184+00	f
aa23da72-898a-4d8e-9db4-56b2258f5a0d	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai 3 Series #69	This is a generated listing for car #69. Features premium interior and low mileage.	Hyundai	3 Series	2019	39116	96862.00	excellent	automatic	hybrid	Black	VIN69461158	{https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg}	City 69	State	0101000020E61000003880543412C449C07C2625A6457B4840	active	f	13	2026-01-31 07:52:37.478184+00	2026-01-31 07:52:37.478184+00	2026-05-01 08:23:37.478184+00	f
407432fe-ab4e-4f17-9869-ffabd2d4a3d7	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Civic #70	This is a generated listing for car #70. Features premium interior and low mileage.	Mercedes	Civic	2022	2566	31521.00	excellent	automatic	hybrid	Silver	VIN70492392	{https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg}	City 70	State	0101000020E6100000981FC08593A653C04CB2525AFB314040	active	f	305	2026-01-31 07:53:37.478184+00	2026-01-31 07:53:37.478184+00	2026-05-01 08:23:37.478184+00	f
629d6874-c66b-4e6c-9035-55adaeb7c71a	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW Camry #71	This is a generated listing for car #71. Features premium interior and low mileage.	BMW	Camry	2018	31570	21741.00	excellent	automatic	petrol	Black	VIN71409155	{https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png}	City 71	State	0101000020E61000005A454C2093914AC0A59C9F5E620B4040	active	f	356	2026-01-31 07:54:37.478184+00	2026-01-31 07:54:37.478184+00	2026-05-01 08:23:37.478184+00	f
c48f1874-facd-4f98-92cb-ac2d027ee242	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Civic #72	This is a generated listing for car #72. Features premium interior and low mileage.	Mercedes	Civic	2021	35770	22854.00	excellent	automatic	petrol	Gray	VIN72490546	{https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg}	City 72	State	0101000020E6100000AEC5E028ACA44BC0B8CE6A62BE064040	active	f	27	2026-01-31 07:55:37.478184+00	2026-01-31 07:55:37.478184+00	2026-05-01 08:23:37.478184+00	f
b044c31b-0d01-4863-b733-68b378f5f0fd	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota F-150 #73	This is a generated listing for car #73. Features premium interior and low mileage.	Toyota	F-150	2019	92243	35562.00	excellent	automatic	electric	Black	VIN73849842	{https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg}	City 73	State	0101000020E6100000651ADAEB0C124FC0FA7256469DED3E40	active	f	283	2026-01-31 07:56:37.478184+00	2026-01-31 07:56:37.478184+00	2026-05-01 08:23:37.478184+00	f
70b8b3b9-8b43-40ba-8803-a7faa8765424	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Silverado #74	This is a generated listing for car #74. Features premium interior and low mileage.	Mercedes	Silverado	2016	16222	52254.00	excellent	automatic	petrol	Blue	VIN74143086	{https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg}	City 74	State	0101000020E610000086AA3B452B4352C0F2C4FFC4C7EF4440	active	f	65	2026-01-31 07:57:37.478184+00	2026-01-31 07:57:37.478184+00	2026-05-01 08:23:37.478184+00	f
1081d5f3-6d52-463e-9830-5d12c36c15a5	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW Camry #75	This is a generated listing for car #75. Features premium interior and low mileage.	BMW	Camry	2018	53705	36145.00	excellent	automatic	diesel	Blue	VIN75941785	{https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg}	City 75	State	0101000020E6100000BD8D04D8882956C08222D69B82EB3E40	active	f	452	2026-01-31 07:58:37.478184+00	2026-01-31 07:58:37.478184+00	2026-05-01 08:23:37.478184+00	f
adb145cc-f98b-4141-889e-962260499670	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai Model 3 #76	This is a generated listing for car #76. Features premium interior and low mileage.	Hyundai	Model 3	2024	81127	16854.00	excellent	automatic	petrol	Black	VIN76336291	{https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg}	City 76	State	0101000020E610000084DFB082359A51C0403F608A6E074840	active	f	410	2026-01-31 07:59:37.478184+00	2026-01-31 07:59:37.478184+00	2026-05-01 08:23:37.478184+00	f
ed330617-2365-4618-817c-bab670f954fd	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Altima #77	This is a generated listing for car #77. Features premium interior and low mileage.	Toyota	Altima	2021	55496	33560.00	excellent	automatic	electric	Black	VIN77987375	{https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg}	City 77	State	0101000020E61000004634160098BD51C00AFA3E5835274040	active	f	273	2026-01-31 08:00:37.478184+00	2026-01-31 08:00:37.478184+00	2026-05-01 08:23:37.478184+00	f
b2cac451-7596-4b9b-84b8-5ce8dba1c87a	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi Civic #78	This is a generated listing for car #78. Features premium interior and low mileage.	Audi	Civic	2022	44354	22283.00	excellent	automatic	hybrid	Blue	VIN78157169	{https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg}	City 78	State	0101000020E6100000086F0919A9A64BC064D518207EDE4440	active	f	32	2026-01-31 08:01:37.478184+00	2026-01-31 08:01:37.478184+00	2026-05-01 08:23:37.478184+00	f
6bf2fee3-3386-444e-a6b3-322df5a5be8a	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Silverado #79	This is a generated listing for car #79. Features premium interior and low mileage.	Mercedes	Silverado	2015	77218	42530.00	excellent	automatic	hybrid	Green	VIN79924390	{https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg}	City 79	State	0101000020E6100000E6DB5F64A9E651C0F0F065D61C9A3F40	active	f	426	2026-01-31 08:02:37.478184+00	2026-01-31 08:02:37.478184+00	2026-05-01 08:23:37.478184+00	f
dfcc73e8-0562-4671-b39e-321e6afd90b1	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla 3 Series #80	This is a generated listing for car #80. Features premium interior and low mileage.	Tesla	3 Series	2015	5770	46796.00	excellent	automatic	petrol	Black	VIN80814515	{https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg}	City 80	State	0101000020E610000012E294FCE9FF55C0ED7A1FE7259E4040	active	f	42	2026-01-31 08:03:37.478184+00	2026-01-31 08:03:37.478184+00	2026-05-01 08:23:37.478184+00	f
5b3fbdca-de81-477e-b321-06e67b6c8a99	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Honda C-Class #90	This is a generated listing for car #90. Features premium interior and low mileage.	Honda	C-Class	2015	42747	19986.00	excellent	automatic	hybrid	Gray	VIN90993935	{https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png}	City 90	State	0101000020E6100000A78845046A3250C0D6B93BFD21DE3F40	active	f	354	2026-01-31 08:13:37.478184+00	2026-01-31 08:13:37.478184+00	2026-05-01 08:23:37.478184+00	f
e35974a2-2f86-4a70-b22b-da48dbb6ddf9	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Camry #81	This is a generated listing for car #81. Features premium interior and low mileage.	Mercedes	Camry	2018	50322	18073.00	excellent	automatic	petrol	Red	VIN81607907	{https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg}	City 81	State	0101000020E6100000EB5225F26D1B52C052D9694B13AA4340	active	f	491	2026-01-31 08:04:37.478184+00	2026-01-31 08:04:37.478184+00	2026-05-01 08:23:37.478184+00	f
ff30a810-f61c-416e-8534-9c69ea201143	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai Camry #82	This is a generated listing for car #82. Features premium interior and low mileage.	Hyundai	Camry	2016	95156	11334.00	excellent	automatic	electric	Black	VIN82828937	{https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg}	City 82	State	0101000020E6100000AB9A3EBDC7CE51C0ADEFF0B5E40E4340	active	t	169	2026-01-31 08:05:37.478184+00	2026-01-31 08:05:37.478184+00	2026-05-01 08:23:37.478184+00	f
65237afa-7489-4275-a17a-2096abff34a4	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Model 3 #83	This is a generated listing for car #83. Features premium interior and low mileage.	Toyota	Model 3	2017	51932	52365.00	excellent	automatic	diesel	Green	VIN83416509	{https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg}	City 83	State	0101000020E6100000B8E34E81B79849C0856D001B13B74840	active	f	339	2026-01-31 08:06:37.478184+00	2026-01-31 08:06:37.478184+00	2026-05-01 08:23:37.478184+00	f
21b81aa2-9cd5-4da5-8e47-a63dd5fca898	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet Civic #84	This is a generated listing for car #84. Features premium interior and low mileage.	Chevrolet	Civic	2016	97419	87036.00	excellent	automatic	diesel	Silver	VIN84364487	{https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg}	City 84	State	0101000020E61000004C02A06776AE51C0863C33D045AD4240	active	f	177	2026-01-31 08:07:37.478184+00	2026-01-31 08:07:37.478184+00	2026-05-01 08:23:37.478184+00	f
153bb092-ab8a-4bdd-9e90-449a659c247a	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla Silverado #85	This is a generated listing for car #85. Features premium interior and low mileage.	Tesla	Silverado	2021	68313	62020.00	excellent	automatic	electric	Gray	VIN85714565	{https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg}	City 85	State	0101000020E6100000872C300339194DC0FA2F51EE7E7A4240	active	f	214	2026-01-31 08:08:37.478184+00	2026-01-31 08:08:37.478184+00	2026-05-01 08:23:37.478184+00	f
cc934b12-cc42-4584-9100-9397149e607f	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Altima #86	This is a generated listing for car #86. Features premium interior and low mileage.	Mercedes	Altima	2024	91822	56275.00	excellent	automatic	electric	Black	VIN86386140	{https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg}	City 86	State	0101000020E6100000603C10E291D349C069FD6A6BF6FE4240	active	f	35	2026-01-31 08:09:37.478184+00	2026-01-31 08:09:37.478184+00	2026-05-01 08:23:37.478184+00	f
ef2d9c65-0f6c-40da-9983-368d8ef29083	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Hyundai Altima #87	This is a generated listing for car #87. Features premium interior and low mileage.	Hyundai	Altima	2018	59182	62957.00	excellent	automatic	hybrid	Silver	VIN87372106	{https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg}	City 87	State	0101000020E6100000C7509498A7A753C02A5C2AF533034740	active	f	57	2026-01-31 08:10:37.478184+00	2026-01-31 08:10:37.478184+00	2026-05-01 08:23:37.478184+00	f
1fc19b4b-ae84-4fb7-a9f2-4e50134eb5a3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW A4 #88	This is a generated listing for car #88. Features premium interior and low mileage.	BMW	A4	2020	63017	77170.00	excellent	automatic	petrol	Red	VIN88888525	{https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg,https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg}	City 88	State	0101000020E6100000EECCF7B865AB52C0240E9E1A7C504240	active	t	330	2026-01-31 08:11:37.478184+00	2026-01-31 08:11:37.478184+00	2026-05-01 08:23:37.478184+00	f
fd398353-aed4-4b8b-87ae-5df69817c4d3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi Model 3 #89	This is a generated listing for car #89. Features premium interior and low mileage.	Audi	Model 3	2017	91439	36166.00	excellent	automatic	hybrid	White	VIN89141511	{https://images.pexels.com/photos/13555064/pexels-photo-13555064.jpeg,https://images.pexels.com/photos/27849359/pexels-photo-27849359.jpeg,https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg}	City 89	State	0101000020E6100000A6A3F282BAF755C01E2AA6B0BCCA4840	active	f	209	2026-01-31 08:12:37.478184+00	2026-01-31 08:12:37.478184+00	2026-05-01 08:23:37.478184+00	f
28e40a60-92c7-4ab6-9c51-3ce483ffa0c3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet Model 3 #91	This is a generated listing for car #91. Features premium interior and low mileage.	Chevrolet	Model 3	2021	34294	49167.00	excellent	automatic	electric	Silver	VIN91871199	{https://images.pexels.com/photos/217330/pexels-photo-217330.jpeg,https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg}	City 91	State	0101000020E61000006E30D3D0F17B51C0AACDFD34A0E94140	active	f	232	2026-01-31 08:14:37.478184+00	2026-01-31 08:14:37.478184+00	2026-05-01 08:23:37.478184+00	f
8d1bad67-1683-40d5-b5b4-1e87a137acf6	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Ford Altima #92	This is a generated listing for car #92. Features premium interior and low mileage.	Ford	Altima	2023	73053	13106.00	excellent	automatic	hybrid	Silver	VIN92548941	{https://images.pexels.com/photos/13555123/pexels-photo-13555123.jpeg,https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg}	City 92	State	0101000020E610000007955766DADE55C050ACD199CD624340	active	f	323	2026-01-31 08:15:37.478184+00	2026-01-31 08:15:37.478184+00	2026-05-01 08:23:37.478184+00	f
1683614e-83ed-436a-a81e-cdfa1302e3bf	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Nissan Model 3 #93	This is a generated listing for car #93. Features premium interior and low mileage.	Nissan	Model 3	2018	96340	70841.00	excellent	automatic	hybrid	Green	VIN93838748	{https://images.pexels.com/photos/14807980/pexels-photo-14807980.jpeg,https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg}	City 93	State	0101000020E6100000F624E13DB3844EC0FFC7CFAC062E4740	active	f	351	2026-01-31 08:16:37.478184+00	2026-01-31 08:16:37.478184+00	2026-05-01 08:23:37.478184+00	f
58026ef7-b56d-40da-b151-6fb2b80463fc	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota F-150 #94	This is a generated listing for car #94. Features premium interior and low mileage.	Toyota	F-150	2023	98700	65859.00	excellent	automatic	electric	Red	VIN94317230	{https://images.pexels.com/photos/13555288/pexels-photo-13555288.jpeg,https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg}	City 94	State	0101000020E6100000266E07B73BE54FC01653FC646D324640	active	f	14	2026-01-31 08:17:37.478184+00	2026-01-31 08:17:37.478184+00	2026-05-01 08:23:37.478184+00	f
6929263e-7425-4e5f-b0a5-339fdccd8d76	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Tesla A4 #95	This is a generated listing for car #95. Features premium interior and low mileage.	Tesla	A4	2018	11279	36702.00	excellent	automatic	hybrid	Green	VIN95457861	{https://images.pexels.com/photos/34071036/pexels-photo-34071036.jpeg,https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg}	City 95	State	0101000020E610000053994E2B4CF055C0E6A38641B7754840	active	f	334	2026-01-31 08:18:37.478184+00	2026-01-31 08:18:37.478184+00	2026-05-01 08:23:37.478184+00	f
5caf1897-a8fe-4e28-872f-32ed28f7fdc2	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Toyota Altima #96	This is a generated listing for car #96. Features premium interior and low mileage.	Toyota	Altima	2021	84420	30127.00	excellent	automatic	hybrid	White	VIN96737133	{https://images.pexels.com/photos/27243718/pexels-photo-27243718.jpeg,https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg}	City 96	State	0101000020E61000004A2B93DAAFCA51C0D056509A577A4340	active	f	309	2026-01-31 08:19:37.478184+00	2026-01-31 08:19:37.478184+00	2026-05-01 08:23:37.478184+00	f
355ac32b-45c3-4a7d-b29f-a65d65fac078	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	BMW C-Class #97	This is a generated listing for car #97. Features premium interior and low mileage.	BMW	C-Class	2022	8071	66170.00	excellent	automatic	diesel	White	VIN97765873	{https://images.pexels.com/photos/18382225/pexels-photo-18382225.png,https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg}	City 97	State	0101000020E6100000F6AC96401C3C51C0183E233588CA4540	active	f	205	2026-01-31 08:20:37.478184+00	2026-01-31 08:20:37.478184+00	2026-05-01 08:23:37.478184+00	f
b2a438b9-81b3-4a47-b70b-23f8357199ee	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Mercedes Silverado #98	This is a generated listing for car #98. Features premium interior and low mileage.	Mercedes	Silverado	2018	63999	90067.00	excellent	automatic	petrol	Silver	VIN98177455	{https://images.pexels.com/photos/13575248/pexels-photo-13575248.jpeg,https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg}	City 98	State	0101000020E610000015D10AB219D754C045A63A93BF134740	active	f	436	2026-01-31 08:21:37.478184+00	2026-01-31 08:21:37.478184+00	2026-05-01 08:23:37.478184+00	f
4a4d053a-b76c-4cc5-9265-f6eda75fc796	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Audi Model 3 #99	This is a generated listing for car #99. Features premium interior and low mileage.	Audi	Model 3	2020	30098	94747.00	excellent	automatic	hybrid	Black	VIN9981323	{https://images.pexels.com/photos/13446947/pexels-photo-13446947.jpeg,https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg}	City 99	State	0101000020E610000084BE36BB261750C05BAA794AD5AD4340	active	t	182	2026-01-31 08:22:37.478184+00	2026-01-31 08:22:37.478184+00	2026-05-01 08:23:37.478184+00	f
aa8d09c8-2593-40ca-ada5-a1c1c061e7b3	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	Chevrolet Camry #100	This is a generated listing for car #100. Features premium interior and low mileage.	Chevrolet	Camry	2022	50866	42694.00	excellent	automatic	hybrid	Black	VIN100885078	{https://images.pexels.com/photos/13248976/pexels-photo-13248976.jpeg,https://images.pexels.com/photos/13555063/pexels-photo-13555063.jpeg,https://images.pexels.com/photos/13554945/pexels-photo-13554945.jpeg,https://images.pexels.com/photos/13498965/pexels-photo-13498965.jpeg,https://images.pexels.com/photos/13575292/pexels-photo-13575292.jpeg,https://images.pexels.com/photos/13446948/pexels-photo-13446948.jpeg,https://images.pexels.com/photos/13554821/pexels-photo-13554821.jpeg,https://images.pexels.com/photos/34071079/pexels-photo-34071079.jpeg}	City 100	State	0101000020E61000001333A741D1774FC0A54C005A78294140	active	f	276	2026-01-31 08:23:37.478184+00	2026-01-31 08:23:37.478184+00	2026-05-01 08:23:37.478184+00	f
\.


--
-- Data for Name: conversation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversation_participants (conversation_id, user_id, last_read_message_id, joined_at, unread_count) FROM stdin;
c1c961e3-3aa2-43ba-b0e7-54ac971294a8	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	0001-01-01 00:00:00+00	2
c1c961e3-3aa2-43ba-b0e7-54ac971294a8	952e2667-83cc-4f4a-bc15-a8ea089edee1	\N	0001-01-01 00:00:00+00	0
dbb1c55d-6943-46c6-9453-b7cab2acbe66	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	0001-01-01 00:00:00+00	3
dbb1c55d-6943-46c6-9453-b7cab2acbe66	952e2667-83cc-4f4a-bc15-a8ea089edee1	\N	0001-01-01 00:00:00+00	0
049bf01b-0da7-4b2d-a5e5-a20b22db9000	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	\N	0001-01-01 00:00:00+00	1
049bf01b-0da7-4b2d-a5e5-a20b22db9000	952e2667-83cc-4f4a-bc15-a8ea089edee1	\N	0001-01-01 00:00:00+00	0
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversations (id, created_at, updated_at, metadata, car_id, car_title, car_seller_id, last_message_at) FROM stdin;
c1c961e3-3aa2-43ba-b0e7-54ac971294a8	2026-02-08 17:07:20.998542+00	2026-02-08 18:59:52.407014+00	\N	355ac32b-45c3-4a7d-b29f-a65d65fac078	BMW C-Class #97	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-02-08 18:59:52.406904+00
dbb1c55d-6943-46c6-9453-b7cab2acbe66	2026-02-08 16:39:48.154701+00	2026-02-08 19:00:08.17682+00	\N	4a4d053a-b76c-4cc5-9265-f6eda75fc796	Audi Model 3 #99	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-02-08 19:00:08.176398+00
049bf01b-0da7-4b2d-a5e5-a20b22db9000	2026-02-08 19:01:43.347866+00	2026-02-08 19:01:43.376791+00	\N	5caf1897-a8fe-4e28-872f-32ed28f7fdc2	Toyota Altima #96	a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	2026-02-08 19:01:43.37669+00
\.


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.favorites (user_id, car_id, created_at) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.messages (id, conversation_id, sender_id, content, message_type, media_url, is_read, created_at, status, delivered_at, seen_at) FROM stdin;
50adbb67-1a8b-4b53-9cb3-8f2b7dbd6d93	dbb1c55d-6943-46c6-9453-b7cab2acbe66	952e2667-83cc-4f4a-bc15-a8ea089edee1	Gi	text	\N	f	2026-02-08 16:39:48.320264+00	sent	\N	\N
2f00296b-063b-4e85-b54d-7a3da9ad25a4	c1c961e3-3aa2-43ba-b0e7-54ac971294a8	952e2667-83cc-4f4a-bc15-a8ea089edee1	Is it possible in 10?	text	\N	f	2026-02-08 17:07:21.156868+00	sent	\N	\N
075c4008-58fa-4233-8374-2ab2c421b882	dbb1c55d-6943-46c6-9453-b7cab2acbe66	952e2667-83cc-4f4a-bc15-a8ea089edee1	Hello	text	\N	f	2026-02-08 17:07:42.90259+00	sent	\N	\N
b943b61e-6e67-466d-b367-05fdb9b89c95	c1c961e3-3aa2-43ba-b0e7-54ac971294a8	952e2667-83cc-4f4a-bc15-a8ea089edee1	Hii	text	\N	f	2026-02-08 18:59:52.406904+00	sent	\N	\N
66369081-7068-41e8-8a15-7439fb8e167e	dbb1c55d-6943-46c6-9453-b7cab2acbe66	952e2667-83cc-4f4a-bc15-a8ea089edee1	Hiiii	text	\N	f	2026-02-08 19:00:08.176398+00	sent	\N	\N
ad635a40-555b-47e3-9ace-128737522aa5	049bf01b-0da7-4b2d-a5e5-a20b22db9000	952e2667-83cc-4f4a-bc15-a8ea089edee1	Hello	text	\N	f	2026-02-08 19:01:43.37669+00	sent	\N	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version) FROM stdin;
003_make_fields_optional.sql
004_add_chat_only_column.sql
005_create_chat_tables.sql
006_add_conversation_metadata.sql
007_add_car_context_to_conversations.sql
008_add_message_status.sql
009_complete_schema_sync.sql
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: user_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_devices (id, user_id, fcm_token, device_type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, phone, password_hash, full_name, profile_photo_url, is_verified, is_dealer, is_active, created_at, updated_at, last_login_at, gender, dob) FROM stdin;
a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11	dummy_seller@example.com	+15550001111	hash_placeholder	Premium Auto Sales	\N	t	f	t	2025-12-31 10:08:33.354888	2025-12-31 10:08:33.354888	\N	\N	\N
42932313-d4f3-4271-ab95-304c8615a958	nahid@gmail.com	+94646866464949	$2a$12$BtO8hXEN5uxYvr3PVvIoVO9VpOvfv6nbdr11G92ys3frCH6qZoorO	nahid	\N	t	f	t	2025-12-30 15:33:09.944944	2025-12-31 19:59:38.849393	2025-12-31 19:59:38.849164	\N	\N
952e2667-83cc-4f4a-bc15-a8ea089edee1	user@example.com	+1234567890	$2a$12$JoV5wmS6222fmRiCRR4kxufjp1PANNAGWUspzb9Yu1lPunuOlyDXe	John Doe	\N	t	f	t	2025-12-30 15:26:27.649748	2026-02-08 16:37:41.499304	2026-02-08 16:37:41.491733	\N	\N
\.


--
-- Data for Name: verification_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.verification_codes (id, phone, code, attempts, is_verified, created_at, expires_at) FROM stdin;
\.


--
-- Name: car_views car_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car_views
    ADD CONSTRAINT car_views_pkey PRIMARY KEY (id);


--
-- Name: cars cars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_pkey PRIMARY KEY (id);


--
-- Name: conversation_participants conversation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_pkey PRIMARY KEY (conversation_id, user_id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (user_id, car_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: user_devices user_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_pkey PRIMARY KEY (id);


--
-- Name: user_devices user_devices_user_id_fcm_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_user_id_fcm_token_key UNIQUE (user_id, fcm_token);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verification_codes verification_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verification_codes
    ADD CONSTRAINT verification_codes_pkey PRIMARY KEY (id);


--
-- Name: idx_car_views_car_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_car_views_car_id ON public.car_views USING btree (car_id);


--
-- Name: idx_cars_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_created_at ON public.cars USING btree (created_at);


--
-- Name: idx_cars_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_location ON public.cars USING gist (coordinates);


--
-- Name: idx_cars_make_model; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_make_model ON public.cars USING btree (make, model);


--
-- Name: idx_cars_price; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_price ON public.cars USING btree (price);


--
-- Name: idx_cars_seller; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_seller ON public.cars USING btree (seller_id);


--
-- Name: idx_cars_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_status ON public.cars USING btree (status);


--
-- Name: idx_cars_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cars_year ON public.cars USING btree (year);


--
-- Name: idx_conversation_participants_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_participants_unread ON public.conversation_participants USING btree (user_id, unread_count);


--
-- Name: idx_conversation_participants_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversation_participants_user_id ON public.conversation_participants USING btree (user_id);


--
-- Name: idx_conversations_car_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversations_car_id ON public.conversations USING btree (car_id);


--
-- Name: idx_conversations_car_seller_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversations_car_seller_id ON public.conversations USING btree (car_seller_id);


--
-- Name: idx_conversations_last_message_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_conversations_last_message_at ON public.conversations USING btree (last_message_at DESC);


--
-- Name: idx_messages_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_conversation_id ON public.messages USING btree (conversation_id);


--
-- Name: idx_messages_conversation_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_conversation_status ON public.messages USING btree (conversation_id, status);


--
-- Name: idx_messages_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_created_at ON public.messages USING btree (created_at);


--
-- Name: idx_messages_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_sender_id ON public.messages USING btree (sender_id);


--
-- Name: idx_messages_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_messages_status ON public.messages USING btree (status);


--
-- Name: idx_user_devices_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_devices_user_id ON public.user_devices USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_is_active ON public.users USING btree (is_active);


--
-- Name: idx_users_is_verified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_is_verified ON public.users USING btree (is_verified);


--
-- Name: idx_users_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_phone ON public.users USING btree (phone);


--
-- Name: idx_verification_codes_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_verification_codes_expires_at ON public.verification_codes USING btree (expires_at);


--
-- Name: idx_verification_codes_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_verification_codes_phone ON public.verification_codes USING btree (phone);


--
-- Name: conversations update_conversations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: user_devices update_user_devices_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_user_devices_updated_at BEFORE UPDATE ON public.user_devices FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: car_views car_views_car_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car_views
    ADD CONSTRAINT car_views_car_id_fkey FOREIGN KEY (car_id) REFERENCES public.cars(id) ON DELETE CASCADE;


--
-- Name: car_views car_views_viewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.car_views
    ADD CONSTRAINT car_views_viewer_id_fkey FOREIGN KEY (viewer_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: cars cars_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cars
    ADD CONSTRAINT cars_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: conversation_participants conversation_participants_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: conversation_participants conversation_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversation_participants
    ADD CONSTRAINT conversation_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_car_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_car_id_fkey FOREIGN KEY (car_id) REFERENCES public.cars(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_devices user_devices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_devices
    ADD CONSTRAINT user_devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict gIQEO99e0YycejhjByn5IGSfLjhTRrdghmOhkrpSBqvAq1y51w36UcllnBUNH1u

