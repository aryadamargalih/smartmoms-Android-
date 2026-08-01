# SmartMoms Flutter App 🤱

Aplikasi Android untuk pemantauan kesehatan ibu hamil & menyusui yang terhubung dengan smartwatch.

---

## 📁 Struktur Project

```
lib/
├── main.dart                          # Entry point + routing
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Light & Dark theme, colors
│   ├── constants/
│   │   └── app_constants.dart         # Routes, assets, strings
│   └── widgets/
│       └── common_widgets.dart        # Shared widgets (button, textfield, dll)
└── features/
    ├── splash/
    │   └── splash_screen.dart
    ├── onboarding/
    │   └── onboarding_screen.dart
    ├── auth/
    │   ├── login/
    │   │   └── login_screen.dart
    │   └── register/
    │       └── register_screen.dart
    ├── dashboard/
    │   └── dashboard_screen.dart      # BPM, BP, Activity charts
    └── ai_chat/
        └── ai_chat_screen.dart        # AI Health Assistant chat
```

---

## 🚀 Setup

### 1. Dependencies
```bash
flutter pub get
```

### 2. Font Poppins
Download font Poppins dari [Google Fonts](https://fonts.google.com/specimen/Poppins) dan taruh di:
```
assets/fonts/
├── Poppins-Regular.ttf
├── Poppins-Medium.ttf
├── Poppins-SemiBold.ttf
├── Poppins-Bold.ttf
└── Poppins-ExtraBold.ttf
```

### 3. Assets Logo
Taruh file logo kamu di:
```
assets/images/
├── logo.png          # Logo utama
└── splash_logo.png   # Logo untuk splash screen
```

### 4. Buat folder assets
```bash
mkdir -p assets/images assets/fonts
```

### 5. Run
```bash
flutter run
```

---

## 🎨 Color Scheme

| Warna | Hex | Penggunaan |
|-------|-----|-----------|
| Primary Blue | `#1565C0` | Button, accent utama |
| Primary Light | `#1E88E5` | Gradient, icon |
| Accent Orange | `#F57C00` | AI banner, aktivitas |
| BPM Red | `#EF4444` | Chart BPM |
| Success Green | `#22C55E` | Status normal |

---

## 📱 Screens

| Screen | File | Status |
|--------|------|--------|
| Splash | `splash_screen.dart` | ✅ |
| Onboarding | `onboarding_screen.dart` | ✅ |
| Login | `login_screen.dart` | ✅ |
| Register (2-step) | `register_screen.dart` | ✅ |
| Dashboard + Charts | `dashboard_screen.dart` | ✅ |
| AI Chat | `ai_chat_screen.dart` | ✅ |

---

## 🔧 Dependencies Utama

- **fl_chart** `^0.68.0` — Line chart (BPM, Blood Pressure) & Bar chart (Activity)
- **provider** `^6.1.2` — State management
- **google_fonts** `^6.2.1` — Typography
- **go_router** `^13.2.0` — Navigation

---

## 📋 TODO (Backend & Logic)

- [ ] Koneksi API smartwatch (BLE / Bluetooth)
- [ ] Implementasi autentikasi (Firebase / custom API)
- [ ] Integrasi AI API (OpenAI / Gemini / dll)
- [ ] Real-time data sync dari smartwatch
- [ ] Push notification untuk alert kesehatan
- [ ] Export laporan kesehatan (PDF)
- [ ] Profil user & riwayat kehamilan
