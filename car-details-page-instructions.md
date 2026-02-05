# Car Details Page Implementation - Instructions for Antigravity Claude

## Task Overview

Create a car details page in the Flutter app that displays comprehensive information about a single car when a user taps on a car item from the car list (homepage or "My Cars" section).

---

## API Endpoint Information

**Endpoint:** `GET /api/cars/{carId}`

**Example Response:**
```json
{
  "id": "8228e04d-8891-4b7a-97eb-82ee56600500",
  "seller_id": "e9d5050e-a2b4-4308-a07f-9030f037d5e0",
  "title": "Toyota Camry 2022",
  "description": "Well-maintained car with full service history",
  "make": "Toyota",
  "model": "Camry",
  "year": 2022,
  "mileage": 3243243,
  "price": 2342342343,
  "condition": "excellent",
  "transmission": "automatic",
  "fuel_type": "petrol",
  "color": "silver",
  "vin": "1HGBH41JXMN109186",
  "images": [
    "https://pub-xxx.r2.dev/cars/image1.jpg",
    "https://pub-xxx.r2.dev/cars/image2.jpg"
  ],
  "city": "Los Angeles",
  "state": "California",
  "latitude": 34.0522,
  "longitude": -118.2437,
  "status": "active",
  "is_featured": false,
  "views_count": 0,
  "created_at": "2026-02-04T12:54:39.470931Z",
  "updated_at": "2026-02-04T12:54:39.470931Z",
  "expires_at": "2026-05-05T12:54:39.470931Z",
  "is_favorited": false,
  "is_owner": false
}
```

---

## Required UI Components (Top to Bottom)

### 1. Image Carousel
- Display all images from the `images` array
- Swipeable horizontally
- Show image indicators/dots at the bottom
- If `images` array is empty, show a placeholder image

### 2. Title Row
- Car title (from `title` field)
- Car brand (from `make` field)
- Share button (on the right)

### 3. Mileage & Fuel Type Row
- Mileage card showing `mileage` value with icon
- Fuel type card showing `fuel_type` value with icon
- Both cards in one row with equal width

### 4. Price Section
- Display `price` prominently formatted as currency
- Large, bold text

### 5. Description Section
- Display `description` text
- Expandable if text is too long

### 6. Bottom Action Buttons
- Chat button (to contact seller)
- Call button (to call seller)
- Fixed at bottom of screen or in a sticky footer

---

## Step-by-Step Implementation Instructions

### Phase 1: Analyze Existing Project Structure

Before writing any code, analyze:

1. **Find the car list implementation:**
   - Locate where car list/grid is displayed (homepage, my cars page)
   - Check how car items are currently built
   - Identify how navigation is handled in the project
   - Note the routing/navigation pattern used (Navigator.push, named routes, go_router, etc.)

2. **Find the API service layer:**
   - Locate where API calls are made
   - Check if there's a CarService, ApiService, or similar
   - Identify the HTTP client being used (dio, http package, etc.)
   - Note the base URL configuration

3. **Find the Car model:**
   - Locate the Car model/class definition
   - Check if it has all the fields from the API response
   - Note how JSON serialization is handled (json_serializable, manual, etc.)

4. **Identify the project's patterns:**
   - State management solution (Provider, Riverpod, Bloc, GetX, etc.)
   - Folder structure conventions
   - Naming conventions for screens/pages
   - Widget organization patterns

---

### Phase 2: Update or Create Car Model

**Task:** Ensure the Car model has all fields from the API response

**What to do:**

1. **Locate the existing Car model** (search for `class Car` or similar)

2. **Verify it has these fields:**
   - id, seller_id, title, description
   - make, model, year, mileage, price
   - condition, transmission, fuel_type, color, vin
   - images (List<String>)
   - city, state, latitude, longitude
   - status, is_featured, views_count
   - created_at, updated_at, expires_at
   - is_favorited, is_owner

3. **Add missing fields** if any are absent

4. **Ensure proper JSON serialization:**
   - If using `fromJson` factory, make sure all fields are mapped
   - If using `json_serializable`, ensure annotations are correct
   - Handle nullable fields appropriately (use `?` for optional fields)

**Example structure (adapt to existing pattern):**
```dart
class Car {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final String make;
  final String model;
  final int year;
  final int mileage;
  final double price;
  final String? condition;
  final String? transmission;
  final String fuelType;
  final String? color;
  final String? vin;
  final List<String> images;
  final String city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final String status;
  final bool isFeatured;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final bool isFavorited;
  final bool isOwner;

  // Constructor, fromJson, toJson...
}
```

