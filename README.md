# 🥖 Roti Ledger

A **full-stack mobile application** built to manage **customer ledgers, daily roti deliveries, and cash payments** for a local roti business. The application automates balance calculations, tracks customer transactions, and provides a simple and efficient way to manage daily business operations.

---

# 🚀 Features

### 👥 Customer Management
- Add new customers.
- Set a **custom price per roti** for each customer.

### 🥖 Daily Deliveries
- Record daily roti deliveries.
- Automatically calculate the delivery amount based on the customer's individual pricing.

### 💰 Payment Tracking
- Record cash payments received from customers.
- Maintain accurate payment history.

### 📒 Automated Ledger
- Automatically update customer balances whenever a delivery or payment is recorded.
- Eliminate manual calculations.

### 📜 Transaction History
- View a complete chronological history of:
  - Deliveries
  - Payments
  - Running balance

### 🔐 Secure Authentication
- Token-based authentication protects user data and API endpoints.

---

# 🛠️ Technology Stack

## 📱 Frontend

- **Flutter**
- **Dart**
- **Riverpod** (State Management)
- **HTTP Package** (REST API Communication)
- **Material 3 Design**

## ⚙️ Backend

- **Python**
- **Django**
- **Django REST Framework**
- **Token Authentication**

## 🗄️ Database

- **PostgreSQL**
- Hosted on **Render**

---

# 🏗️ Project Architecture

This project follows a **monorepo architecture**, containing both the backend and frontend codebases.

```
project-root/
│
├── roti_app/      # Flutter mobile application
│
├── ledger/        # Django application (models, views, serializers)
│
├── config/        # Django project configuration and routing
│
├── manage.py
│
└── requirements.txt
```

# 💻 Local Development Setup

## Prerequisites

Before running the project locally, make sure you have installed:

- Flutter SDK
- Python 3.x
- PostgreSQL
- Git

---

## ⚙️ Backend Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd Roti-ledger
```

### 2. Activate the virtual environment

**Windows**

```bash
.venv\Scripts\activate
```

**Mac/Linux**

```bash
source .venv/bin/activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Apply database migrations

```bash
python manage.py migrate
```

### 5. Start the Django server

```bash
python manage.py runserver
```

The backend will run on:

```
http://127.0.0.1:8000/
```

---

## 📱 Frontend Setup

Open another terminal.

Navigate to the Flutter project.

```bash
cd roti_app
```

Install Flutter packages.

```bash
flutter pub get
```

Run the application.

```bash
flutter run
```

> **Note**
>
> To connect the Flutter app to your local backend, change:
>
> ```dart
> isProduction = false;
> ```
>
> inside:
>
> ```
> lib/main.dart
> ```

---

# ☁️ Deployment

## Backend

- Django
- Gunicorn
- PostgreSQL
- Hosted on **Render**

## Frontend

Generate a release APK using:

```bash
flutter build apk --release
```

---

# 📚 Project Highlights

- ✅ Full-stack mobile application
- ✅ RESTful API architecture
- ✅ Token-based authentication
- ✅ Automated ledger calculations
- ✅ Customer-specific pricing
- ✅ PostgreSQL database
- ✅ Flutter + Django integration
- ✅ Production-ready backend deployment

---

# 🔮 Future Improvements

- PDF invoice generation
- Export ledger to Excel
- Customer analytics dashboard
- Push notifications
- Offline data synchronization
- Multi-user support
- Search and filter functionality


📱 Screenshots

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-40-37-76_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/85991110-3679-44bf-ad15-d99707f0492e" />

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-42-42-85_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/b51b1a4e-087e-47c4-9f84-1d34cfdffd66" />

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-42-16-07_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/fd52c8c5-66f9-42dc-b70c-b7d9cee05082" />

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-41-52-25_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/1926a273-0ef5-4a08-8952-edba3d0a3cb7" />

# 👨‍💻 Author

*Bibhudatta Sahoo*

