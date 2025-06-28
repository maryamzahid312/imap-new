# 🗺️ iMap – Interactive Geo Mapping App

**iMap** is a Flutter-based interactive mapping application that allows users to search for cities, visualize data points on a map, and upload custom datasets in CSV or JSON format. Users can filter the displayed data by population range and view city-specific markers with animated effects.

---

## 🚀 Features

- 🌍 **OpenStreetMap and Satellite Map Layers**
- 🔍 **City Search with Auto-Completion** (powered by Geocoding API)
- 📁 **File Upload Support** for `.csv` and `.json` files
- 📊 **Population-Based Filtering**
- 📌 **Animated Markers** for user-uploaded data
- 🧭 **Map Controls**: Zoom, Toggle View, Marker Info
- 📝 **Manual Data Entry** via Dialog Form
- 🎯 Built using [flutter_map](https://pub.dev/packages/flutter_map)

---

## 📱 Screenshots

> 📌 Add screenshots here of:
- The main map view  
- City search UI  
- Filter dialog  
- File upload dialog

---

## 🧑‍💻 Tech Stack

| Layer | Package |
|-------|---------|
| **Map Rendering** | `flutter_map` |
| **Geolocation** | `latlong2`, Custom GeocodingService |
| **Search Bar** | `flutter_typeahead` |
| **File Handling** | `file_picker`, Custom FileUtils |
| **State Management** | Stateful Widgets |
| **Storage** | Custom local save via `StorageService` |
| **UI** | Material Design with custom assets |

---

## 📂 Folder Structure
lib/
├── models/ # Data model for UserEntry
├── screens/
│ └── home_page.dart # Main UI logic and map integration
├── utils/
│ ├── file_utils.dart # CSV/JSON parsing
│ ├── storage_service.dart # Local storage
│ └── geocoding_service.dart # API for city suggestions
├── assets/
│ └── images/ # Map icons, nav bar icons, etc.