---

### Phase 3: Create API Method to Fetch Single Car

**Task:** Add a method to fetch car details by ID

**What to do:**

1. **Locate the API service file** (CarService, ApiService, etc.)

2. **Add a new method** to get single car details:
   - Method name: `getCarById` or `fetchCarDetails` (follow existing naming)
   - Parameters: `String carId`
   - Return type: `Future<Car>` or `Future<Car?>` depending on error handling
   - Endpoint: `GET /api/cars/{carId}`

3. **Implement the method:**
   - Make GET request to `/api/cars/$carId`
   - Parse JSON response into Car object
   - Handle errors appropriately (network errors, 404, etc.)
   - Follow the existing error handling pattern in the project

**Example approach (adapt to existing code style):**
```dart
Future<Car> getCarById(String carId) async {
  // Use existing HTTP client
  final response = await httpClient.get('/api/cars/$carId');
  
  if (response.statusCode == 200) {
    return Car.fromJson(response.data);
  } else {
    throw Exception('Failed to load car details');
  }
}
```

---

### Phase 4: Create Car Details Page Widget

**Task:** Create a new screen/page to display car details

**What to do:**

1. **Create a new file** for the details page:
   - Follow the project's naming convention (e.g., `car_details_page.dart`, `car_detail_screen.dart`)
   - Place it in the appropriate folder (screens/, pages/, views/, etc.)

2. **Create the main widget:**
   - Stateful or Stateless based on requirements
   - If using state management, create the appropriate provider/bloc/controller

3. **Accept car ID as parameter:**
   - Constructor should accept `String carId`
   - Or accept the full `Car` object if navigation passes it

4. **Handle data loading:**
   - Show loading indicator while fetching data
   - Display error message if fetch fails
   - Show car details when data loads successfully

**Widget structure:**
```dart
class CarDetailsPage extends StatefulWidget {
  final String carId;
  
  const CarDetailsPage({required this.carId});
  
  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  // State variables for loading, error, car data
  // Fetch car details in initState or using state management
}
```

---

### Phase 5: Implement UI Components

**Task:** Build each section of the details page

#### 5.1 Image Carousel

**What to implement:**

1. **Find or install a carousel package:**
   - Check if `carousel_slider` or similar is already in pubspec.yaml
   - If not, ask user: "Should I add carousel_slider package for the image carousel?"

2. **Build the carousel:**
   - Use `CarouselSlider` or `PageView` widget
   - Map over `car.images` list to display each image
   - Use `Image.network()` to load images from URLs
   - Add loading placeholders while images load
   - Add error placeholders if image fails to load
   - Add dots indicator below carousel to show current position

3. **Handle empty images:**
   - If `car.images.isEmpty`, show a placeholder/default car image

**Approach:**
```dart
// Carousel widget
CarouselSlider(
  items: car.images.map((imageUrl) => 
    Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: // show loading spinner,
      errorBuilder: // show error placeholder,
    )
  ).toList(),
  options: CarouselOptions(
    height: 300,
    viewportFraction: 1.0,
    enableInfiniteScroll: car.images.length > 1,
  ),
)
```

#### 5.2 Title Row

**What to implement:**

1. **Create a row with three elements:**
   - Car title (left, takes most space)
   - Car make/brand (below title or as subtitle)
   - Share button (right)

2. **Title styling:**
   - Large, bold font
   - Use `car.title` field

3. **Brand display:**
   - Smaller text showing `car.make` or `car.make + ' ' + car.model`

4. **Share button:**
   - Icon button with share icon
   - On press: Use `share_plus` package to share car details
   - Share text: Include car title, price, and link if available

