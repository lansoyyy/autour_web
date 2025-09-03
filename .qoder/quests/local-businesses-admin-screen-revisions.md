# Local Businesses Admin Screen Revisions

## 1. Overview

This document outlines the proposed revisions to the Local Businesses Admin Screen in the Autour Web application. The revisions focus on enhancing business management capabilities with the following key improvements:

1. Addition of Business Registration Number field
2. Restriction on business name editing by owners
3. Enhanced geotagging with color-coded pins based on business categories
4. Integration of social media accounts in business details with Google Maps location
5. Room availability and pricing with timestamp tracking

These changes will improve data accuracy, provide better visualization of business locations, and ensure that critical business information is properly managed by the appropriate parties.

## 2. Current State Analysis

The existing Local Businesses Admin Screen provides basic CRUD (Create, Read, Update, Delete) functionality for managing business listings. Key features include:
- Business information management (name, category, location, description)
- Category-specific fields (accommodations, transportation, markets)
- Social media account integration
- Geolocation coordinates
- Image upload capability
- CSV import/export functionality
- Map view for visualizing business locations

## 3. Proposed Revisions

### 3.1 Business Registration Number

Add a new field to store the official registration number of businesses, which will be managed by the Tourism Office.

#### Implementation Details:
- Add `registrationNumber` field to the Business model
- Add input field in the business form dialog
- Make this field visible but not editable by business owners
- Store in Firestore as `registrationNumber`

### 3.2 Business Name Edit Restriction

Implement a restriction to prevent business owners from editing the business name field, as this should be managed by the Tourism Office.

#### Implementation Details:
- Add a role-based check in the edit form
- Disable the business name field for non-admin users
- Display the field as read-only with appropriate styling

### 3.3 Enhanced Geotagging with Color-Coded Pins

Improve the geotagging functionality with color-coded pins based on business categories for better map visualization.

#### Implementation Details:
- Implement a color mapping system for business categories
- Update map markers to use category-specific colors
- Ensure consistent color coding between map view and business details
- Add visual indication of pin colors in the UI

### 3.4 Social Media Integration in Business Details

Enhance business details to include legitimate social media accounts with direct linking capabilities and exact location on Google Maps.

#### Implementation Details:
- Display social media icons with direct links in business cards
- Add validation for social media URLs
- Include social media accounts in business details view
- Integrate Google Maps for exact location display

### 3.5 Room Availability and Pricing with Timestamps

Implement a system for tracking room availability and pricing with timestamps to show when information was last updated, including a notice that it changes.

#### Implementation Details:
- Add timestamp fields for room availability updates
- Create a history tracking system for price changes
- Display "Last Updated" information in the UI
- Add notice about information changes
- Implement automatic timestamp updates when room information is modified

### 3.6 Adding Categories in Edit Business

Allow administrators to add new business categories during the editing process to expand the available options.

#### Implementation Details:
- Add functionality to create new categories in the edit business form
- Implement category management in the admin interface
- Ensure new categories are properly validated and stored
- Update the category dropdown to include newly added categories

## 4. Detailed Design

### 4.1 Data Model Updates

