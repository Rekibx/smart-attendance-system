# 🎓 Smart Attendance Management System

A professional, full-stack attendance management solution featuring a **Node.js/Express API**, **MySQL database**, and a **Flutter mobile app**. 

Designed for universities to streamline the attendance process for both teachers and students.

---

## 🚀 Features

- **Role-based Access**: Separate dashboards for Teachers and Students.
- **Secure Auth**: JWT-based authentication with secure token storage on mobile.
- **Real-time Attendance**: Teachers can mark attendance, and students can view their percentage immediately.
- **Data Persistence**: Robust MySQL schema with automated calculations.

---

## 🛠️ Tech Stack

- **Mobile**: Flutter (Provider for State Management)
- **Backend**: Node.js, Express.js
- **Database**: MySQL
- **Security**: JWT, Bcrypt, Helmet, CORS

---

## 📥 Prerequisites

Before you begin, ensure you have the following installed:
- [Node.js](https://nodejs.org/) (v16 or higher)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [MySQL Server](https://dev.mysql.com/downloads/installer/)
- A code editor like [VS Code](https://code.visualstudio.com/)

---

## ⚙️ Setup & Installation

### 1. Database Setup
1. Open your MySQL client (Command Line or Workbench).
2. Create the database and seed it:
   ```bash
   mysql -u root -p < backend/database/schema.sql
   mysql -u root -p < backend/database/seed.sql
   ```

### 2. Backend Setup
1. Navigate to the backend folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables:
   - Copy `.env.example` to a new file named `.env`.
   - Update `DB_PASSWORD` and `JWT_SECRET` in the `.env` file to match your local setup.
4. Start the server:
   ```bash
   npm run dev
   ```

### 3. Mobile Setup
1. Navigate to the mobile folder:
   ```bash
   cd mobile
   ```
2. Install Flutter packages:
   ```bash
   flutter pub get
   ```
3. **Configure API URL**: 
   - If using an **Android Emulator**, the app is pre-configured to connect to `http://10.0.2.2:4000`.
   - If using a **Physical Device**, find your laptop's local IP address and run the app like this:
     ```bash
     flutter run --dart-define=API_BASE_URL=http://YOUR_LOCAL_IP:4000
     ```

---

## 🔑 Demo Accounts

Use these credentials to test the app (Password for all: `password123`):

| Role | Email |
| :--- | :--- |
| **Teacher** | `teacher@ustm.edu` |
| **Student** | `rikib@student.ustm.edu` |
| **Student** | `monimul@student.ustm.edu` |

---

## 🧪 Running Tests

To verify the installation:
- **Backend**: `cd backend && npm test`
- **Mobile**: `cd mobile && flutter test`

---

## 🆘 Troubleshooting

- **Database Connection Error**: Ensure your MySQL service is running and the credentials in `backend/.env` match your MySQL setup.
- **Mobile App cannot connect to Backend**: Ensure both your laptop and mobile device are on the **same Wi-Fi network**. Use your laptop's Local IP address as the `API_BASE_URL`.
