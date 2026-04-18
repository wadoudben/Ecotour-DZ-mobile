# EcoTourDZ Mobile App

EcoTourDZ is a Flutter-based mobile application promoting sustainable tourism and ecological destinations. It serves as the companion app for the EcoTourDZ platform, allowing users to explore eco-friendly hotels, engage with a vibrant travel blog community, and manage reservations.

## Features
- **User Roles:** Distinct experiences for regular Users, Blog Authors, and Administrators.
- **Destinations & Hotels:** Browse carefully curated ecological destinations and sustainable accommodation options.
- **Micro-blogging Community:** Engage with articles, post comments, drop reactions.
- **Real-Time Communication:** Integrated chat/messaging features.
- **Secure Architecture:** State-of-the-art authentication using Flutter Secure Storage to interface securely with the Laravel ecosystem backend.

## Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode (for emulation)
- The [EcoTourDZ Laravel Backend](https://github.com/your-username/ecotourdz-backend) running locally or remotely.

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/your-username/ecotourdz-mobile.git
cd ecotourdz-mobile
```

2. Install dependencies
```bash
flutter pub get
```

3. Setup Backend Configuration
Update `lib/services/api_service.dart` with your API URL:
If running an Android emulator targeting a local Laravel Sail or Serve backend, use `http://10.0.2.2:8000/api`. For iOS Simulator, use `http://127.0.0.1:8000/api`. For production, configure the live remote URL.

4. Run the project
```bash
# To run on an attached physical device or emulator
flutter run
```

## Project Structure
- `lib/models`: Data structures and serializations.
- `lib/screens`: Application UI pages, logically separated by user roles (`/admin`, `/author`, `/user`, `/home`, etc).
- `lib/services`: Networking and API integration.
- `lib/storage`: Local encrypted secure storage for storing tokens.
- `lib/widgets`: Shared UI components and partials.

## Contributing
Contributions are always welcome. Please follow standard repository gitflow when creating feature branches and opening pull requests!
