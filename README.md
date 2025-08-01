# 🏢 WADDI Platform - Venue Booking Application

A comprehensive Flutter-based venue booking platform that connects venue owners with users for seamless booking experiences.

## 📱 Current Features

### 🔐 Authentication & User Management
- **Multi-role system**: Guest, User, Venue Owner, Admin
- **Guest mode**: Browse venues without registration
- **User registration/login**: Email/password authentication
- **Profile management**: Edit name, phone number, view booking history
- **Password reset**: Email-based password recovery (⚠️ **Currently not working properly**)
- **Session persistence**: Users stay logged in after app restart (⚠️ **Currently not working properly**)

### 🏢 Venue Management
- **Venue creation**: Venue owners can add detailed venue information
- **Room management**: Add multiple rooms with individual details (capacity, price, amenities, images)
- **Maintenance mode**: Mark venues/rooms as closed for maintenance
- **Operating hours**: Set open/close times and time slot duration
- **Image upload**: Firebase Storage integration for venue and room images

### 📅 Booking System
- **Time slot selection**: Replace duration-based with specific time slots (9:00, 9:30, etc.)
- **Multiple slot booking**: Users can select multiple time slots
- **Real-time availability**: Calendar-based availability checking
- **Booking management**: View, modify, cancel bookings
- **Status tracking**: Pending, confirmed, in-progress, completed, cancelled
- **Booking history**: Past bookings with ratings/reviews

### 🔍 Search & Discovery
- **Advanced search filters**: Price range, capacity, amenities, location
- **Map integration**: Venue locations on map (placeholder)
- **Favorites system**: Save preferred venues
- **Sorting options**: By price, rating, distance, availability

### 🎨 User Experience
- **Theme system**: Light/dark/system theme with automatic detection
- **Multi-language support**: English, Arabic, French, Spanish, German (⚠️ **Currently not working properly**)
- **Accessibility features**: Text scaling, high contrast, screen reader support (⚠️ **Partially working**)
- **Push notifications**: Booking reminders, venue updates (infrastructure ready)
- **Offline support**: Data caching for offline browsing
- **Loading states**: Skeleton screens and improved loading animations

### 👨‍💼 Admin Features
- **Venue approval**: Approve/reject venue submissions
- **User management**: Create venue owner accounts with forced password change
- **Database management**: Add maintenance fields, cleanup operations
- **Analytics**: Basic booking and venue analytics

## 🚧 Known Issues & Limitations

### 🔴 Critical Issues
1. **Password Reset**: Email validation and sending not working properly
2. **Language Support**: Only English works, other languages show RTL but no translation
3. **Accessibility**: Page loads but settings don't apply correctly
4. **Image Loading**: Firebase Storage images fail to load on web (statusCode: 0)
5. **Session Persistence**: Users are not remembered after app restart - they get signed out

### 🟡 Minor Issues
1. **Profile Updates**: Name changes don't persist properly
2. **Navigation**: Some routes need optimization
3. **Error Handling**: Some error messages could be more user-friendly

## 🛠 Technical Stack

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI**: Material Design 3
- **Localization**: flutter_localizations

### Backend
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Functions**: Firebase Cloud Functions
- **Notifications**: Firebase Cloud Messaging (FCM)

## 🚀 Future Improvements

### Phase 1: Critical Fixes (Priority 1)
1. **Fix Password Reset**
   - Implement proper email validation
   - Fix Firebase Auth integration
   - Add success/error feedback

2. **Fix Language Support**
   - Debug localization files
   - Ensure proper language switching
   - Add missing translations

3. **Fix Accessibility**
   - Debug accessibility settings application
   - Test with screen readers
   - Ensure all features are accessible

4. **Fix Image Loading**
   - Resolve Firebase Storage CORS issues
   - Implement proper fallback mechanisms
   - Add image compression

5. **Fix Session Persistence**
   - Implement proper session management
   - Ensure users stay logged in after app restart
   - Add automatic login restoration

### Phase 2: User Experience (Priority 2)
1. **Enhanced Booking System**
   - Payment integration (Stripe/PayPal)
   - Booking confirmation emails
   - Advanced cancellation policies
   - Recurring bookings

2. **Improved Search & Discovery**
   - AI-powered recommendations
   - Advanced filtering options
   - Map integration with real-time location
   - Venue comparison features

3. **Better Notifications**
   - Push notification implementation
   - Email notifications
   - SMS notifications
   - Custom notification preferences

### Phase 3: Admin & Venue Owner Features (Priority 3)
1. **Admin Dashboard**
   - Comprehensive analytics
   - User management tools
   - Revenue tracking
   - System monitoring

2. **Venue Owner Tools**
   - Advanced booking management
   - Revenue analytics
   - Customer insights
   - Marketing tools

## 📱 User Roles & Permissions

### 👤 Guest User
- Browse venues
- View venue details
- Access settings (limited)
- No booking capabilities

### 👤 Regular User
- All guest features
- Create/edit profile
- Book venues
- View booking history
- Submit reviews
- Manage favorites
- Access all settings

### 🏢 Venue Owner
- All user features
- Create/edit venues
- Manage rooms
- View venue analytics
- Handle bookings
- Set maintenance status
- Manage operating hours

### 👨‍💼 Admin
- All venue owner features
- Approve/reject venues
- Manage all users
- Create venue owner accounts
- Access system analytics
- Manage system settings
- Database maintenance

## 🔧 Installation & Setup

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code
- Firebase project
- Git

### Setup Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/omarashour04/WADDI.git
   cd waddi_platform
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create Firebase project
   - Add Android/iOS apps
   - Download configuration files
   - Enable Firestore, Auth, Storage, Functions

4. **Run the app**
   ```bash
   flutter run
   ```

## 📊 Performance Metrics

### Current Performance
- App startup time: ~3-5 seconds
- Image loading: Variable (depends on network)
- Booking creation: ~2-3 seconds
- Search response: ~1-2 seconds

### Optimization Targets
- App startup: <2 seconds
- Image loading: <1 second
- Booking creation: <1 second
- Search response: <500ms

## 🔒 Security Considerations

### Implemented Security
- Firebase Auth integration
- Role-based access control
- Input validation
- Secure API calls

### Planned Security Enhancements
- Data encryption
- API rate limiting
- Advanced user verification
- Audit logging

## 📈 Analytics & Monitoring

### Current Analytics
- Basic user engagement
- Booking metrics
- Error tracking

### Planned Analytics
- Advanced user behavior
- Revenue tracking
- Performance monitoring
- A/B testing framework

## 🤝 Contributing

### Development Guidelines
1. Follow Flutter best practices
2. Use proper state management
3. Write comprehensive tests
4. Document code changes
5. Follow Git workflow

### Code Review Process
1. Create feature branch
2. Implement changes
3. Write tests
4. Submit pull request
5. Code review
6. Merge to main branch

## 📞 Support & Contact

### Technical Support
- GitHub Issues: [Repository Issues](https://github.com/omarashour04/WADDI/issues)
- Email: [Support Email]
- Documentation: [Wiki Link]

### Business Inquiries
- Email: [Business Email]
- Phone: [Business Phone]

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- All contributors and testers
- Open source community

---

**Last Updated**: December 2024
**Version**: 1.0.0
**Status**: Development Phase
**Branch**: ashour
