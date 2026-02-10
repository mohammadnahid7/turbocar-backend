--
-- PostgreSQL database dump
--

\restrict HNc9yTwyFc6uwuG9y9SakUcAjW3uqdXEAuFYEo92aYASwxmxdDh98EetgppL2cw

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
    status public.car_status DEFAULT 'active'::public.car_status NOT NULL,
    is_featured boolean DEFAULT false,
    views_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone,
    chat_only boolean DEFAULT false,
    latitude double precision,
    longitude double precision,
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

COPY public.cars (id, seller_id, title, description, make, model, year, mileage, price, condition, transmission, fuel_type, color, vin, images, city, state, status, is_featured, views_count, created_at, updated_at, expires_at, chat_only, latitude, longitude) FROM stdin;
837ec8a2-6990-422b-92be-2cc9bb71206b	eeca92f2-ebfe-43b1-945e-a57ce93ae845	Chevrolet New Car 2022	This is my new car, please contact me. This is the edit	Chevrolet	Sedan New Car	2022	4643758	123111.00	good	automatic	electric			{https://pub-25cab28550e14f6c9169356728977f1b.r2.dev/cars/837ec8a2-6990-422b-92be-2cc9bb71206b/1-1770529653743287817.jpg,https://pub-25cab28550e14f6c9169356728977f1b.r2.dev/cars/837ec8a2-6990-422b-92be-2cc9bb71206b/2-1770529654109170901.jpg}	Busan		active	f	11	2026-02-08 05:47:34.42236+00	2026-02-09 13:24:43.457853+00	2026-05-09 05:47:34.42236+00	f	\N	\N
\.


--
-- Data for Name: conversation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversation_participants (conversation_id, user_id, last_read_message_id, joined_at, unread_count) FROM stdin;
2eeae823-87fd-4502-a7da-bd111611dc42	eeca92f2-ebfe-43b1-945e-a57ce93ae845	\N	0001-01-01 00:00:00+00	1
2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	\N	0001-01-01 00:00:00+00	0
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversations (id, created_at, updated_at, metadata, car_id, car_title, car_seller_id, last_message_at) FROM stdin;
2eeae823-87fd-4502-a7da-bd111611dc42	2026-02-08 09:53:16.997679+00	2026-02-09 04:04:12.543013+00	\N	837ec8a2-6990-422b-92be-2cc9bb71206b	Chevrolet New Car 2022	eeca92f2-ebfe-43b1-945e-a57ce93ae845	2026-02-09 04:04:12.542685+00
\.


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.favorites (user_id, car_id, created_at) FROM stdin;
eeca92f2-ebfe-43b1-945e-a57ce93ae845	837ec8a2-6990-422b-92be-2cc9bb71206b	2026-02-09 12:04:05.658572+00
2fb65e4b-a424-41c7-a84d-6015c8c45ced	837ec8a2-6990-422b-92be-2cc9bb71206b	2026-02-09 13:24:26.570019+00
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.messages (id, conversation_id, sender_id, content, message_type, media_url, is_read, created_at, status, delivered_at, seen_at) FROM stdin;
e139836e-f8c3-4dd4-9f7a-16e95a5c1595	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	hii	text	\N	t	2026-02-08 09:53:17.055131+00	seen	\N	2026-02-08 09:53:22.119041+00
1ada3681-8b31-42ac-aabf-c1cb55485d59	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Hello bro	text	\N	t	2026-02-08 09:54:49.41347+00	seen	\N	2026-02-08 09:55:29.982692+00
71bc4108-9637-46fe-a2a4-623e96b1ec18	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Oo hello	text	\N	t	2026-02-08 09:55:07.155981+00	seen	\N	2026-02-08 09:55:29.982692+00
9bc3d06d-61cc-4b4e-a8b0-ed46382d568c	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Hi bro	text	\N	t	2026-02-08 09:55:22.841495+00	seen	\N	2026-02-08 09:55:29.982692+00
d878ec79-be20-499c-aa7b-31859345570b	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	hey	text	\N	t	2026-02-08 09:55:38.092109+00	seen	\N	2026-02-08 09:55:38.148935+00
76787160-bd08-4723-a1c7-d46d8d885a67	2eeae823-87fd-4502-a7da-bd111611dc42	eeca92f2-ebfe-43b1-945e-a57ce93ae845	Yoo	text	\N	t	2026-02-08 09:55:46.938829+00	seen	\N	2026-02-08 09:55:54.232478+00
2dd38022-88a3-4ad5-85dc-62375a080a54	2eeae823-87fd-4502-a7da-bd111611dc42	eeca92f2-ebfe-43b1-945e-a57ce93ae845	Bro	text	\N	t	2026-02-08 09:55:50.605677+00	seen	\N	2026-02-08 09:55:54.232478+00
a1d4d730-e9ea-4352-a631-936a8eaa7c5c	2eeae823-87fd-4502-a7da-bd111611dc42	eeca92f2-ebfe-43b1-945e-a57ce93ae845	Hii	text	\N	t	2026-02-08 09:56:01.282114+00	seen	\N	2026-02-08 09:59:23.512567+00
53054c78-fc47-4f07-bbf1-c7e8d7904549	2eeae823-87fd-4502-a7da-bd111611dc42	eeca92f2-ebfe-43b1-945e-a57ce93ae845	What bro?	text	\N	t	2026-02-08 09:56:05.336525+00	seen	\N	2026-02-08 09:59:23.512567+00
1bb4153f-daa5-4a11-92b1-14bfbc91dc1f	2eeae823-87fd-4502-a7da-bd111611dc42	eeca92f2-ebfe-43b1-945e-a57ce93ae845	Koi	text	\N	t	2026-02-08 10:04:13.720406+00	seen	\N	2026-02-08 10:05:04.21512+00
b085ffd7-9c05-461b-9db4-22b3ddfb5b38	2eeae823-87fd-4502-a7da-bd111611dc42	eeca92f2-ebfe-43b1-945e-a57ce93ae845	Vsbdbd	text	\N	t	2026-02-08 10:05:16.243776+00	seen	\N	2026-02-08 10:06:14.008516+00
4ccbfd94-1784-4da5-8106-8b138187dffa	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Hi	text	\N	t	2026-02-09 04:02:29.248483+00	seen	\N	2026-02-09 04:02:29.262488+00
bf437030-9b6f-4448-85fa-0cf3071fe128	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Bro	text	\N	t	2026-02-09 04:02:33.203392+00	seen	\N	2026-02-09 04:02:33.212632+00
85e889c9-0615-445b-b12d-200b5e7c0125	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	How are you	text	\N	t	2026-02-09 04:02:49.370633+00	seen	\N	2026-02-09 04:02:49.379402+00
ed01578d-dea3-4d52-9d1a-999dc595c5b7	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Hwy	text	\N	t	2026-02-09 04:03:08.96155+00	seen	\N	2026-02-09 04:03:08.970242+00
0098874b-04b6-487e-9ded-f78beb793452	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Bro	text	\N	t	2026-02-09 04:03:27.589549+00	seen	\N	2026-02-09 04:04:01.762525+00
730c8e26-364c-4cc8-aeb5-0743aaf37c33	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	How are you	text	\N	t	2026-02-09 04:03:32.837723+00	seen	\N	2026-02-09 04:04:01.762525+00
22bb2dd8-94b1-45a7-8541-27451d646e0d	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Are you fine?	text	\N	t	2026-02-09 04:03:47.895628+00	seen	\N	2026-02-09 04:04:01.762525+00
1c8f0e72-cc48-40a2-990a-202357700b1e	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Not fine?	text	\N	t	2026-02-09 04:03:56.344366+00	seen	\N	2026-02-09 04:04:01.762525+00
f1c64dc6-5da8-4d28-851b-a996d89a3080	2eeae823-87fd-4502-a7da-bd111611dc42	2fb65e4b-a424-41c7-a84d-6015c8c45ced	Hi	text	\N	f	2026-02-09 04:04:12.542685+00	sent	\N	\N
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
-- Data for Name: user_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_devices (id, user_id, fcm_token, device_type, created_at, updated_at) FROM stdin;
eedb706f-8d47-4523-b439-319704538895	2fb65e4b-a424-41c7-a84d-6015c8c45ced	f6_b0MRsSzOoaUPNDxlchd:APA91bFhYkG59Uxf3mB8okuhqO3y_H05-mkuflmW9ZtnIHl3Sw8FJsZ0WFiys1G3cuzIOAIJ6wIL9r6DZmsTCnMlYBcSiRIl2JL66UCLKqx0i3VkKKuSf9w	android	2026-02-09 04:41:37.409187+00	2026-02-09 04:41:37.409187+00
dc6f4532-b21a-4fb5-83fe-9ec08db09160	eeca92f2-ebfe-43b1-945e-a57ce93ae845	dhcNzqfyQEqqFB8Sldtd7r:APA91bGFz1haES9Y-gWRHRLB9HkYJez79KAE47N_DTuWN5YlkHl5MTg3-FDV6biChYeb1PG9q10ELpT-g0sEFKYkR06qGpyvvGTSAcaMrd4iMhrt53hdF00	android	2026-02-09 04:44:54.538562+00	2026-02-09 04:44:54.538562+00
3493c4d3-4690-4f6f-9994-ecd6b7486aae	eeca92f2-ebfe-43b1-945e-a57ce93ae845	ezTSGt0aSzW8n9P9qFgCyM:APA91bFzW-aEzrhWPi-QL4cyNT6Mo7HIc8Fece4kKOnKhoBn6HkMOem9WnKZ-bqNBk28ieyYIIic1FSKj77VBDHGAFY7wSAnRVM7OyXq2TWO2RB820Ns_Es	android	2026-02-09 11:53:58.161254+00	2026-02-09 11:53:58.161254+00
99a025ec-7096-4513-bf00-0615c5e45e7e	2fb65e4b-a424-41c7-a84d-6015c8c45ced	fYHq6Fa-S4m85luo1g1wLr:APA91bFWFxbeYiDT8NFpUq8j867wjN6iOkxrrQ2xl4-dh82a41y9w1EY80vB-vHg7aUpQsdyy3RO3cq7JJVUmWHgxjBy2LxJWqnDFe0_iK-D0c5DrASPAUQ	android	2026-02-09 11:57:00.923503+00	2026-02-09 11:57:00.923503+00
f4df7b2a-62f1-481c-9d0b-5335963a9688	2fb65e4b-a424-41c7-a84d-6015c8c45ced	fUy86aN5Tb2OMK8-wE0V0R:APA91bFVnHQuNIWdY3jj6qnckaEqf0FfVYU6wuMCZTeGk-j23qU5Wx2HuwrtzkrXpDBD1loJeVyOl-dwGBI4XwPWeYw7shEWxHWV24sNp7FXOnqYy_VBe9U	android	2026-02-09 13:21:01.223144+00	2026-02-09 13:21:01.223144+00
6fb17a5d-e831-4480-9f8c-b70e8fd56271	eeca92f2-ebfe-43b1-945e-a57ce93ae845	dfYpMcz3QK6CcUJ6qJjMIR:APA91bHclQQc7wLT-YLdOi1GuUyUAE4wBEXIWl5i2UgV6fB48kqx-QShYJ3-SGNmbkCH2je4jauWvxfTV2_GsnNn6zoZw11eFzYllmfeb5T0OZv-5iiD7-U	android	2026-02-09 13:21:33.404828+00	2026-02-09 13:21:33.404828+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, phone, password_hash, full_name, profile_photo_url, is_verified, is_dealer, is_active, created_at, updated_at, last_login_at, gender, dob) FROM stdin;
2fb65e4b-a424-41c7-a84d-6015c8c45ced	pc@gmail.com	+1231214	$2a$12$/7gW.I4sh.2eDZ7vqGTpnuwiQ9H/ypaIInoQOTZcr1SemM.X1qMh2	Pc Person	\N	t	f	t	2026-02-08 05:48:55.305788	2026-02-09 13:21:00.575395	2026-02-09 13:21:00.575	\N	\N
eeca92f2-ebfe-43b1-945e-a57ce93ae845	mobile@gmail.com	+1273766454	$2a$12$E04gVEhIhQvKYPm8u7Y26uxIcG7NMjuC0elzBA8GPka.a31A6KA5O	Mobile Phone	\N	t	f	t	2026-02-08 05:37:32.636429	2026-02-09 13:21:32.791321	2026-02-09 13:21:32.79122	\N	\N
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

\unrestrict HNc9yTwyFc6uwuG9y9SakUcAjW3uqdXEAuFYEo92aYASwxmxdDh98EetgppL2cw

