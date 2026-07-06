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