**Layout:**
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(car.title, style: // large bold),
          Text(car.make, style: // smaller gray),
        ],
      ),
    ),
    IconButton(
      icon: Icon(Icons.share),
      onPressed: () {
        // Share car details
      },
    ),
  ],
)
```

#### 5.3 Mileage & Fuel Type Row

**What to implement:**

1. **Create two cards in a row:**
   - Each card takes 50% width (use Expanded or Flexible)
   - Add padding/margin between cards

2. **Mileage card:**
   - Icon: odometer/speed icon
   - Label: "Mileage"
   - Value: `car.mileage` formatted with commas (e.g., "32,432 km")

3. **Fuel type card:**
   - Icon: gas pump or appropriate fuel icon
   - Label: "Fuel Type"
   - Value: `car.fuelType` capitalized

4. **Styling:**
   - Light background color
   - Rounded corners
   - Icon and text vertically aligned

**Layout:**
```dart
Row(
  children: [
    Expanded(
      child: Card(
        child: // Mileage info with icon and text,
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: Card(
        child: // Fuel type info with icon and text,
      ),
    ),
  ],
)
```

#### 5.4 Price Section

**What to implement:**

1. **Display price prominently:**
   - Very large, bold font
   - Format as currency (e.g., "$2,342,343")
   - Add currency symbol based on locale or hardcode "$"

2. **Optional additions:**
   - Label above price: "Price"
   - Negotiable badge if applicable

**Formatting:**
```dart
Text(
  '\$${NumberFormat('#,###').format(car.price)}',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  ),
)
```

#### 5.5 Description Section

**What to implement:**

1. **Display description text:**
   - Use `car.description` field
   - Multi-line text
   - Readable font size

2. **Handle long descriptions:**
   - If description is very long, truncate initially
   - Add "Read more" / "Show less" button to expand/collapse
   - Or use `maxLines` property with ellipsis

3. **Styling:**
   - Gray color for better readability
   - Proper line height
   - Padding around text

**Approach:**
```dart
// Simple version
Text(
  car.description,
  style: TextStyle(color: Colors.grey[700]),
)

// Or expandable version with maxLines and "Read more" button
```

#### 5.6 Bottom Action Buttons

**What to implement:**

1. **Create a fixed bottom bar:**
   - Use `bottomNavigationBar` in Scaffold
   - Or use a Container with fixed positioning

2. **Two buttons side by side:**
   - Chat button (left, primary color)
   - Call button (right, secondary color or outlined)
   - Equal width or proportional

3. **Chat button action:**
   - Navigate to chat screen with seller
   - Pass `car.sellerId` to chat screen
   - If chat feature not implemented, show "Coming soon" message

4. **Call button action:**
   - Check if you have seller phone number in data
   - Use `url_launcher` package to initiate phone call
   - Format: `tel:${sellerPhone}`
   - If phone number not available, show message or disable button

**Layout:**
```dart
// In Scaffold
bottomNavigationBar: Container(
  padding: EdgeInsets.all(16),
  child: Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          icon: Icon(Icons.chat),
          label: Text('Chat'),
          onPressed: () {
            // Navigate to chat or show message
          },
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: OutlinedButton.icon(
          icon: Icon(Icons.call),
          label: Text('Call'),
          onPressed: () {
            // Make phone call
          },
        ),
      ),
    ],
  ),
)
```

---

### Phase 6: Add Navigation from Car List

**Task:** Enable navigation to details page when user taps a car item

**What to do:**

1. **Locate car list item widgets:**
   - Find where car items are displayed (GridView, ListView, etc.)
   - Identify the widget that represents a single car item

2. **Add tap handler:**
   - Wrap the car item widget with `GestureDetector` or `InkWell`
   - On tap, navigate to car details page

3. **Pass car ID to details page:**
   - Use the existing navigation method in the project
   - Pass `car.id` to the details page

4. **Navigation approaches** (choose based on what's used in project):
   
   **Option A: Direct Navigator.push**
   ```dart
   onTap: () {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => CarDetailsPage(carId: car.id),
       ),
     );
   }
   ```
   
   **Option B: Named routes**
   ```dart
   onTap: () {
     Navigator.pushNamed(
       context,
       '/car-details',
       arguments: car.id,
     );
   }
   ```
   
   **Option C: go_router or other routing packages**
   ```dart
   onTap: () {
     context.go('/cars/${car.id}');
   }
   ```

5. **Apply to all car lists:**
   - Add navigation to car items on homepage
   - Add navigation to car items in "My Cars" page
   - Ensure consistent behavior across app

---

### Phase 7: Add Loading and Error States

**Task:** Handle loading, error, and empty states gracefully

**What to implement:**

1. **Loading state:**
   - Show `CircularProgressIndicator` while fetching car details
   - Center it on screen
   - Optionally show skeleton/shimmer loading effect

2. **Error state:**
   - Show error message if API call fails
   - Display error icon
   - Add retry button to refetch data
   - Show appropriate message for different errors (network, 404, etc.)

3. **Empty/null handling:**
   - Handle cases where data might be missing
   - Show placeholders for missing images
   - Show "N/A" or "-" for missing optional fields

**Example structure:**
```dart
// In build method
if (isLoading) {
  return Center(child: CircularProgressIndicator());
}

if (error != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red),
        SizedBox(height: 16),
        Text('Failed to load car details'),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _fetchCarDetails(),
          child: Text('Retry'),
        ),
      ],
    ),
  );
}

