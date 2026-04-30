<div align="center">

<img src="assets/images/nutripumplogo.webp" alt="NutriPump Logo" width="120" />

<br />
<br />

# NutriPump — Mobile App

### *Premium Kashmiri Artisanal Products, delivered natively to iOS & Android.*

<br />

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-10.x-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev/)

<br />

[![iOS](https://img.shields.io/badge/iOS-13.0+-black?style=flat-square&logo=apple)](https://developer.apple.com/)
[![Android](https://img.shields.io/badge/Android-API%2021+-34A853?style=flat-square&logo=android&logoColor=white)](https://developer.android.com/)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)](./LICENSE)

</div>

---

## 📖 Overview

**NutriPump Mobile** is the native iOS & Android companion to the NutriPump Artisanal e-commerce platform. Built with Flutter, it brings the full premium shopping experience — from product discovery and AI-powered chat assistance, to checkout and real-time order tracking — directly to your pocket.

The app is architected with a feature-first folder structure, Riverpod for reactive state management, and GoRouter for declarative navigation, giving it a clean, scalable, production-grade codebase.

> 🌐 **Web Platform:** [github.com/NaveedBhat/nutripump](https://github.com/NaveedBhat/nutripump)

---

## ✨ Features

### 🛍️ Shopping Experience
- **Home Screen** — Firestore-driven announcements, featured products, category hub, and editorial journal
- **Shop & Discovery** — Full product grid with category filtering, search, and price sorting
- **Voice Search** — Tap-to-speak product search powered by `speech_to_text`
- **AI Gift Builder** — Gemini-powered AI assistant to help users find the perfect product
- **Product Detail** — Multi-image gallery, nutritional info, add to cart, and wishlist
- **Taste Profiler** — Personalized product quiz & recommendation engine

### 🛒 Cart & Checkout
- **Persistent Cart** — Hive-backed local cart that survives app restarts
- **Promo Codes** — Validated promo system with `isFirstOrderOnly` and `oneTimeUse` restrictions
- **Guest Intercept** — Guest users attempting to redeem exclusive promos are prompted to log in
- **Razorpay Checkout** — Full native payment flow with server-side HMAC signature verification
- **Address Book** — Save, edit, and set default delivery addresses

### 🔐 Authentication & Account
- Email/Password registration with email verification flow
- Google Sign-In via Firebase Authentication
- Forgot password via email reset link
- **Account Dashboard** — Quick action hub (Orders, Addresses, Support)
- **Order History** — Real-time order status with timeline tracking
- **Security** — Change password with current-password re-authentication
- **Return Requests** — In-app return flow for delivered orders

### 🔔 Notifications
- **Firebase Cloud Messaging (FCM)** — Push notifications for order updates
- **In-App Notification Centre** — Bell icon with real-time unread badge
- **Local Notifications** — Foreground message display

### 🎨 UI & Polish
- Custom design system with `AppColors`, `AppTypography`, `AppSpacing` tokens
- Lottie animations for loading and success states
- Shimmer skeleton loading for product lists
- Smooth page transitions with `flutter_animate`
- Native splash screen and custom launcher icons

---

## 🛠️ Tech Stack

| Category | Library / Tool |
|----------|---------------|
| **Framework** | Flutter 3.22+ |
| **Language** | Dart 3.4+ |
| **State Management** | Riverpod 2.x + `riverpod_annotation` |
| **Navigation** | GoRouter 14.x |
| **Database** | Firebase Firestore |
| **Authentication** | Firebase Auth + Google Sign-In |
| **Storage** | Firebase Storage |
| **Push Notifications** | Firebase Cloud Messaging |
| **Crash Reporting** | Firebase Crashlytics |
| **Analytics** | Firebase Analytics |
| **Payments** | Razorpay Flutter |
| **Local Storage** | Hive Flutter |
| **Networking** | Dio + http |
| **Image Loading** | Cached Network Image |
| **Animations** | Lottie, flutter_animate, Shimmer |
| **Voice Search** | speech_to_text |
| **Deep Linking** | app_links |
| **Fonts** | Google Fonts |
| **Forms** | Reactive Forms |

---

## 📁 Project Structure

```
nutripump_mobile/
├── assets/
│   ├── animations/          # Lottie JSON files (loading, success)
│   ├── icons/               # SVG/PNG icon assets (e.g. google.png)
│   └── images/              # Brand images (nutripumplogo.webp)
│
├── lib/
│   ├── main.dart            # App entry point, Firebase init, Riverpod root
│   ├── firebase_options.dart # ⚠️ NOT in git — provision via CI/CD
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart        # Brand color palette
│   │   │   ├── app_typography.dart    # Text styles
│   │   │   ├── app_spacing.dart       # Spacing constants
│   │   │   └── app_theme.dart         # ThemeData configuration
│   │   ├── router/
│   │   │   ├── app_router.dart        # GoRouter route definitions
│   │   │   └── main_shell.dart        # Bottom navigation shell
│   │   ├── utils/
│   │   │   ├── formatters.dart        # Price, date formatters
│   │   │   └── validators.dart        # Form validation helpers
│   │   └── widgets/
│   │       ├── animated_enter.dart    # Reusable fade-slide animation
│   │       ├── custom_network_image.dart
│   │       ├── empty_state.dart       # Generic empty state widget
│   │       ├── loading_spinner.dart
│   │       ├── primary_button.dart    # Brand CTA button
│   │       └── product_card.dart      # Shared product card component
│   │
│   ├── features/
│   │   ├── account/          # Account dashboard, edit profile, addresses
│   │   ├── ai_chat/          # Gemini-powered AI chat bottom sheet
│   │   ├── auth/             # Login, register, verify email, forgot password
│   │   ├── cart/             # Cart screen + promo code sheet
│   │   ├── categories/       # Category browse screen
│   │   ├── checkout/         # Checkout + Razorpay payment
│   │   ├── contact/          # Contact form
│   │   ├── find_us/          # Physical store locator
│   │   ├── home/             # Home screen + announcement bar widget
│   │   ├── journal/          # Blog listing + article detail
│   │   ├── notifications/    # Notification centre + in-app popup
│   │   ├── orders/           # Order history + order detail
│   │   ├── our_story/        # Brand narrative page
│   │   ├── product_detail/   # Product detail + image gallery
│   │   ├── search/           # Search screen + voice search sheet
│   │   ├── shop/             # Shop grid + AI Gift Builder
│   │   ├── support/          # Help & support screen
│   │   ├── taste_profiler/   # Product recommendation quiz
│   │   └── wishlist/         # Saved / wishlisted products
│   │
│   ├── models/
│   │   ├── product.dart
│   │   ├── order.dart
│   │   ├── cart_item.dart
│   │   ├── user_profile.dart
│   │   ├── article.dart
│   │   ├── app_notification.dart
│   │   └── models.dart        # Barrel export
│   │
│   ├── providers/
│   │   ├── providers.dart     # Core service providers (auth, cart, etc.)
│   │   ├── cart_provider.dart
│   │   ├── promo_provider.dart
│   │   ├── notifications_provider.dart
│   │   ├── journal_provider.dart
│   │   └── inapp_popup_provider.dart
│   │
│   └── services/
│       ├── firebase/
│       │   ├── auth_service.dart      # Firebase Auth wrapper
│       │   ├── order_service.dart     # Order CRUD
│       │   ├── product_service.dart   # Product queries
│       │   └── misc_services.dart     # Settings, addresses, etc.
│       ├── api/
│       │   ├── ai_api.dart            # Gemini AI endpoint calls
│       │   └── checkout_api.dart      # Server-side checkout API
│       └── notification_service.dart  # FCM + local notification setup
│
├── test/
│   ├── unit/
│   │   ├── cart_notifier_test.dart
│   │   ├── cart_state_test.dart
│   │   └── shop_filters_test.dart
│   ├── widget/
│   │   └── checkout_order_summary_test.dart
│   └── helpers/
│       └── test_helpers.dart
│
├── android/                   # Android native project
├── ios/                       # iOS native project (Xcode workspace)
├── pubspec.yaml
└── analysis_options.yaml
```

---

## ⚙️ Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | `>= 3.22.0` |
| Dart SDK | `>= 3.4.0` |
| Xcode | `15+` (for iOS builds) |
| Android Studio | `Hedgehog+` (for Android builds) |
| Firebase Project | Blaze plan (for Storage & FCM) |
| CocoaPods | `>= 1.15` (for iOS dependencies) |

### 1. Clone the Repository

```bash
git clone https://github.com/NaveedBhat/nutripump_mobile.git
cd nutripump_mobile
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

```bash
cp .env.example .env
# Open .env and fill in all required values
```

### 4. Add Firebase Configuration Files

> ⚠️ These files contain API keys and are **not committed to git**. Obtain them from Firebase Console → Project Settings → Your Apps.

```
# Android
android/app/google-services.json

# iOS
ios/Runner/GoogleService-Info.plist
```

Then regenerate the Dart options file:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 5. iOS Setup

```bash
cd ios
pod install
cd ..
```

### 6. Run the App

```bash
# Debug mode
flutter run

# Specific device
flutter run -d "iPhone 15 Pro"
flutter run -d "Pixel 7"

# Release mode
flutter run --release
```

---

## 🔑 Environment Variables

Create a `.env` file in the project root (see `.env.example` for the template):

```env
# ─── Firebase (Client) ────────────────────────────────────────
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com

# ─── Razorpay ────────────────────────────────────────────────
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxxxxx

# ─── Backend API ─────────────────────────────────────────────
API_BASE_URL=https://your-nutripump-web.vercel.app
```

> ⚠️ Never commit `.env` to version control. It is excluded by `.gitignore`.

---

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run a specific test file
flutter test test/unit/cart_notifier_test.dart

# Analyze the codebase
flutter analyze
```

---

## 🏗️ Building for Production

### Android

```bash
# APK (direct install)
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
# Then open Xcode → Product → Archive → Distribute App
```

Or use Xcode directly:
```bash
open ios/Runner.xcworkspace
```

---

## 🎨 Design System

All UI is built using a custom, centralized design system:

| Token File | Purpose |
|------------|---------|
| `AppColors` | Brand palette — primary gold, deep charcoal, neutral cream |
| `AppTypography` | Text styles — display, heading, body, label sizes |
| `AppSpacing` | Consistent spacing scale (xs → xxl) |
| `AppTheme` | MaterialApp `ThemeData` — light mode with brand tokens |

| Color | Value | Usage |
|-------|-------|-------|
| `primary` | `#C6973F` | Buttons, accents, active states |
| `deepCharcoal` | `#1B180D` | Primary text |
| `neutralGold` | `#7A6A3E` | Secondary / muted text |
| `backgroundLight` | `#FAF8F3` | Page backgrounds |
| `success` | `#2D7A4A` | Success snackbars |
| `error` | `#C0392B` | Error snackbars, destructive actions |

---

## 💳 Test Payments (Razorpay)

Use the following test credentials in development:

| Method | Credentials |
|--------|------------|
| **Card** | `4111 1111 1111 1111` · Any future expiry · Any CVV |
| **UPI** | `success@razorpay` |
| **Net Banking** | Select any bank → use test credentials shown |

---

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feat/your-feature`
3. **Commit** using conventional commits: `git commit -m "feat: add voice search to shop screen"`
4. **Push** and **open a Pull Request**

### Commit Convention

| Prefix | Purpose |
|--------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `chore:` | Tooling, dependencies |
| `style:` | Formatting, no logic change |
| `refactor:` | Code restructuring |
| `test:` | Adding or updating tests |
| `docs:` | Documentation |

---

## 🗺️ Roadmap

| Feature | Status |
|---------|--------|
| Core shopping flow (browse → cart → checkout) | ✅ Complete |
| Firebase Auth (email + Google) | ✅ Complete |
| Push notifications (FCM) | ✅ Complete |
| AI Chat (Gemini) | ✅ Complete |
| Voice Search | ✅ Complete |
| Promo Codes with eligibility checks | ✅ Complete |
| Return Request flow | ✅ Complete |
| Security — change password with re-auth | ✅ Complete |
| Android release build & Play Store listing | ⏳ Planned |
| iOS release build & App Store listing | ⏳ Planned |
| Dark mode support | 🔲 Backlog |
| Product reviews submission | 🔲 Backlog |
| Loyalty / points system | 🔲 Backlog |

---

## 📄 License

This project is **proprietary software**. All rights reserved.

© 2026 NutriPump Artisanal. Unauthorized copying, modification, or distribution is strictly prohibited.

---

## 👥 Authors

<div align="center">

Built with ❤️ from the Heart of Kashmir

| Name | Role |
|------|------|
| **Naveed Mohammad Bhat** | Co-Founder & Lead Developer |
| **Nadeem Mohammad Bhat** | Co-Founder |
| **Tayab Sarwar** | Co-Founder |

<br />

*NutriPump Artisanal — Est. 2024 · Srinagar, Kashmir*

</div>
