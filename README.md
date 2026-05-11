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

## 📖 The Platform Ecosystem

**NutriPump Artisanal** is a production-grade, multi-platform e-commerce ecosystem designed to bring premium, authentic natural products from the Kashmir Valley — such as stone-ground nut butters, wildflower honey, and cold-pressed oils — to a global audience. 

The ecosystem is architected as a **unified platform** comprising a web application, a native mobile app, and a shared serverless backend. This ensures seamless real-time data synchronization across all touchpoints, providing a consistent experience for customers and a centralized management hub for administrators.

### 1. The Native Mobile App (This Repository)
The mobile companion is built entirely in **Flutter**, utilizing an **MVVM + Service Layer** architecture powered by **Riverpod**. It shares the exact same database as the web platform but is tailored for a native, on-the-go experience.
- Features mobile-exclusive capabilities such as an **AI-powered Voice Chat Assistant** (using NLP for product recommendations) and deep-linked **Firebase Cloud Messaging (FCM)** push notifications.
- Maintains complete feature parity with the web, including Razorpay checkout, real-time order tracking, address book management (with GPS auto-fill), and profile management.

### 2. The Web Platform (Storefront & Admin CMS)
> 💻 **Website:** [nutripump.store](https://nutripump.store)

Built with **Next.js 14 (App Router)** and **Tailwind CSS**, the web platform serves two primary functions:
- **Premium Customer Storefront**: An SEO-optimized, highly interactive e-commerce storefront featuring dynamic URL-synced filtering, a slide-out cart, guest/user checkout flows, and seamless Razorpay integration. 
- **Custom Admin CMS**: A role-protected, fully responsive dashboard built directly into the web app (`/admin`). It empowers non-technical staff to run the entire business—from real-time order fulfillment and inventory tracking to dynamic storefront banner updates and category reordering—without requiring third-party headless CMS subscriptions or code redeployments.

### 3. The Unified Backend & Data Layer
Both the Web and Mobile clients are powered by the same secure, serverless infrastructure:
- **Real-time Database (Cloud Firestore)**: Acts as the single source of truth. Products, orders, users, reviews, and store settings are streamed in real-time to all connected web and mobile clients simultaneously.
- **Secure API Hub (Next.js API Routes)**: The web platform's API (`/api/checkout/*`, `/api/ai/*`) acts as the authoritative backend for *both* the web storefront and this mobile app. It securely handles Razorpay order creation, HMAC signature verification, promotional code validation, and AI processing. This ensures that critical business logic, price calculations, and secrets are strictly enforced on the server and never exposed to the client.

---
### About Project
Architected, designed, and developed the **NutriPump Ecosystem** from the ground up. From a business perspective, NutriPump is a premium e-commerce platform designed to bridge authentic, artisanal Kashmiri food products—like stone-ground nut butters and wildflower honey—with a global audience.

To achieve this, I didn't just build a simple website; I engineered a **unified, multi-platform ecosystem** consisting of three tightly integrated clients, all communicating in real-time with a centralized serverless backend:

1. **The Premium Customer Web Storefront (Next.js 14):**
   I built a highly interactive, SEO-optimized web application using Next.js App Router and Tailwind CSS. To give it a premium, native feel on the web, I used **Framer Motion** for glassmorphic animations and interactive elements (like our signature Honey Wheel). For complex persistent state—such as ensuring a user's shopping cart survives page refreshes without server lag—I utilized **Zustand** connected to local storage.
2. **The Custom Admin CMS (Built into Next.js):**
   Instead of paying a monthly premium for a third-party service like Shopify, I engineered a bespoke, role-protected Admin Dashboard directly into the web application. This empowers non-technical staff to run the entire business from their phones or laptops. They can manage inventory stock, process orders, review analytics, and dynamically update storefront hero banners—all without requiring a single code redeployment from me.
3. **The Native Mobile App (Flutter for iOS & Android):**
   I built a production-grade mobile companion using Flutter. It is designed with a strict **MVVM architecture** powered by **Riverpod** for compile-time safe state management. It delivers a deeply native experience by offering features that are impossible on the web, including an **AI-powered Voice Chat Assistant** (using Speech-to-Text and NLP for product recommendations), persistent offline data caching using **Hive NoSQL**, and rich background push notifications via **Firebase Cloud Messaging (FCM)**.

## 🏗 Architecture

NutriPump Mobile is built using a **Feature-First Clean Architecture** pattern, combining concepts from Clean Architecture and Domain-Driven Design, adapted for Flutter + Riverpod.

### Architectural Layers

```
┌─────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                       │
│   lib/features/<name>/                                         │
│   • *_screen.dart  — ConsumerWidget / ConsumerStatefulWidget  │
│   • widgets/       — Pure/stateless extracted UI components    │
└────────────────────────────┬────────────────────────────────-┘
                             │ watches / reads
┌────────────────────────────▼────────────────────────────────┐
│                       STATE LAYER (Riverpod)                   │
│   lib/providers/                                               │
│   • providers.dart         — StreamProvider, FutureProvider,  │
│                              StateNotifierProvider             │
│   • cart_provider.dart     — CartNotifier (Hive persistence)  │
│   • theme_provider.dart    — ThemeNotifier                    │
│   • journal_provider.dart  — JournalNotifier                  │
│   • notifications_provider — NotificationsNotifier (Hive)     │
└────────────────────────────┬────────────────────────────────-┘
                             │ calls
┌────────────────────────────▼────────────────────────────────┐
│                       SERVICE LAYER                            │
│   lib/services/                                               │
│   ├── firebase/                                               │
│   │   • auth_service.dart      — Firebase Auth + Firestore   │
│   │   • product_service.dart   — Firestore product queries   │
│   │   • order_service.dart     — Firestore order streams     │
│   │   • misc_services.dart     — Categories, Settings, etc.  │
│   ├── api/                                                    │
│   │   • checkout_api.dart      — Dio → Next.js REST API      │
│   │   • ai_api.dart            — Dio → AI chat endpoint      │
│   └── notification_service.dart — FCM + local notifications  │
└────────────────────────────┬────────────────────────────────-┘
                             │ uses
┌────────────────────────────▼────────────────────────────────┐
│                       DATA / MODEL LAYER                       │
│   lib/models/                                                 │
│   • product.dart / order.dart / cart_item.dart                │
│   • user_profile.dart / article.dart / app_notification.dart  │
│   • models.dart  — StoreSettings, Category, Review, etc.     │
└─────────────────────────────────────────────────────────────┘
```

### Design Pattern: MVVM + Service Layer

NutriPump Mobile uses **MVVM (Model–View–ViewModel)** with an additional **Service Layer** — the standard, production-grade architecture pattern for large Flutter + Riverpod applications.

#### MVVM Layer Mapping

| MVVM Layer | Role | In This Project |
|---|---|---|
| **Model** | Data structures — pure Dart classes, no UI | `lib/models/` — `Product`, `Order`, `CartItem`, `UserProfile`, `StoreSettings`, etc. |
| **ViewModel** | Holds state, exposes it to the View, contains no UI code | `lib/providers/` — All Riverpod providers: `CartNotifier`, `ShopFiltersNotifier`, `ThemeNotifier`, `StreamProvider`, `FutureProvider` |
| **View** | Pure UI — observes the ViewModel and rebuilds | `lib/features/**/screen.dart` + `widgets/` — `ConsumerWidget` screens using `ref.watch()` |
| **Service Layer** *(+1 beyond classic MVVM)* | Abstracts data sources from the ViewModel | `lib/services/` — Firebase services (`AuthService`, `ProductService`, `OrderService`) and REST API clients (`CheckoutApi`, `AiApi`) |

#### Why Riverpod IS the ViewModel

In traditional MVVM (Android/iOS), a ViewModel:
- Holds and mutates state → **`StateNotifier<T>`** does exactly this
- Exposes data as observable streams → **`StreamProvider` / `FutureProvider`**
- The View observes and rebuilds automatically → **`ref.watch(provider)` in `ConsumerWidget`**
- Contains zero UI code → **providers are pure Dart classes**

Your `CartNotifier`, `ShopFiltersNotifier`, and `ThemeNotifier` **are ViewModels** — written as Riverpod `StateNotifier`s. The `StreamProvider`s wrapping Firestore streams are **observable ViewModel data streams**.

#### Why Not the Others?

| Pattern | Why NutriPump does NOT use it |
|---|---|
| **MVC** | In MVC the Controller handles input AND updates the Model directly. Here, screens never touch services — they only call `ref.read(provider.notifier).method()`. No Controller class exists |
| **MVP** | In MVP the Presenter holds a direct reference to the View and calls methods on it. Riverpod providers never know which screen is watching them — zero coupling |
| **Clean Architecture** | True Clean Architecture requires separate "Use Case" / "Interactor" classes between providers and services. This project intentionally skips that extra layer for pragmatic simplicity |
| **BLoC** | BLoC requires explicit `Event` → `Bloc` → `State` stream chains. `StateNotifier` achieves the same result with less boilerplate |

#### Full Data Flow

```
┌──────────────────────────────────────────┐
│  VIEW  (ConsumerWidget Screens + Widgets) │
│  ref.watch(provider)  →  UI rebuilds      │
│  ref.read(notifier).method()  →  actions  │
└────────────────┬─────────────────────────┘
                 │
┌────────────────▼─────────────────────────┐
│  VIEWMODEL  (Riverpod Providers)          │
│  StateNotifier  /  StreamProvider         │
│  FutureProvider  /  StateProvider         │
└────────────────┬─────────────────────────┘
                 │
┌────────────────▼─────────────────────────┐
│  SERVICE LAYER                            │
│  Firebase: AuthService, ProductService,   │
│            OrderService, MiscServices     │
│  REST API: CheckoutApi (Dio), AiApi (Dio) │
│  Local:    NotificationService            │
└────────────────┬─────────────────────────┘
                 │
┌────────────────▼─────────────────────────┐
│  DATA SOURCES                             │
│  Cloud Firestore  /  Next.js REST API     │
│  Hive (local)     /  Razorpay SDK         │
└──────────────────────────────────────────┘
```

---

### Key Architectural Decisions

| Decision | Rationale |
|---|---|
| **Feature-first directory layout** | Each feature (`account`, `shop`, `checkout`, etc.) is self-contained with its own screen files and `widgets/` subfolder |
| **Riverpod as the single source of truth** | All app state — auth, cart, products, orders, theme — flows through Riverpod providers. No `setState` in top-level logic |
| **Services are plain Dart classes, not singletons** | Instantiated via `Provider<T>` so Riverpod controls their lifecycle and they're easily testable |
| **Backend-authoritative payments** | Order amount is always calculated server-side (Node.js/Razorpay). The client never computes final price — preventing client-side manipulation |
| **Dual data source** | Firestore for real-time streams (orders, products, addresses). REST API (Dio) for transactional write operations (checkout, AI) |
| **StatefulShellRoute navigation** | GoRouter's `StatefulShellRoute.indexedStack` preserves the scroll position and state of each bottom-nav tab independently |
| **Responsive scaling system** | A custom `AppScale` + `R` (responsive) utility locks the design width to 390px and proportionally scales all spacing/fonts across screen sizes |

---

## ✨ Features

### 🛒 Shopping & Discovery
- **Home screen** with hero banners, featured products, category quick-links, and a live announcement banner from the admin panel
- **Shop screen** with real-time search, multi-filter (category, price range slider, origin), and multi-sort (featured, newest, price, rating)
- **Product Detail** with image carousel, weight variant selector, bundle pricing, stock badge, and customer reviews
- **Categories** page with a dynamically admin-controlled hero banner (Firestore-driven)
- **Wishlist** with persistent Hive storage across sessions

### 🤖 AI Chat Assistant
- Voice-to-text input via `speech_to_text`
- `POST /api/ai/chat` to a custom NLP endpoint on the Next.js backend
- AI responses include product recommendations rendered as tappable product cards

### 🧾 Checkout & Payments
- **Razorpay** online payment (UPI, Card, Netbanking, Wallet)
- **Cash-on-Delivery** order flow
- Server-side order creation and HMAC signature verification — payment is never trusted from the client
- Promo code validation (server-enforced, one-use-per-user)
- Abandoned order auto-cancellation on payment dismissal
- Address management with GPS auto-fill (Geolocator + Geocoding)

### 📦 Orders & Returns
- Real-time order tracking via Firestore `StreamProvider`
- Order detail page with timeline status, item list, and address
- Return request flow with admin-configurable return window and per-reason selection
- Filter + search orders by date range and status

### 🔐 Authentication
- Email/Password login & registration with email verification gate
- Google Sign-In (OAuth 2.0 via `google_sign_in`)
- Forgot password / reset flow
- Protected route guard in GoRouter using `FirebaseAuth.instance.authStateChanges()`
- Admin role check (`isAdmin` field on Firestore user doc) for admin portal redirect

### 🔔 Push Notifications
- Firebase Cloud Messaging (FCM) — foreground, background, and terminated states
- Deep-link routing on notification tap (navigates to `/orders/:id`, `/product/:slug`, etc.)
- Local notification persistence in Hive — notification inbox survives app restarts
- Android custom notification icon and color configured in `AndroidManifest.xml`

### 👤 Account & Profile
- Edit profile (display name, phone, avatar)
- Password change and email security
- Address book (add/edit/delete/set-default with GPS auto-fill)
- Theme selector (Light / Dark / System) persisted via Hive
- App version display via `package_info_plus`

### 📋 Content & Legal
- **Journal** (blog articles from Firestore)
- **Our Story**, **Contact**, **Find Us**, **Taste Profiler**
- **Support** screen with order-linked ticket submission
- **Privacy Policy** and **Terms of Service** (Firestore-driven, live editable from admin)

---

## 🛠 Tech Stack

### At a Glance

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.22+ · Dart 3.4+ |
| **Architecture** | MVVM + Service Layer |
| **State Management** | Riverpod 2.x (`StateNotifier`, `StreamProvider`, `FutureProvider`) |
| **Navigation** | GoRouter 14.x (`StatefulShellRoute`) |
| **Database** | Cloud Firestore (real-time) |
| **Authentication** | Firebase Auth · Google Sign-In |
| **Payments** | Razorpay Flutter SDK |
| **Push Notifications** | Firebase Cloud Messaging (FCM) · flutter_local_notifications |
| **Crash Reporting** | Firebase Crashlytics |
| **REST API Client** | Dio 5.x |
| **Local Storage** | Hive Flutter |
| **Location** | Geolocator · Geocoding |
| **Voice Input** | speech_to_text |
| **UI / Animations** | Google Fonts · flutter_animate · skeletonizer · cached_network_image |
| **Forms** | reactive_forms |
| **Environment Config** | flutter_dotenv |
| **Internationalization** | intl |

---

### Core Framework

| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | `>=3.22.0` | Cross-platform UI framework |
| **Dart** | `>=3.4.0` | Programming language |
| **Material 3** | Built-in | Design system (custom-themed) |

### Backend & Database
| Technology | Version | Purpose |
|---|---|---|
| **Cloud Firestore** | `^5.6.0` | Primary real-time database (products, orders, addresses, users, content) |
| **Firebase Auth** | `^5.5.0` | Authentication (email/password + Google OAuth) |
| **Firebase Messaging** | `^15.2.5` | Push notifications (FCM) |
| **Firebase Crashlytics** | `^4.3.0` | Production crash reporting |
| **Firebase Core** | `^3.13.0` | Firebase SDK initialization |
| **Next.js REST API** | Custom | Checkout, payment verification, AI chat, promo validation (`nutripump.store/api/*`) |

### State Management & Navigation
| Technology | Version | Purpose |
|---|---|---|
| **flutter_riverpod** | `^2.5.0` | State management — `StreamProvider`, `FutureProvider`, `StateNotifierProvider`, `Provider` |
| **riverpod_annotation** | `^2.5.0` | Code generation annotations |
| **riverpod_generator** | `^2.5.0` | Dev: generates provider boilerplate |
| **go_router** | `^14.2.0` | Declarative routing with guards, deep links, `StatefulShellRoute` for bottom nav |

### Payments
| Technology | Version | Purpose |
|---|---|---|
| **razorpay_flutter** | `^1.4.5` | Native Razorpay payment SDK (UPI, Card, Netbanking, Wallet, COD) |

### Networking
| Technology | Version | Purpose |
|---|---|---|
| **dio** | `^5.7.0` | HTTP client for REST API calls (checkout + AI endpoints) with custom interceptors |
| **flutter_dotenv** | `^5.1.0` | `.env` file for `API_BASE_URL` and `RAZORPAY_KEY_ID` |

### Local Storage
| Technology | Version | Purpose |
|---|---|---|
| **hive_flutter** | `^1.1.0` | Offline-first local persistence — cart, wishlist, notifications, settings |

### Location & Permissions
| Technology | Version | Purpose |
|---|---|---|
| **geolocator** | `^13.0.2` | GPS location for address auto-fill |
| **geocoding** | `^3.0.0` | Reverse geocoding (lat/lng → street address) |
| **permission_handler** | `^12.0.1` | Runtime permission requests (location, microphone) |

### UI & Styling
| Technology | Version | Purpose |
|---|---|---|
| **google_fonts** | `^6.1.0` | Custom typography (Outfit, Inter) |
| **cached_network_image** | `^3.3.0` | Disk-cached image loading with placeholder |
| **smooth_page_indicator** | `^1.1.0` | Image carousel dot indicators |
| **flutter_animate** | `^4.5.2` | Declarative micro-animations |
| **skeletonizer** | `^2.1.3` | Skeleton loading screens |
| **Custom `AppScale` + `R` system** | Internal | Responsive scaling — locks design to 390px base, proportionally scales spacing, font sizes, and radii |

### Forms & Validation
| Technology | Version | Purpose |
|---|---|---|
| **reactive_forms** | `^17.0.0` | Typed, reactive form groups with validators |

### Utilities
| Technology | Version | Purpose |
|---|---|---|
| **speech_to_text** | `^7.0.0` | Voice input for AI chat assistant |
| **intl** | `^0.19.0` | Date formatting, number/currency formatting, localization |
| **url_launcher** | `^6.3.0` | Open mailto, browser, external URLs |
| **share_plus** | `^13.1.0` | Native OS share sheet for products/articles |
| **uuid** | `^4.5.3` | UUID generation for cart items, notifications |
| **timeago** | `^3.7.1` | "2 hours ago" relative time formatting |
| **package_info_plus** | `^10.1.0` | App version/build number display |
| **flutter_local_notifications** | `^18.0.1` | Local notification display and channel management |

### Developer Tools
| Technology | Version | Purpose |
|---|---|---|
| **build_runner** | `^2.4.0` | Code generation runner |
| **mockito** | `^5.4.4` | Unit test mocking |
| **flutter_lints** | `^4.0.0` | Dart linting rules |
| **flutter_launcher_icons** | `^0.13.0` | Generates adaptive launcher icons |
| **flutter_native_splash** | `^2.3.0` | Generates native splash screen |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase init, Hive init,
│                                # FCM background handler, global NavigatorKey
│
├── firebase_options.dart        # Auto-generated Firebase platform config
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Brand color palette (light + dark tokens)
│   │   ├── app_typography.dart  # Context-aware text styles (h1–h3, body, label)
│   │   ├── app_theme.dart       # Full MaterialTheme light + dark definitions
│   │   └── app_spacing.dart     # Spacing constants
│   │
│   ├── router/
│   │   ├── app_router.dart      # GoRouter config: all 30+ routes, auth guards
│   │   └── main_shell.dart      # StatefulShellRoute bottom nav shell
│   │
│   ├── utils/
│   │   ├── responsive.dart      # R.w(), R.h(), R.sp() responsive helpers
│   │   ├── app_scale.dart       # InheritedWidget for global scale factor
│   │   ├── formatters.dart      # formatPrice(), formatOrderId(), date helpers
│   │   └── validators.dart      # Email, phone, pincode, password validators
│   │
│   └── widgets/                 # Shared UI components
│       ├── product_card.dart    # Reusable product card (shop, search, wishlist)
│       ├── skeleton_loaders.dart # 15+ skeleton placeholder variants
│       ├── custom_network_image.dart
│       ├── animated_enter.dart
│       ├── empty_state.dart
│       ├── loading_spinner.dart
│       └── primary_button.dart
│
├── models/
│   ├── product.dart             # Product, ProductVariant, BundleTier
│   ├── order.dart               # Order, OrderItem, OrderStatus enum
│   ├── cart_item.dart           # CartItem, Address
│   ├── user_profile.dart        # UserProfile (Firestore user doc)
│   ├── article.dart             # Journal article
│   ├── app_notification.dart    # In-app notification model
│   └── models.dart              # StoreSettings, Category, Review, StoreSettings,
│                                # PaymentSettings, AnnouncementSettings, etc.
│
├── providers/
│   ├── providers.dart           # Core providers: auth, products, orders,
│   │                            # addresses, shop filters, store settings
│   ├── cart_provider.dart       # CartNotifier — Hive-backed cart state
│   ├── theme_provider.dart      # ThemeNotifier — Hive-persisted theme
│   ├── journal_provider.dart    # JournalNotifier — Firestore blog articles
│   ├── legal_provider.dart      # privacyPageProvider, termsPageProvider
│   ├── notifications_provider.dart # NotificationsNotifier (Hive inbox)
│   ├── promo_provider.dart      # PromoNotifier — promo code state
│   └── inapp_popup_provider.dart # In-app popup/announcement state
│
├── services/
│   ├── firebase/
│   │   ├── auth_service.dart    # signIn, signUp, Google auth, profile stream
│   │   ├── product_service.dart # getFeaturedProducts, getProductBySlug, search
│   │   ├── order_service.dart   # userOrdersStream, orderStream, requestReturn
│   │   └── misc_services.dart   # CategoryService, SettingsService, ReviewService,
│   │                            # AddressService, WishlistService, PromoCodeService
│   ├── api/
│   │   ├── checkout_api.dart    # Dio client: createOrder, verifyPayment,
│   │   │                        # createCodOrder, cancelOrder
│   │   └── ai_api.dart          # Dio client: sendMessage (AI chat)
│   └── notification_service.dart # FCM setup, local channels, tap-routing
│
└── features/
    ├── home/                    # Home screen + hero banner
    ├── shop/                    # Product listing, filters, sorting
    │   └── widgets/
    ├── product_detail/          # Product page, reviews, cart add
    │   └── widgets/
    ├── categories/              # Category grid with Firestore banner
    ├── search/                  # Search + voice input
    ├── cart/                    # Cart, promo codes
    ├── checkout/                # Address selection, payment flow
    │   └── widgets/
    ├── orders/                  # Order list (filter/search), order detail
    │   └── widgets/
    ├── wishlist/                # Wishlist screen
    ├── ai_chat/                 # AI assistant chat UI
    ├── notifications/           # In-app notification inbox
    ├── account/                 # Account hub, profile, addresses, returns
    │   └── widgets/
    │       ├── account/         # ProfileCard, StatsRow, AccountNavTile, ThemeSelection
    │       ├── address_book/    # AddressCard, AddressFormSheet
    │       └── return_request/  # ReturnOrderSelectionCard, ReturnReasonTile
    ├── auth/                    # Login, Register, ForgotPassword, VerifyEmail
    ├── legal/                   # Privacy Policy, Terms of Service
    │   └── widgets/             # LegalHeroBanner, LegalSectionWidget, LegalContactBlock, etc.
    ├── support/                 # Support ticket screen
    ├── journal/                 # Blog article list + detail
    ├── contact/                 # Contact form
    ├── find_us/                 # Store locator / map
    ├── our_story/               # Brand story page
    └── taste_profiler/          # Taste preference quiz
```

---

## 🔄 Data Flow

### Authentication Flow
```
App Start
  → Firebase.initializeApp()
  → authStateChangesProvider (StreamProvider<User?>)
  → authStateProvider (StreamProvider<UserProfile?>) — streams live Firestore profile
  → GoRouter redirect guard — blocks /checkout, /account, /orders if not logged in
```

### Checkout Payment Flow
```
User taps "Place Order"
  → CheckoutApi.createOrder() → POST /api/checkout/create-order
  → Backend validates items, computes price (GST + shipping + promo), creates Razorpay order
  → Backend returns { orderId, firestoreOrderId, amount }
  → App opens Razorpay SDK with server-provided amount (never client-computed)
  → On payment success: CheckoutApi.verifyPayment() → POST /api/checkout/verify
  → Backend HMAC-verifies Razorpay signature, marks Firestore order as PAID
  → App navigates to order confirmation screen
```

### Real-Time Order Tracking
```
OrdersScreen
  → userOrdersProvider(userId) — StreamProvider.family
  → OrderService.userOrdersStream(userId) — Firestore snapshot stream
  → UI rebuilds live whenever admin updates order status in the dashboard
```

### Cart Persistence
```
CartNotifier (StateNotifier)
  → All mutations immediately written to Hive box ('nutripump_cart')
  → On app start, Hive box is read in main() before runApp()
  → Cart survives app restarts, even without network
```

---

## ⚙️ Environment Setup

### Prerequisites
- Flutter SDK `>=3.22.0`
- Dart SDK `>=3.4.0`
- Android Studio / Xcode
- Firebase project with iOS & Android apps registered
- Active Razorpay account (test or live keys)

### 1. Clone & Install
```bash
git clone https://github.com/NutriPump/nutripump_mobile.git
cd nutripump_mobile
flutter pub get
```

### 2. Environment Variables
Create a `.env` file in the project root:
```env
API_BASE_URL=https://www.nutripump.store
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxxxxxx
```

> ⚠️ The app will throw an exception on startup if these keys are missing or empty.

### 3. Firebase Configuration
- Place your `google-services.json` in `android/app/`
- Place your `GoogleService-Info.plist` in `ios/Runner/`
- The `firebase_options.dart` file is auto-generated and already committed

### 4. Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run
```bash
# Debug
flutter run

# Release (Android)
flutter build apk --release

# Release (iOS)
flutter build ios --release
```

### 6. Generate Icons & Splash
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 🔑 Key Providers Reference

| Provider | Type | Description |
|---|---|---|
| `authStateProvider` | `StreamProvider<UserProfile?>` | Live Firestore user profile, null when signed out |
| `authStateChangesProvider` | `StreamProvider<User?>` | Raw Firebase auth state |
| `isAdminProvider` | `Provider<bool>` | True if current user has `isAdmin: true` in Firestore |
| `storeSettingsProvider` | `StreamProvider<StoreSettings>` | Live store config (emails, policies, features) |
| `paymentSettingsProvider` | `StreamProvider<PaymentSettings>` | Live payment method config (COD on/off, etc.) |
| `cartProvider` | `StateNotifierProvider<CartNotifier, CartState>` | Hive-backed cart with item quantity management |
| `shopFiltersProvider` | `StateNotifierProvider<ShopFiltersNotifier, ShopFilters>` | Category, price, origin, sort filters |
| `filteredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Derived — all products filtered client-side |
| `userOrdersProvider(uid)` | `StreamProvider.family<List<Order>, String>` | Live Firestore orders for a user |
| `userAddressesProvider(uid)` | `StreamProvider.family<List<Address>, String>` | Live Firestore addresses for a user |
| `themeProvider` | `StateNotifierProvider<ThemeNotifier, ThemeMode>` | Hive-persisted Light/Dark/System theme |
| `scrollTabEventProvider` | `StateProvider<int?>` | Emits tab index on re-tap → triggers scroll-to-top |

---

## 📱 Platform Support

| Platform | Min Version | Build Status |
|---|---|---|
| **Android** | API 21 (Android 5.0) | ✅ Production |
| **iOS** | iOS 13.0 | ✅ Production |

### Android Permissions
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />      <!-- Voice input -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />   <!-- GPS address -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" /> <!-- GPS address -->
```

### iOS (Info.plist keys)
- `NSMicrophoneUsageDescription` — Voice-to-text for AI chat
- `NSLocationWhenInUseUsageDescription` — Address auto-fill
- `NSLocationAlwaysAndWhenInUseUsageDescription` — Address auto-fill

---

## 🎨 Design System

The app uses a fully custom design system defined in `lib/core/constants/`:

- **Color palette** — Warm gold (`#C9A84C`), Deep Charcoal (`#1C1C1E`), and surface/background tokens for light and dark modes
- **Typography** — Context-aware `AppTypography` methods (e.g. `AppTypography.h3(context)`) that scale with the `AppScale` factor
- **Responsive system** — `R.w(context, n)`, `R.h(context, n)`, `R.sp(context, n)` scale all values relative to the 390px base design width, clamped between 0.82× and 1.1× for tablets and small phones
- **Themes** — Full `ThemeData` for light and dark modes including `ColorScheme`, `TextTheme`, `InputDecoration`, `CardTheme`, `AppBarTheme`, `BottomNavigationBarTheme`, and more

---

## 🔒 Security

- Payment amounts are **never computed client-side** — the backend is the sole authority
- Razorpay payment signature is **HMAC-verified server-side** before any order is marked paid
- Firebase Auth **JWT tokens** are automatically refreshed by the Firebase SDK
- Protected routes (`/checkout`, `/account`, `/orders`) redirect unauthenticated users to login
- Environment secrets (API URLs, Razorpay keys) are loaded from `.env` at runtime and are **not committed to version control**
- Firebase Crashlytics captures all uncaught Flutter and platform errors in production

---

## 📄 License

This project is **proprietary and confidential**. All rights reserved by NutriPump Artisanal.
Unauthorized copying, distribution, or use of this software is strictly prohibited.

---

<div align="center">

Made with ❤️ for Kashmir's finest artisanal products.

**[nutripump.store](https://nutripump.store)** | **[Instagram](https://instagram.com/nutripump)** | **contact@nutripump.in**

</div>
