# Local Businesses Management - New Features

This document describes the new features implemented for the Local Businesses Management screen.

## Features Implemented

### 1. Social Media Accounts
Business profiles now support official social media accounts:
- TikTok
- Facebook
- Instagram
- Telegram

These fields are visible on the business cards and can be managed through the add/edit dialog.

### 2. Geolocation Support
- Added latitude and longitude fields to business profiles
- Interactive map for selecting business locations
- Visual map view to display all businesses with location data
- Color-coded markers based on business category

### 3. Map Visualization
- Toggle between list view and map view
- Businesses displayed as pins on the map
- Click on markers to view business details
- Automatic centering of map based on business locations

### 4. CSV Import/Export
- Import businesses from CSV files
- Export all businesses to CSV format
- Supports all business fields including social media and geolocation

## How to Use

### Adding a Business with Location
1. Click "Add Business"
2. Fill in business details
3. Scroll to the "Geolocation" section
4. Either:
   - Enter latitude/longitude values manually
   - Click on the map to select a location
   - Use "Generate Random Location" for testing
5. Click "Add"

### Using the Map View
1. Click "Map View" button to switch from list to map
2. Businesses with location data will appear as colored pins
3. Click on pins to view business details
4. Click "List View" to return to the traditional list

### CSV Import/Export
- **Import**: Click "Import CSV" and select a properly formatted CSV file
- **Export**: Click "Export CSV" to download all businesses as a CSV file

## CSV Format
The CSV file should include these columns:
```
name,category,location,description,phone,email,hours,image,tiktok,facebook,instagram,telegram,latitude,longitude
```

## Sample CSV Data
A sample CSV file (`sample_businesses.csv`) is included in the project root for testing.

## Technical Details
- Uses `flutter_map` for map visualization
- OpenStreetMap for map tiles
- All data stored in Firebase Firestore
- CSV handling through `universal_html` for web compatibility