```dart
class Business {
  String name;
  String category;
  String location;
  String description;
  String? registrationNumber; // New field
  String? phone;
  String? email;
  String? hours;
  int? roomsAvailable;
  int? totalRooms;
  List<String>? roomTypes;
  String? priceRange;
  Map<String, dynamic>? prices;
  Map<String, dynamic>? fares;
  String? image;
  // Social media fields
  String? tiktok;
  String? facebook;
  String? instagram;
  String? telegram;
  // Geolocation fields
  double? latitude;
  double? longitude;
  // Timestamp fields
  DateTime? roomAvailabilityLastUpdated; // New field
  DateTime? priceLastUpdated; // New field
  
  Business({
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    this.registrationNumber,
    this.phone,
    this.email,
    this.hours,
    this.roomsAvailable,
    this.totalRooms,
    this.roomTypes,
    this.priceRange,
    this.prices,
    this.fares,
    this.image,
    this.tiktok,
    this.facebook,
    this.instagram,
    this.telegram,
    this.latitude,
    this.longitude,
    this.roomAvailabilityLastUpdated,
    this.priceLastUpdated,
  });
  
  // Convert Business object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'location': location,
      'description': description,
      'registrationNumber': registrationNumber,
      'phone': phone,
      'email': email,
      'hours': hours,
      'roomsAvailable': roomsAvailable,
      'totalRooms': totalRooms,
      'roomTypes': roomTypes,
      'priceRange': priceRange,
      'prices': prices,
      'fares': fares,
      'image': image,
      'tiktok': tiktok,
      'facebook': facebook,
      'instagram': instagram,
      'telegram': telegram,
      'latitude': latitude,
      'longitude': longitude,
      'roomAvailabilityLastUpdated': roomAvailabilityLastUpdated?.toIso8601String(),
      'priceLastUpdated': priceLastUpdated?.toIso8601String(),
    };
  }
  
  // Create Business object from Firestore map
  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      name: map['name'],
      category: map['category'],
      location: map['location'],
      description: map['description'],
      registrationNumber: map['registrationNumber'],
      phone: map['phone'],
      email: map['email'],
      hours: map['hours'],
      roomsAvailable: map['roomsAvailable'],
      totalRooms: map['totalRooms'],
      roomTypes: List<String>.from(map['roomTypes'] ?? []),
      priceRange: map['priceRange'],
      prices: Map<String, dynamic>.from(map['prices'] ?? {}),
      fares: Map<String, dynamic>.from(map['fares'] ?? {}),
      image: map['image'],
      tiktok: map['tiktok'],
      facebook: map['facebook'],
      instagram: map['instagram'],
      telegram: map['telegram'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      roomAvailabilityLastUpdated: map['roomAvailabilityLastUpdated'] != null
          ? DateTime.parse(map['roomAvailabilityLastUpdated'])
          : null,
      priceLastUpdated: map['priceLastUpdated'] != null
          ? DateTime.parse(map['priceLastUpdated'])
          : null,
    );
  }
}
```

### 4.2 UI/UX Design

#### 4.2.1 Add/Edit Business Dialog

The business form dialog will be enhanced with the following changes:

1. **Business Name Field**:
   - For admin users: Editable text field
   - For business owners: Read-only field with disabled styling
   - Positioned at the top of the form

2. **Registration Number Field**:
   - New text field added to the form
   - Positioned after the business name field
   - Visible to all users but only editable by admins
   - Includes validation for proper format

3. **Geolocation Section**:
   - Enhanced map interface with category color coding
   - Improved marker visualization
   - Integration with Google Maps for precise location selection
   - Visual indicator showing the category color for the pin

4. **Room Information Section**:
   - Add timestamp display for last update
   - Add notice about information changes
   - Automatic timestamp update when room information is modified
   - Clear indication when information was last updated

#### 4.2.2 Business Details View

The business details view will be enhanced with:

1. **Social Media Integration**:
   - Clickable social media icons with direct links
   - Proper validation of social media URLs

2. **Geolocation Information**:
   - Google Maps integration for exact location display
   - Color-coded category pins

3. **Room Availability Information**:
   - Timestamp for last update
   - Notice about information changes

### 4.3 Map Implementation

#### 4.3.1 Color-Coded Category Pins

Implement a consistent color scheme for different business categories:

```dart
Color _getCategoryColor(String category) {
  switch (category) {
    case 'Accommodations':
      return Colors.blue;
    case 'Restaurants':
      return Colors.red;
    case 'Markets':
      return Colors.green;
    case 'Transportation':
      return Colors.orange;
    case 'Services':
      return Colors.purple;
    case 'Tours':
      return Colors.teal;
    default:
      return primaryColor;
  }
}

// Enhanced marker creation with category-specific styling
Marker _createBusinessMarker(Business business) {
  return Marker(
    point: LatLng(business.latitude!, business.longitude!),
    width: 80,
    height: 80,
    child: GestureDetector(
      onTap: () => _showBusinessDetails(business),
      child: Icon(
        Icons.location_pin,
        color: _getCategoryColor(business.category),
        size: 40,
      ),
    ),
  );
}
```

#### 4.3.2 Google Maps Integration

Integrate Google Maps for displaying exact business locations in business details:

- Add Google Maps widget to business details view
- Implement proper API key handling through environment variables
- Ensure responsive design for map display
- Add marker with business name and category color
- Include zoom controls for better user experience

## 5. Business Logic Implementation

### 5.1 Role-Based Access Control

Implement role-based access control to restrict business name editing:

```dart
// Check if user can edit business name
bool canEditBusinessName(User user) {
  // Only admin and tourism office users can edit business names
  return user.role == UserRole.admin || user.role == UserRole.tourismOffice;
}

// Check if user can edit registration number
bool canEditRegistrationNumber(User user) {
  // Only admin and tourism office users can edit registration numbers
  return user.role == UserRole.admin || user.role == UserRole.tourismOffice;
}
```

