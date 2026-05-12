# 📱 Smart Locker App (Flutter)

Đây là ứng dụng giao diện người dùng (Frontend) cho hệ thống **Smart Locker** (Tủ Thông Minh), được xây dựng bằng framework **Flutter**. Ứng dụng hỗ trợ chạy trên cả môi trường **Web** và **Mobile (Android/iOS)**.

## ✨ Tính Năng Chính

*   **Trang Chủ (Dashboard):** Xem tổng quan thống kê trạng thái tủ và đơn hàng nhanh chóng.
*   **Gửi Hàng:** Biểu mẫu nhập thông tin người gửi (Tên, ngày sinh, SĐT), tự động gọi API để hệ thống cấp ô tủ trống và mã PIN.
*   **Lấy Hàng:** Nhập số ô tủ và mã PIN bảo mật để lấy hàng.
*   **Quản Lý:** Giao diện cho Admin/Nhân viên quản lý để xem danh sách toàn bộ các gói hàng và trạng thái các ô tủ.

## 📂 Cấu Trúc Thư Mục `lib/`

```text
lib/
├── config/
│   └── app_config.dart         # Cấu hình địa chỉ API Server (Development/Production)
├── models/                     # Các lớp model (Locker, Package, User,...)
├── providers/                  # Quản lý trạng thái (State Management)
├── screens/
│   ├── home_screen.dart        # Màn hình chính
│   ├── send_screen.dart        # Màn hình gửi hàng
│   ├── receive_screen.dart     # Màn hình nhận hàng
│   └── manage_screen.dart      # Màn hình quản lý hệ thống
├── services/
│   ├── api_service.dart        # Xử lý gọi API giao tiếp với Backend
│   └── local_storage_service.dart # Dịch vụ lưu trữ dữ liệu cục bộ (SharedPreferences/Hive)
├── theme/                      # Cấu hình màu sắc, typography, UI/UX
├── utils/                      # Các hàm tiện ích, helpers
└── main.dart                   # Điểm bắt đầu của ứng dụng
```

## ⚙️ Cấu Hình API Endpoint

Để ứng dụng kết nối được với Node.js Backend, bạn cần kiểm tra và cập nhật cấu hình API URL.

Mở file `lib/config/app_config.dart` hoặc `lib/services/api_service.dart` (tùy theo cấu trúc dự án hiện tại của bạn) và cập nhật đường dẫn:

*   **Chạy giả lập Android (Emulator):** Sử dụng `http://10.0.2.2:3500`
*   **Chạy trên thiết bị thật (Physical Device):** Thay bằng IP mạng LAN của máy tính bạn (Ví dụ: `http://192.168.1.50:3500`)
*   **Chạy Web / Docker:** Web thường dùng Nginx proxy `/api/` hoặc trỏ trực tiếp localhost nếu chạy cục bộ (`http://localhost:3500`).

*(Lưu ý: Theo tài liệu gốc, cổng API Backend hiện tại là 3500).*

## 🚀 Hướng Dẫn Chạy Cục Bộ (Local)

Đảm bảo bạn đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) trên máy.

**1. Cài đặt các thư viện (dependencies):**
```bash
flutter pub get
```

**2. Chạy ứng dụng trên thiết bị di động (Mobile - Android/iOS):**
```bash
flutter run
```

**3. Chạy ứng dụng dưới dạng Web App:**
```bash
flutter run -d chrome
```

## 📦 Xây Dựng Bản Phát Hành (Build Release)

**Build cho Android (APK):**
```bash
flutter build apk
```

**Build cho Web:**
```bash
flutter build web
```
*(Thư mục `build/web` có thể được sử dụng để host trên Firebase Hosting, Vercel, hoặc chạy cùng Nginx/Docker).*
