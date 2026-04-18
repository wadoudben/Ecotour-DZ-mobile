<p align="center">
  <img src="https://img.shields.io/badge/Laravel-12-red?logo=laravel" alt="Laravel 12">
  <img src="https://img.shields.io/badge/PHP-8.2-blue?logo=php" alt="PHP 8.2">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License">
</p>

<h1 align="center">🌿 EcoTour-DZ</h1>
<p align="center">An eco-tourism web platform for Algeria — discover destinations, hotels, blogs, and connect with the community.</p>

---

## ✨ Features

- 🗺️ **Destinations** — Browse and discover eco-friendly destinations across Algeria
- 🏨 **Hotels** — Find sustainable hotels with affiliate links
- 📝 **Blog** — Authors can write and publish eco-tourism articles
- 💬 **Comments & Reactions** — Readers can engage with blog posts
- 📩 **Messaging** — Built-in conversation system between users and admin
- 👤 **User Profiles** — Avatar upload, password management
- 🔐 **Role-Based Access** — Admin, Author, and User roles
- 🌐 **REST API** — Full Sanctum-authenticated API for all features

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Backend | Laravel 12 (PHP 8.2) |
| Auth | Laravel Sanctum (API tokens) |
| Database | MySQL |
| Frontend | Blade templates + Vite |
| API | RESTful JSON API |
| Testing | Pest PHP |

---

## 🚀 Getting Started

### Prerequisites

- PHP >= 8.2
- Composer
- Node.js & npm
- MySQL

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/EcoTour-DZ.git
cd EcoTour-DZ

# 2. Install PHP dependencies
composer install

# 3. Install JS dependencies
npm install

# 4. Copy environment file and configure it
cp .env.example .env
php artisan key:generate

# 5. Configure your database in .env, then run migrations
php artisan migrate

# 6. (Optional) Seed the database with a demo author account
php artisan db:seed

# 7. Link storage
php artisan storage:link

# 8. Build frontend assets
npm run build
```

### Running Locally

```bash
composer run dev
```

This starts the Laravel server, queue listener, and Vite dev server concurrently.

---

## 🔑 Default Seeded Account

| Role | Email | Password |
|---|---|---|
| Author | author@eco.com | authoreco |

> ⚠️ Change this password immediately after first login.

---

## 📡 API Overview

| Prefix | Auth | Description |
|---|---|---|
| `/api/destinations` | Public | List & show destinations |
| `/api/hotels` | Public | List & show hotels |
| `/api/blogs` | Public | List & show blog posts |
| `/api/register` `/api/login` | Public | Authentication |
| `/api/profile` | Sanctum | View & update profile |
| `/api/conversations` | Sanctum | Messaging |
| `/api/comments` | Sanctum | Post comments |
| `/api/reactions` | Sanctum | Like / Eco reactions |
| `/api/admin/*` | Sanctum + Admin | Admin management |
| `/api/author/*` | Sanctum + Author | Author blog management |

---

## 📁 Project Structure

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── Admin/        # Web admin controllers
│   │   ├── Api/Admin/    # API admin controllers
│   │   ├── Api/Author/   # API author controllers
│   │   ├── Api/          # Public & auth API controllers
│   │   └── Author/       # Web author controllers
│   └── Middleware/
│       └── EnsureUserHasRole.php
├── Models/               # Eloquent models
resources/views/          # Blade templates
routes/
├── api.php               # API routes
└── web.php               # Web routes
```

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
