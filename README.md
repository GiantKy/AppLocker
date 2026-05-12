# 🔐 Tủ Thông Minh - Smart Locker System

Ứng dụng quản lý tủ thông minh với Flutter (Web/Mobile) + Node.js Backend + Docker.

## 📱 Tính Năng

| Tính năng | Mô tả |
|-----------|-------|
| 📦 **Gửi Hàng** | Lưu tên, ngày sinh, SĐT người gửi; tự động phân ô tủ & tạo mã PIN |
| 📬 **Lấy Hàng** | Nhập số ô tủ + mã PIN để lấy hàng |
| 🗂️ **Quản Lý** | Xem tất cả đơn hàng, trạng thái tủ, tìm kiếm theo tên/SĐT |

## 🏗️ Kiến Trúc

```
App_Locker/
├── backend/              # Node.js + Express + SQLite
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── flutter_app/          # Flutter (Web + Android + iOS)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── home_screen.dart   # Trang chủ + Dashboard
│   │   │   ├── send_screen.dart   # Gửi hàng
│   │   │   ├── receive_screen.dart # Lấy hàng
│   │   │   └── manage_screen.dart # Quản lý
│   │   ├── services/
│   │   └── theme/
│   ├── Dockerfile
│   └── nginx.conf
└── docker-compose.yml    # Đóng gói toàn bộ hệ thống
```

## 🐳 Chạy Với Docker (Khuyên Dùng)

### Yêu Cầu
- Docker Desktop (Windows/Mac/Linux)
- Docker Compose

### Khởi Chạy
```bash
cd App_Locker

# Build và chạy toàn bộ hệ thống
docker-compose up --build

# Hoặc chạy ngầm (background)
docker-compose up --build -d
```

### Truy Cập
- **Web App:** http://localhost:8888
- **API:** http://localhost:3500

### Dừng Hệ Thống
```bash
docker-compose down

# Dừng và xóa data
docker-compose down -v
```

## 💻 Chạy Thủ Công (Không Dùng Docker)

### Backend
```bash
cd backend
npm install
node server.js
# API: http://localhost:3500
```

### Flutter App (Mobile)
```bash
cd flutter_app
flutter pub get
flutter run   # Kết nối thiết bị/emulator
```

### Flutter Web
```bash
cd flutter_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

## 📡 API Endpoints

| Method | Endpoint | Mô Tả |
|--------|----------|-------|
| GET | `/api/lockers` | Danh sách tủ |
| GET | `/api/lockers/available` | Ô tủ trống |
| POST | `/api/packages/send` | Gửi hàng |
| POST | `/api/packages/receive` | Lấy hàng |
| GET | `/api/packages` | Danh sách hàng |
| GET | `/api/stats` | Thống kê |
| GET | `/health` | Health check |

### Ví dụ Gửi Hàng
```json
POST /api/packages/send
{
  "sender_name": "Nguyễn Văn A",
  "sender_dob": "15/03/1990",
  "sender_phone": "0901234567",
  "receiver_name": "Trần Thị B",      // optional
  "receiver_phone": "0987654321",     // optional
  "description": "Quần áo"            // optional
}
```

### Ví dụ Lấy Hàng
```json
POST /api/packages/receive
{
  "locker_number": "L01",
  "pin_code": "1234"
}
```

## ⚙️ Cấu Hình

Trong `flutter_app/lib/services/api_service.dart`:
- Android Emulator: `http://10.0.2.2:3000`
- Physical Device: thay bằng IP máy tính của bạn (VD: `http://192.168.1.100:3000`)
- Web: Nginx proxy tự động chuyển `/api/` → backend

## 🛠️ Công Nghệ

- **Flutter** 3.x - UI Framework (Mobile & Web)
- **Node.js + Express** - REST API Backend
- **SQLite** - Cơ sở dữ liệu
- **Docker + Docker Compose** - Container hóa
- **Nginx** - Web server & Reverse proxy
