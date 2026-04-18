<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter 3.x">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart 3.x">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">
</p>

<h1 align="center">🌿 EcoTour-DZ Mobile App</h1>
<p align="center">An eco-tourism mobile application for Algeria — discover destinations, hotels, blogs, and connect with the community.</p>

---

## ✨ Features

- 🗺️ **Destinations** — Browse and discover eco-friendly destinations across Algeria
- 🏨 **Hotels** — Find sustainable hotels with eco-level ratings and pricing
- 📝 **Blog Reading** — Explore eco-tourism articles written by the community
- 💬 **Reactions & Engagement** — Leave likes, eco-reactions, and comments on posts
- 📩 **Messaging** — Real-time chat system to communicate with other members and admins
- 👤 **Profile Management** — Update your personal details and app preferences
- 🔐 **Role-Based Navigation** — Custom app interfaces depending on your role (Admin, Author, User)
- 🌐 **Secure Authentication** — Token-based security seamlessly connected to the Laravel API

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Networking | `http` package (REST) |
| Local Storage | Secure Storage (`flutter_secure_storage`) |
| Platform Support | Android / iOS / Web |
| Backend Integration | Laravel Sanctum API |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode (for emulation)
- A running instance of the EcoTour-DZ backend API

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/wadoudben/Ecotour-DZ-mobile.git
cd Ecotour-DZ-mobile

# 2. Get Flutter dependencies
flutter pub get

# 3. Configure API Endpoint
# Open lib/services/api_service.dart and update `baseUrl` if necessary.
# By default, it targets 10.0.2.2 (Android Emulator).

# 4. Run the application
flutter run
```

---

## 🔑 Default Connection Notes

Make sure you've seeded your backend database to log into the app!
Example accounts assuming default backend seeds:

| Role | Email | Password |
|---|---|---|
| Admin | admin@eco.com | admineco |
| Author | author@eco.com | authoreco |
| User | user@eco.com | usereco |

---

## 📱 App Navigation Overview

| Role Segment | Description |
|---|---|
| **`/screens/user`** | Home feed, Chat, Booking access, and general blog browsing. |
| **`/screens/author`** | Dashboards allowing authors to view their authored blogs and track engagement. |
| **`/screens/admin`** | Panels for the admin to create/edit/delete new Destinantions, Hotels, and moderate users. |
| **`/screens/destinations`** | Dynamic map wrappers and detail screens for landmarks. |
| **`/screens/auth`** | The secure entry point (Login/Register) utilizing Token Storage. |

---

## 📁 Project Structure

```text
lib/
├── models/         # Dart data models (Destination, Hotel, BlogPost, User)
├── screens/        # UI Screens segmented by Role and Feature
│   ├── admin/      # Admin moderation screens
│   ├── auth/       # Login and Registration
│   ├── author/     # Author-specific dashboards
│   ├── blog/       # Blog feed and detail views
│   ├── destinations/ # Landmark browsing and maps
│   ├── home/       # Primary landing screens
│   ├── hotels/     # Accommodation browsing
│   └── user/       # End-user profile and chat tools
├── services/       # Network logic (api_service.dart)
├── storage/        # Secured local token caching
├── widgets/        # Reusable UI partials and components
├── role_based_nav.dart # Logic directing users to their correct interface
└── main.dart       # App entry point
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
