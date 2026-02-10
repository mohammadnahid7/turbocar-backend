# Listing API Documentation

## Create Listing

**POST** `/api/cars`

**Headers:**
- `Authorization`: Bearer {token}
- `Content-Type`: multipart/form-data

**Body:**
- `title` (string, required): Title of the listing (10-100 chars)
- `description` (string, required): Detailed description
- `make` (string, required): Car make (e.g., Toyota)
- `model` (string, required): Car model (e.g., Camry)
- `year` (int, required): Year of manufacture
- `price` (float, required): Price in base currency
- `mileage` (int, required): Mileage in km/miles
- `condition` (string, required): `excellent`, `good`, `fair`
- `transmission` (string, required): `automatic`, `manual`
- `fuel_type` (string, required): `petrol`, `diesel`, `electric`, `hybrid`
- `color` (string, required): Color
- `vin` (string, optional): Vehicle Identification Number
- `city` (string, required): City location
- `state` (string, required): State/Province
- `latitude` (float, required): Geo-coordinates
- `longitude` (float, required): Geo-coordinates
- `images` (files, required): 3-10 image files (.jpg, .png)

**Response (201 Created):**
```json
{
  "id": "uuid",
  "title": "Toyota Camry 2020",
  "price": 25000,
  "images": ["url1", "url2"],
  "created_at": "...",
  ...
}
```

## Get Listing

**GET** `/api/cars/:id`

**Response (200 OK):**
```json
{
  "id": "uuid",
  "title": "...",
  "seller_name": "John Doe",
  "is_favorited": false,
  "is_owner": false,
  ...
}
```

## List Listings

**GET** `/api/cars`

**Query Parameters:**
- `page` (int): Page number (default 1)
- `limit` (int): Items per page (default 20)
- `make`, `model`, `city`, `state`, `condition` (string): Filters
- `min_price`, `max_price` (float): Price range
- `sort_by` (string): `created_at_desc` (default), `price_asc`, `price_desc`, `year_asc`, `year_desc`

**Response (200 OK):**
```json
{
  "data": [ ... ],
  "total": 100,
  "page": 1,
  "limit": 20
}
```

## Update Listing

**PUT** `/api/cars/:id`

**Headers:**
- `Authorization`: Bearer {token}

**Body (Multipart or JSON if no new images):**
- Fields similar to Create, all optional.
- `images` (files): New images to replace/add.

**Response (200 OK):** Updated car object.

## Delete Listing

**DELETE** `/api/cars/:id`

**Headers:**
- `Authorization`: Bearer {token}

**Response (204 No Content)**

## My Listings

**GET** `/api/cars/my-listings`

**Headers:**
- `Authorization`: Bearer {token}

**Response (200 OK):** List of cars owned by the user.

## Toggle Favorite

**POST** `/api/cars/:id/favorite`

**Headers:**
- `Authorization`: Bearer {token}

**Response (200 OK):**
```json
{
  "favorited": true
}
```

## Get Favorites

**GET** `/api/cars/favorites`

**Headers:**
- `Authorization`: Bearer {token}

**Response (200 OK):** List of favorited cars.
