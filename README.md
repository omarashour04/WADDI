# 🎮 WADDI Platform - Gaming Venue Booking Application

A comprehensive, production-ready Flutter application for booking gaming venues and rooms. Built with modern architecture patterns, Firebase backend services, Riverpod state management, and GoRouter navigation. This application provides a complete solution for gaming venue management, user authentication, booking systems, and real-time data synchronization.

## 📋 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [Tech Stack](#tech-stack)
5. [Installation](#installation)
6. [Configuration](#configuration)
7. [Project Structure](#project-structure)
8. [State Management](#state-management)
9. [Navigation](#navigation)
10. [UI/UX Design](#uiux-design)
11. [Firebase Integration](#firebase-integration)
12. [Performance Optimization](#performance-optimization)
13. [Security](#security)
14. [Testing](#testing)
15. [Deployment](#deployment)
16. [API Documentation](#api-documentation)
17. [Troubleshooting](#troubleshooting)
18. [Contributing](#contributing)
19. [License](#license)

## 🚀 Features

### 🏠 **Home Page (Venues Page)**
- **Featured Venues Section**: Displays top venues with dynamic image loading from Firebase Storage
- **Search Bar**: Redirects to dedicated search page with query parameters
- **Modern UI**: Responsive venue cards with aspect ratio images, gradient backgrounds
- **Responsive Layout**: Adapts to different screen sizes with MediaQuery-based sizing
- **Loading States**: Skeleton loading with shimmer effects for better UX
- **Error Handling**: Graceful error states with retry functionality
- **Theme Adaptation**: Text colors adapt to light/dark mode

### 🔍 **Search Page**
- **Dedicated Search Functionality**: Full-featured search with real-time results
- **Advanced Filtering**: Price range, rating, amenities, game types
- **Location-Based Search**: Geocoding integration for venue discovery
- **Real-Time Results**: Live updates as user types
- **Filter Dialog**: Comprehensive filtering options with visual feedback
- **Search History**: Cached search queries for quick access
- **Empty States**: Helpful messages when no results found

### 📅 **Booking System**
- **Complete Booking Flow**: Step-by-step booking process with room selection
- **Room Selection**: Visual room cards with local asset images and descriptions
- **Date & Time Selection**: Intuitive date/time picker
- **Duration Selection**: Flexible booking duration options
- **Price Calculation**: Real-time price updates based on selections
- **Booking Confirmation**: Success page with booking details and action buttons
- **Booking Details Page**: Comprehensive booking information with venue/room details
- **Booking History**: Complete booking management with navigation to details
- **Cancellation Policy**: Clear cancellation terms with Firestore updates
- **Calendar Integration**: Add bookings to Google Calendar via URL launcher

### 👤 **User Management**
- **Firebase Authentication**: Secure user authentication with email/password
- **Guest Mode**: Anonymous authentication for non-registered users with browsing limitations
- **User Registration**: Complete registration flow with validation
- **Password Reset**: Secure password recovery system accessible to authenticated users
- **Change Password**: Functional password change with Firebase Auth integration
- **Profile Management**: Modern profile page with account options and support tickets
- **Support Tickets**: Integrated support system with ticket management
- **Session Persistence**: Automatic login state restoration
- **Guest Limitations**: Guest users can browse but cannot book or access profile

### 🎯 **Venue Management**
- **Venue Details**: Comprehensive venue information with dynamic image loading
- **Image Galleries**: Multiple venue images with Firebase Storage integration
- **Amenities Display**: Visual amenities with icons
- **Room Selection**: Interactive room selection interface with visual cards
- **Real-Time Availability**: Live availability checking
- **Review System**: User reviews and ratings
- **Venue Owner Features**: Special features for venue owners
- **Room Management**: CRUD operations for rooms
- **Contact Integration**: Phone calls and email via URL launcher
- **Directions**: Google Maps integration for venue directions

### 🎨 **UI/UX Features**
- **Light/Dark Mode**: Theme toggle with persistent state, dark grey/black colors
- **Responsive Design**: Adapts to all screen sizes with MediaQuery
- **Native Phone Fonts**: Uses device's native font family
- **Consistent Theming**: Unified design system across all pages
- **Bottom Navigation**: Persistent navigation bar
- **Loading Animations**: Smooth loading states with skeleton loaders
- **Error States**: User-friendly error messages
- **Accessibility**: Screen reader support and accessibility features
- **Animations**: Smooth page transitions and micro-interactions
- **Global Back Button**: Native Android back button/swipe gesture handling

### 💳 **Payment System**
- **PayMob Integration**: Secure payment processing
- **Multiple Payment Methods**: Credit cards, digital wallets
- **Payment Status Tracking**: Real-time payment status updates
- **Receipt Generation**: Digital receipts for bookings
- **Refund Processing**: Automated refund handling

### 🔔 **Notifications**
- **Push Notifications**: Firebase Cloud Messaging integration
- **Booking Reminders**: Automated booking reminders
- **Status Updates**: Real-time booking status notifications
- **Promotional Notifications**: Marketing and promotional messages
- **In-App Notifications**: Local notification handling

### 📊 **Analytics & Reporting**
- **User Analytics**: User behavior tracking
- **Booking Analytics**: Booking pattern analysis
- **Venue Performance**: Venue-specific analytics
- **Revenue Tracking**: Financial reporting and analytics
- **Admin Dashboard**: Comprehensive admin interface
- **Crashlytics**: Firebase Crashlytics for error reporting

### 🆘 **Support System**
- **Help Center**: Dedicated help center page with placeholder actions
- **Support Tickets**: Ticket management system
- **FAQ Page**: Frequently asked questions
- **Contact Form**: Direct contact with support team

## 🏗️ Architecture

### **Clean Architecture Pattern**
The application follows Clean Architecture principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │    Pages    │ │   Widgets   │ │  Providers  │        │
│  └─────────────┘ └─────────────┘ └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │  Entities   │ │ Use Cases   │ │ Repositories│        │
│  └─────────────┘ └─────────────┘ └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │ DataSources │ │ Repositories│ │   Models    │        │
│  └─────────────┘ └─────────────┘ └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### **Feature-First Organization**
Each feature is self-contained with its own:
- **Domain Layer**: Entities, use cases, repositories
- **Data Layer**: Data sources, repository implementations
- **Presentation Layer**: Pages, widgets, providers

### **Dependency Injection**
- **Riverpod**: Primary dependency injection solution
- **Provider Pattern**: Clean separation of concerns
- **Repository Pattern**: Abstract data access layer

## 🛠️ Tech Stack

### **Frontend Framework**
- **Flutter 3.8.1+**: Cross-platform UI framework
- **Dart 3.0+**: Programming language
- **Material Design 3**: Modern UI components
- **Cupertino Icons**: iOS-style icons

### **State Management**
- **Riverpod 2.5.1**: Modern state management
- **Riverpod Generator**: Code generation for providers
- **Consumer Widgets**: Reactive UI components
- **Provider Pattern**: Clean dependency injection

### **Navigation**
- **GoRouter 13.2.0**: Declarative routing
- **Deep Linking**: URL-based navigation
- **Route Guards**: Authentication-based routing
- **Query Parameters**: Dynamic route parameters
- **Global Back Button**: Native Android back button handling

### **Backend Services**
- **Firebase Core**: Firebase initialization
- **Firebase Auth**: User authentication with password change
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: File storage for venue/room images
- **Firebase App Check**: Security
- **Firebase Messaging**: Push notifications
- **Firebase Crashlytics**: Error reporting
- **Cloud Functions**: Serverless functions

### **Development Tools**
- **Android Studio**: Primary IDE
- **VS Code**: Alternative IDE
- **Flutter CLI**: Command-line tools
- **Dart DevTools**: Debugging and profiling
- **Git**: Version control
- **Flutter Launcher Icons**: App icon generation

### **Testing Framework**
- **Flutter Test**: Widget testing
- **Integration Test**: End-to-end testing
- **Mockito**: Mocking framework
- **Test Coverage**: Code coverage analysis

### **Performance & Monitoring**
- **Shimmer**: Loading effects
- **Caching**: Data caching strategies
- **Performance Profiling**: Memory and CPU monitoring
- **Error Tracking**: Crash reporting with Crashlytics

### **UI/UX Libraries**
- **Google Maps Flutter**: Map integration
- **Image Picker**: Image selection
- **URL Launcher**: External link handling (phone, maps, calendar)
- **Shared Preferences**: Local storage
- **HTTP**: Network requests
- **Lottie**: Animated loading states
- **Pull to Refresh**: Custom refresh functionality

## 📱 Screenshots & UI Walkthrough

### 🔐 Authentication Flow
- **Login Page**: Gradient background with native fonts, email/password fields, Google Sign-In, "Continue as Guest" option
- **Registration Page**: Unified styling with password confirmation, terms acceptance
- **Password Reset**: Email-based password recovery with confirmation
- **Change Password**: Functional password change with validation and Firebase integration
- **Guest Mode**: Anonymous authentication for quick access with browsing limitations

### 🏠 Main Application Pages
- **Home Page (Venues)**: Featured venues carousel with responsive cards, search bar, modern gradient design
- **Search Page**: Full-screen search with filters, real-time results, location search
- **Bookings Page**: Booking history with status indicators, booking details access
- **Profile Page**: Modern user information, account options, support tickets, theme toggle

### 📅 Booking Flow
- **Venue Details**: Comprehensive venue information with dynamic image loading, amenities, reviews
- **Room Selection**: Visual room cards with local asset images, descriptions, pricing, selection interface
- **Booking Flow**: Date/time picker, duration selection, price calculation, payment integration
- **Booking Confirmation**: Success page with booking details, action buttons (View Booking, Add to Calendar)
- **Booking Details**: Complete booking information with venue, room, timing, status, management options

### 🎨 Design Elements
- **Color Scheme**: Teal primary (#00838F), blue secondary (#1976D2), green tertiary (#4CAF50)
- **Dark Mode**: Dark grey (#181818) and black (#121212) colors, no blue
- **Typography**: Native phone fonts with consistent sizing
- **Components**: Custom buttons, input fields, cards with shadows
- **Animations**: Smooth transitions, loading states, micro-interactions
- **Responsive Design**: Adapts to all screen sizes and orientations
- **App Icon**: Custom app icon from assets/icons/logo.png

### 📱 Platform-Specific Features
- **Android**: Material Design 3 components, adaptive icons, native back button handling
- **iOS**: Cupertino-style elements, native iOS feel
- **Web**: Responsive web design with desktop optimization

## 🚀 Getting Started

### 📋 Prerequisites

#### **Development Environment**
- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: 3.0 or higher
- **Android Studio**: 2023.1 or higher (recommended)
- **VS Code**: Latest version with Flutter extension
- **Git**: 2.30 or higher

#### **System Requirements**
- **Operating System**: Windows 10+, macOS 10.15+, or Ubuntu 18.04+
- **RAM**: Minimum 8GB, recommended 16GB
- **Storage**: At least 10GB free space
- **Network**: Stable internet connection for dependencies

#### **Firebase Setup**
- **Firebase Project**: Active Firebase project
- **Firebase Console Access**: Admin access to Firebase project
- **Service Account**: Firebase service account for backend operations

### 🔧 Installation Guide

#### **Step 1: Environment Setup**
```bash
# Install Flutter SDK
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor

# Install Android Studio and configure Android SDK
# Download from: https://developer.android.com/studio
```

#### **Step 2: Project Setup**
```bash
# Clone the repository
git clone https://github.com/your-username/waddi_platform.git
cd waddi_platform

# Install dependencies
flutter pub get

# Generate code (if using code generation)
flutter packages pub run build_runner build

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Verify project setup
flutter analyze
```

#### **Step 3: Firebase Configuration**

**Android Configuration:**
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`
3. Verify package name matches: `com.waddi.mobile.dev`

**iOS Configuration:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place in `ios/Runner/GoogleService-Info.plist`
3. Add to Xcode project if not automatically added

**Web Configuration:**
1. Add Firebase config to `web/index.html`
2. Configure Firebase Hosting if needed

#### **Step 4: Environment Variables**
```bash
# Create .env file for environment variables
cp .env.example .env

# Edit .env with your Firebase configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

#### **Step 5: Run the Application**
```bash
# Development mode
flutter run

# Production build
flutter build apk --release
flutter build ios --release
flutter build web --release
```

### 🔍 Verification Steps

#### **Pre-Run Checks**
```bash
# Check Flutter installation
flutter doctor

# Verify dependencies
flutter pub deps

# Run static analysis
flutter analyze

# Run tests
flutter test
```

#### **Post-Run Verification**
- ✅ App launches without errors
- ✅ Firebase connection established
- ✅ Authentication working (including guest mode)
- ✅ Navigation functional with global back button handling
- ✅ Data loading properly with dynamic images
- ✅ Dark mode working with proper colors
- ✅ Change password functionality working
- ✅ Booking flow complete with confirmation and details pages

## 📁 Project Structure

### **Root Directory Structure**
```
waddi_platform/
├── android/                    # Android-specific configuration
├── ios/                       # iOS-specific configuration
├── web/                       # Web-specific configuration
├── lib/                       # Main Dart source code
├── test/                      # Unit and widget tests
├── integration_test/          # Integration tests
├── assets/                    # Static assets (images, fonts, etc.)
├── pubspec.yaml              # Dependencies and project configuration
├── pubspec.lock              # Locked dependency versions
├── analysis_options.yaml     # Static analysis configuration
├── firebase.json             # Firebase configuration
├── functions/                # Firebase Cloud Functions
└── README.md                 # Project documentation
```

### **Core Application Structure**
```
lib/
├── main.dart                 # Application entry point with Crashlytics
├── app.dart                  # Root app widget and configuration
├── firebase_options.dart     # Firebase configuration options
├── generated/                # Auto-generated files
│   └── l10n/               # Localization files
├── l10n/                    # Localization source files
├── core/                    # Core application utilities
│   ├── constants/           # Application constants
│   │   └── app_constants.dart
│   ├── errors/              # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── models/              # Base models
│   │   └── base_model.dart
│   ├── services/            # Core services
│   │   ├── firebase_service.dart
│   │   └── local_storage_service.dart
│   └── utils/               # Utility functions
│       ├── app_logger.dart
│       ├── date_formatter.dart
│       └── validator.dart
├── features/                # Feature modules (Clean Architecture)
│   ├── auth/               # Authentication feature
│   │   ├── auth_injection.dart
│   │   ├── data/           # Data layer
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/         # Domain layer
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_current_user.dart
│   │   │       ├── login_user.dart
│   │   │       ├── logout_user.dart
│   │   │       ├── register_user.dart
│   │   │       ├── reset_password.dart
│   │   │       └── change_password.dart
│   │   └── presentation/   # Presentation layer
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   ├── profile_page.dart
│   │       │   ├── register_page.dart
│   │       │   ├── reset_password_page.dart
│   │       │   └── change_password_page.dart
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── widgets/
│   │           ├── auth_form_field.dart
│   │           └── password_input.dart
│   ├── bookings/           # Booking system feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── booking_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── booking_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── booking_repository.dart
│   │   │   └── usecases/
│   │   │       ├── check_room_availability.dart
│   │   │       └── create_booking.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── booking_flow_page.dart
│   │       │   ├── booking_history_page.dart
│   │       │   ├── bookings_page.dart
│   │       │   ├── booking_confirmation_page.dart
│   │       │   └── booking_details_page.dart
│   │       └── providers/
│   │           └── booking_providers.dart
│   ├── notifications/      # Push notifications feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── notifications_page.dart
│   ├── payments/           # Payment processing feature
│   │   ├── data/
│   │   │   └── paymob_payment_service.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── payment_page.dart
│   │           └── payment_status_page.dart
│   ├── profile/            # User profile feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── profile_page.dart
│   ├── reviews/            # Review system feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── review_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── review_entity.dart
│   │   │   └── repositories/
│   │   │       └── review_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── reviews_page.dart
│   │       │   └── submit_review_page.dart
│   │       └── providers/
│   │           └── review_providers.dart
│   ├── search/             # Search functionality feature
│   │   └── presentation/
│   │       └── pages/
│   │           └── search_page.dart
│   ├── support/            # Support tickets feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── support_ticket_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── support_ticket_entity.dart
│   │   │   └── repositories/
│   │   │       └── support_ticket_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── contact_form_page.dart
│   │       │   ├── faq_page.dart
│   │       │   ├── support_tickets_page.dart
│   │       │   └── help_center_page.dart
│   │       └── providers/
│   │           └── support_ticket_providers.dart
│   ├── users/              # User management feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── user_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   └── repositories/
│   │   │       └── user_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── users_page.dart
│   │       └── providers/
│   │           └── user_providers.dart
│   ├── venue_owner/        # Venue owner features
│   │   └── presentation/
│   │       └── pages/
│   │           ├── room_form_page.dart
│   │           ├── room_management_page.dart
│   │           ├── venue_bookings_page.dart
│   │           ├── venue_analytics_page.dart
│   │           ├── venue_content_page.dart
│   │           ├── venue_dashboard_page.dart
│   │           └── venue_settings_page.dart
│   └── venues/             # Venue management feature
│       ├── data/
│       │   └── repositories/
│       │       └── venue_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── room_entity.dart
│       │   │   └── venue_entity.dart
│       │   └── repositories/
│       │       └── venue_repository.dart
│       └── presentation/
│           ├── pages/
│           │   ├── rooms_page.dart
│           │   ├── venue_details_page.dart
│           │   └── venues_page.dart
│           └── providers/
│               ├── geocoding_provider.dart
│               └── venue_providers.dart
├── routes/                 # Navigation configuration
│   ├── app_router.dart     # Main router configuration
│   └── app_routes.dart     # Route constants
└── shared/                 # Shared components and utilities
    ├── styles/
    │   └── app_styles.dart
    ├── themes/
    │   ├── app_colors.dart
    │   ├── app_theme.dart
    │   └── app_typography.dart
    └── widgets/
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── loading_indicator.dart
        ├── main_scaffold.dart
        ├── responsive_layout.dart
        ├── skeleton_loader.dart
        └── app_back_button_handler.dart
```

### **Asset Structure**
```
assets/
├── data/                   # Data files
├── fonts/                  # Custom fonts
├── icons/                  # Icon assets (including logo.png for app icon)
├── images/                 # Image assets
│   ├── auth/              # Authentication images
│   ├── common/            # Common images
│   ├── icons/             # Icon images
│   ├── rooms/             # Room images (arena.jpg, vault.jpg, etc.)
│   └── venues/            # Venue images
├── animations/             # Lottie animation files
└── translations/           # Localization files
    ├── ar.arb             # Arabic translations
    └── en.arb             # English translations
```

### **Test Structure**
```
test/
├── widget_test.dart        # Basic widget tests
└── unit/                   # Unit tests
    ├── auth/
    ├── bookings/
    └── venues/

integration_test/
└── app_test.dart          # Integration tests
```

## 🎨 Design System

### Colors
- **Primary**: Teal (#00838F)
- **Secondary**: Blue (#1976D2)
- **Tertiary**: Green (#4CAF50)
- **Background Light**: White (#FFFFFF)
- **Background Dark**: Dark Grey (#181818)
- **Surface Dark**: Dark Grey (#232323)
- **Primary Dark**: Black (#121212)
- **Text**: Dark grey (#212121)

### Typography
- Uses native phone fonts
- Consistent sizing across components
- Proper contrast ratios
- White text in dark mode

### Components
- Custom buttons with unified styling
- Input fields with consistent design
- Cards with shadow effects
- Loading indicators and skeleton loaders
- Responsive venue cards with aspect ratio images

## 🔧 Configuration

### Firebase Setup
1. Create Firebase project
2. Enable Authentication, Firestore, Storage, App Check, Crashlytics
3. Add platform-specific config files
4. Configure security rules

### Android Configuration
- Package name: `com.waddi.mobile.dev`
- Minimum SDK: 21
- Target SDK: 34
- NDK version: 27.0.12077973

### iOS Configuration
- Bundle identifier: `com.waddi.mobile.dev`
- Deployment target: iOS 12.0+

### App Icon Configuration
- Custom app icon: `assets/icons/logo.png`
- Generated using `flutter_launcher_icons`
- Supports Android and iOS platforms

## 📊 State Management

### Providers
- `authProvider` - Authentication state with password change functionality
- `venueProvider` - Venue data with dynamic image loading
- `bookingProvider` - Booking data with confirmation and details
- `themeProvider` - App theme with dark mode support
- `searchProvider` - Search functionality

### Caching
- Venue data caching for performance
- Booking data caching
- Image caching with Firebase Storage fallbacks
- Local asset caching for room images

## 🔐 Security

### Authentication
- Firebase Auth integration
- Email/password authentication
- Google Sign-In
- Anonymous authentication for guest users
- Password change functionality
- Session persistence

### Data Security
- Firebase App Check enabled
- Firestore security rules
- Input validation
- Error handling with Crashlytics

## 🚀 Performance

### Optimizations
- Debounced search queries
- Cached data providers
- Lazy loading of images from Firebase Storage
- Optimized build configurations
- Skeleton loading for better perceived performance

### Android Performance
- MultiDex enabled
- ProGuard for release builds
- Optimized heap size
- Vector drawable support
- Native back button handling

## 🧪 Testing

### Widget Tests
- Basic app functionality tests
- Navigation testing
- UI component testing

### Manual Testing
- Cross-platform testing
- Firebase integration testing
- Payment flow testing
- Guest user functionality testing

## 📦 Dependencies

### Core Dependencies
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Database
- `firebase_auth` - Authentication
- `firebase_storage` - File storage
- `firebase_app_check` - Security
- `firebase_crashlytics` - Error reporting

### UI Dependencies
- `google_maps_flutter` - Maps integration
- `shimmer` - Loading effects
- `image_picker` - Image selection
- `url_launcher` - External links (phone, maps, calendar)
- `lottie` - Animated loading states
- `pull_to_refresh` - Custom refresh functionality

### Development Dependencies
- `build_runner` - Code generation
- `riverpod_generator` - Provider generation
- `flutter_lints` - Code quality
- `flutter_launcher_icons` - App icon generation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔄 Version History

### v1.1.0 (Latest)
- ✅ Implemented change password functionality
- ✅ Added booking confirmation and details pages
- ✅ Enhanced dark mode with dark grey/black colors
- ✅ Added global back button handling
- ✅ Implemented Firebase Crashlytics
- ✅ Added Help Center page
- ✅ Set custom app icon
- ✅ Improved venue cards with responsive design
- ✅ Added guest user limitations
- ✅ Enhanced navigation with proper error handling

### v1.0.0
- Initial release
- Complete booking system
- Firebase integration
- Modern UI/UX design
- Cross-platform support

---

**Built with ❤️ using Flutter and Firebase**
