Roti Ledger 🥖

A full-stack mobile application built to manage customer ledgers, daily deliveries, and cash payments for a local Roti business.

🚀 Features

Customer Management: Add new customers and set custom pricing per roti for each individual.

Daily Deliveries: Log daily roti deliveries. The system automatically calculates the cost based on the customer's specific rate.

Payment Tracking: Record cash payments received from customers.

Automated Ledger: The system automatically recalculates outstanding balances whenever a delivery or payment is logged.

Transaction History: View a chronological history of all deliveries and payments for any customer.

Secure Authentication: Token-based authentication ensures data is protected.

🛠️ Technology Stack

Frontend (Mobile App)

Flutter (Dart)

Riverpod (State Management)

HTTP (API Communication)

Material 3 Design

Backend (API & Database)

Django (Python)

Django REST Framework

PostgreSQL (Hosted on Render)

Token Authentication

🏗️ Architecture

This is a monorepo containing both the backend and frontend codebases:

/roti_app: Contains the Flutter mobile application.

/ledger: Contains the Django backend applications.

/config: Contains the Django project settings and routing.

💻 Local Development Setup

To run this project locally, you will need Flutter and Python installed.

Backend Setup

Navigate to the project root directory.

Activate the virtual environment:

.venv\Scripts\activate  # Windows
source .venv/bin/activate # Mac/Linux


Install dependencies (if needed):

pip install -r requirements.txt


Run the server:

python manage.py runserver


Frontend Setup

Open a new terminal and navigate to the Flutter app directory:

cd roti_app


Install packages:

flutter pub get


Run the app (ensure an emulator is running or a device is connected):

flutter run


Note: To test against your local backend, change isProduction = false in lib/main.dart.

☁️ Deployment

Backend: Deployed on Render using Gunicorn and a PostgreSQL database.

Frontend: Built as an Android APK (flutter build apk --release).

📱 Screenshots

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-40-37-76_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/85991110-3679-44bf-ad15-d99707f0492e" />

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-42-42-85_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/b51b1a4e-087e-47c4-9f84-1d34cfdffd66" />

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-42-16-07_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/fd52c8c5-66f9-42dc-b70c-b7d9cee05082" />

<img width="1080" height="2412" alt="Screenshot_2026-07-06-09-41-52-25_c2d0a91198de1cadbd9f2c71380f77b5" src="https://github.com/user-attachments/assets/1926a273-0ef5-4a08-8952-edba3d0a3cb7" />