### 5.2 Timestamp Management

Implement automatic timestamp updates for room availability and pricing:

```dart
// When updating room availability
void updateRoomAvailability(Business business, int roomsAvailable) {
  business.roomsAvailable = roomsAvailable;
  business.roomAvailabilityLastUpdated = DateTime.now();
  
  // Update in Firestore
  updateBusiness(business.id, business);
}

// When updating prices
void updatePrices(Business business, Map<String, dynamic> newPrices) {
  business.prices = newPrices;
  business.priceLastUpdated = DateTime.now();
  
  // Update in Firestore
  updateBusiness(business.id, business);
}
```

### 5.3 Data Validation

Enhance data validation for the new fields:

1. **Registration Number**:
   - Validate format based on local regulations
   - Ensure uniqueness within the system
   - Implement regex pattern matching for validation

2. **Social Media URLs**:
   - Validate URL format using standard URL validation
   - Check for legitimate social media domains (facebook.com, instagram.com, etc.)
   - Implement proper URL encoding for storage

3. **Geolocation Data**:
   - Validate coordinate ranges (latitude: -90 to 90, longitude: -180 to 180)
   - Ensure coordinates are within the target region (Aurora Province)
   - Implement coordinate precision limits

## 6. Firestore Integration

### 6.1 Updated Data Structure

The Firestore document structure will be updated to include new fields:

```javascript
businesses: {
  [businessId]: {
    name: string,
    category: string,
    location: string,
    description: string,
    registrationNumber: string,  // New field
    phone: string,
    email: string,
    hours: string,
    roomsAvailable: number,
    totalRooms: number,
    roomTypes: string[],
    priceRange: string,
    prices: object,
    fares: object,
    image: string,
    // Social media
    tiktok: string,
    facebook: string,
    instagram: string,
    telegram: string,
    // Geolocation
    latitude: number,
    longitude: number,
    // Timestamps
    roomAvailabilityLastUpdated: timestamp,  // New field
    priceLastUpdated: timestamp  // New field
  }
}
```

## 7. Implementation Approach

### 7.1 Frontend Implementation

1. **Update Business Model**:
   - Add new fields to the Business class
   - Implement serialization/deserialization methods

2. **Update Business Form**:
   - Add registration number field
   - Implement role-based field enabling/disabling
   - Add timestamp display for room information
   - Enhance geolocation section with Google Maps

3. **Update Business Display**:
   - Add social media icons with direct links
   - Integrate Google Maps for exact location display
   - Show timestamp information for room availability

### 7.2 Backend Integration

1. **Firestore Updates**:
   - Update data structure to include new fields
   - Ensure backward compatibility with existing data
   - Implement proper indexing for new fields

2. **Security Rules**:
   - Implement role-based access controls
   - Restrict business name editing to authorized users
   - Protect registration number field from unauthorized changes

### 7.3 Testing and Validation

1. **Unit Testing**:
   - Test Business model with new fields
   - Validate form behavior for different user roles
   - Test timestamp functionality

2. **Integration Testing**:
   - Verify Firestore data storage and retrieval
   - Test map integration with color-coded pins
   - Validate social media link functionality

3. **User Acceptance Testing**:
   - Verify business name editing restrictions
   - Confirm registration number field behavior
   - Validate timestamp display and update functionality

## 8. Error Handling and User Feedback

- Implement proper error handling for form submissions
- Provide user feedback for successful operations
- Display error messages for validation failures

## 9. Testing Strategy

### 8.1 Unit Tests

- Test Business model with new fields
- Test form validation logic
- Test role-based access control
- Test timestamp management

### 8.2 Integration Tests

- Test Firestore data storage with new fields
- Test map integration with color-coded pins
- Test social media link functionality

### 8.3 UI Tests

- Test form behavior for different user roles
- Test map visualization with category colors
- Test business details display with new information

## 10. Implementation Roadmap

### Phase 1: Data Model and Backend Updates
- Update Business model
- Update Firestore integration
- Implement timestamp management

### Phase 2: UI Enhancements
- Update business form dialog
- Implement role-based field restrictions
- Add registration number field

### Phase 3: Map and Geolocation Improvements
- Implement color-coded category pins
- Integrate Google Maps for business details
- Enhance geolocation validation

### Phase 4: Social Media and Information Display
- Implement social media link validation
- Add clickable social media icons
- Implement timestamp display in UI

## 11. Security Considerations

- Ensure registration numbers are properly protected
- Implement proper role-based access controls
- Validate all user inputs to prevent injection attacks
- Secure API keys for map services