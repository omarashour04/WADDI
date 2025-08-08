# WADDI Platform - Venue Booking Application

A comprehensive Flutter-based venue booking platform that connects customers with venue owners, featuring smart room selection, offline mode, and advanced booking management.

## 🚀 Features

### 🔐 Authentication & User Management
- **Multi-role Authentication**: Customer, Venue Owner, and Admin roles
- **Secure Login/Registration**: Firebase Authentication integration
- **Profile Management**: Edit personal information, view booking history
- **Password Reset**: Email-based password recovery (currently disabled)
- **Session Persistence**: Automatic login state management

### 🏢 Venue Management
- **Venue Registration**: Venue owners can register new venues with detailed information
- **Venue Approval System**: Admin approval workflow for new venues
- **Venue Information**: Operating hours, location, amenities, photos
- **Room Management**: Add/edit rooms with capacity, pricing, and availability
- **Maintenance Mode**: Temporarily close rooms for maintenance

### 📅 Smart Booking System
- **Intelligent Room Selection**: Automatic room assignment based on group size and availability
- **Time Slot Management**: Flexible time slot selection with real-time availability
- **Open-Ended Bookings**: Book with start time only (cash payment required)
- **Capacity-Based Booking**: System automatically finds rooms that fit your group size
- **Conflict Prevention**: Prevents double bookings and time conflicts
- **Booking Duration**: Configurable booking durations (30-minute increments)

### 💳 Payment & Pricing
- **Multiple Payment Methods**: Cash and online payment options
- **Dynamic Pricing**: Hourly rates with automatic calculation
- **Open-Ended Pricing**: Special pricing for open-ended bookings
- **Price Summary**: Real-time cost calculation and display

### 📱 User Experience
- **Responsive Design**: Works on mobile, tablet, and desktop
- **Multi-language Support**: English and Arabic localization
- **Accessibility Features**: Text size adjustment, high contrast mode
- **Offline Mode**: View existing bookings and profile when offline
- **Real-time Updates**: Live availability and booking status updates

### 🔄 Booking Management
- **Booking Creation**: Easy booking process with smart room selection
- **Booking Details**: Comprehensive booking information display
- **Booking Cancellation**: Cancel bookings with confirmation
- **Booking History**: View past, current, and upcoming bookings
- **Status Tracking**: Real-time booking status (pending, confirmed, in-progress, completed, cancelled)

### 🎯 Smart Features
- **Smart Room Selection**: Automatically finds the best available room
- **Capacity Optimization**: Matches group size to room capacity
- **Availability Checking**: Real-time availability across all rooms
- **Conflict Detection**: Prevents booking conflicts automatically
- **Progressive Loading**: Efficient data loading for better performance

### 📊 Admin Features
- **Venue Approval**: Review and approve new venue registrations
- **User Management**: Monitor user activity and manage accounts
- **System Monitoring**: Track booking patterns and system usage
- **Content Management**: Manage app content and settings

### 🔧 Technical Features
- **Offline Support**: Core functionality works without internet
- **Caching System**: Intelligent data caching for better performance
- **Batch Loading**: Efficient data loading for multiple venues
- **Error Handling**: Comprehensive error handling and user feedback
- **Performance Monitoring**: Track app performance and usage metrics

### 🌐 Connectivity Features
- **Offline Restrictions**: Prevents new bookings when offline
- **Data Synchronization**: Syncs data when connection is restored
- **Connection Monitoring**: Real-time internet connectivity detection
- **Offline Data Storage**: Caches essential data for offline viewing

### 🎨 UI/UX Features
- **Modern Design**: Clean, intuitive interface design
- **Loading States**: Skeleton loaders and progress indicators
- **Custom Components**: Reusable UI components for consistency
- **Theme Support**: Light mode as default with theme customization
- **Responsive Layout**: Adapts to different screen sizes

### 📍 Navigation & Routing
- **Declarative Routing**: GoRouter for efficient navigation
- **Deep Linking**: Support for direct links to specific pages
- **Navigation History**: Track and manage navigation state
- **Smart Back Navigation**: Context-aware back button behavior

### 🔍 Search & Discovery
- **Venue Browsing**: Browse available venues with filters
- **Search Functionality**: Search venues by name, location, or amenities
- **Category Filtering**: Filter venues by type or features
- **Location-Based**: Find venues near your location

### 📱 Platform Support
- **Cross-Platform**: iOS, Android, Web, and Desktop support
- **Native Performance**: Optimized for each platform
- **Platform-Specific Features**: Leverages platform capabilities

## 🛠 Technical Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences
- **Connectivity**: connectivity_plus
- **Internationalization**: intl package

## 📁 Project Structure

```
lib/
├── features/
│   ├── auth/           # Authentication
│   ├── bookings/       # Booking management
│   ├── venues/         # Venue management
│   ├── users/          # User management
│   ├── admin/          # Admin features
│   └── accessibility/  # Accessibility settings
├── shared/
│   ├── services/       # Shared services
│   ├── widgets/        # Reusable widgets
│   ├── themes/         # App theming
│   ├── utils/          # Utility functions
│   └── providers/      # Shared providers
└── routes/             # Navigation routes
```

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd waddi_platform
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Set up Firebase project
   - Add configuration files
   - Enable required services

4. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Known Issues

- **Password Reset**: Email functionality is currently disabled
- **Language Support**: Arabic translations need refinement
- **Accessibility**: Some accessibility features are partially implemented
- **Session Persistence**: User session management needs improvement

## 🔮 Future Enhancements

- **Email Integration**: Re-implement email confirmation system
- **Push Notifications**: Real-time booking notifications
- **Payment Gateway**: Integrate online payment processing
- **Reviews System**: User reviews and ratings
- **Google Maps**: Location-based venue discovery
- **Analytics**: Advanced booking analytics and reporting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions, please contact the development team or create an issue in the repository.