// Show car details
return _buildCarDetails();
```

---

### Phase 8: Add Additional Features (Optional Enhancements)

**Ask user which of these to implement:**

1. **Favorite/Save functionality:**
   - Add heart icon to top-right or near title
   - Use `car.isFavorited` field
   - On tap, call API to toggle favorite status
   - Update UI optimistically

2. **View count:**
   - Display `car.viewsCount` somewhere (e.g., below title)
   - Icon with eye + number

3. **Listing status badge:**
   - Show badge if `car.status` is "sold", "pending", etc.
   - Different colors for different statuses

4. **Owner indicator:**
   - If `car.isOwner` is true, show "Your listing" badge
   - Hide chat/call buttons if user is the owner
   - Show "Edit" and "Delete" buttons instead

5. **Location information:**
   - Show `car.city` and `car.state`
   - If `latitude` and `longitude` are available, show map preview
   - Use `google_maps_flutter` or similar package

6. **Additional details section:**
   - Show year, condition, transmission, color, VIN in a list
   - Use ListTile or custom cards
   - Only show fields that have values

7. **Created/Updated timestamps:**
   - Show "Posted on [date]" using `car.createdAt`
   - Format dates nicely using `intl` package

8. **Expires at indicator:**
   - If `car.expiresAt` is set, show "Expires on [date]"
   - Show warning if expiring soon

---

### Phase 9: Test the Implementation

**Testing checklist:**

1. **Navigation test:**
   - Tap on a car from homepage → Should open details page
   - Tap on a car from "My Cars" → Should open details page
   - Back button should return to previous screen

2. **Data display test:**
   - Verify all fields display correctly
   - Check image carousel works (swipe left/right)
   - Verify price formatting is correct
   - Check description displays fully

3. **Loading state test:**
   - Slow down network to see loading indicator
   - Verify loading shows before data appears

4. **Error state test:**
   - Turn off internet → Should show error message
   - Retry button should refetch data
   - Invalid car ID → Should handle 404 gracefully

5. **Action buttons test:**
   - Chat button → Should navigate or show message
   - Call button → Should initiate call or show message

6. **Empty data test:**
   - Car with no images → Should show placeholder
   - Missing optional fields → Should not crash

7. **Different screen sizes:**
   - Test on small and large screens
   - Verify layout adapts properly
   - Check button sizing and readability

---

## Required Packages (Check and Install if Needed)

Before implementing, check if these packages are in `pubspec.yaml`:

1. **For image carousel:**
   - `carousel_slider: ^latest_version`
   - Or use built-in `PageView` widget

2. **For number formatting:**
   - `intl: ^latest_version` (probably already present)

3. **For sharing:**
   - `share_plus: ^latest_version`

4. **For making phone calls:**
   - `url_launcher: ^latest_version`

**Ask user:** "I need these packages for the car details page. Should I add them to pubspec.yaml, or are they already present?"

---

## Questions to Ask Before Implementation

1. **"Where is the car list currently implemented? Can you show me the file(s)?"**
   - Helps locate where to add navigation

2. **"What state management solution is being used in this project?"**
   - Determines how to handle data fetching and state

3. **"Should the chat and call buttons be functional, or should they show 'Coming soon' messages?"**
   - Determines implementation scope

4. **"Are there any specific design requirements or mockups for the details page?"**
   - Ensures UI matches expectations

5. **"Should I implement the optional features (favorites, map, owner actions), or just the basic details page?"**
   - Defines scope of work

6. **"Do you want to fetch car details every time, or can we pass the car object from the list to avoid extra API call?"**
   - Performance optimization consideration

---

## Implementation Approach Summary

**Step 1:** Analyze existing code structure and patterns
**Step 2:** Update Car model if needed
**Step 3:** Add `getCarById` API method
**Step 4:** Create CarDetailsPage widget with state management
**Step 5:** Implement all UI sections (carousel, title, cards, price, description, buttons)
**Step 6:** Add navigation from car lists
**Step 7:** Handle loading, error, and empty states
**Step 8:** Add optional features if requested
**Step 9:** Test thoroughly on different scenarios

---

## Final Notes

- **Match existing code style:** Use the same patterns, naming conventions, and architecture as the rest of the project
- **Don't assume locations:** Search for files and ask if you can't find them
- **Handle edge cases:** Missing data, network errors, empty images, etc.
- **Progressive enhancement:** Start with basic implementation, then add features
- **Ask before major decisions:** Package additions, architecture changes, etc.
- **Test as you build:** Verify each section works before moving to next

The goal is a polished, functional car details page that seamlessly integrates with the existing Flutter app and properly displays all data from the API response.
