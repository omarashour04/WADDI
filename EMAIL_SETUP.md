# 📧 Email Setup Guide for WADDI Platform

This guide explains how to set up email functionality for booking confirmations, cancellations, and reminders.

## 🚀 Features Implemented

### ✅ Email Types
1. **Booking Confirmation Email** - Sent when a booking is created
2. **Booking Cancellation Email** - Sent when a booking is cancelled
3. **Booking Reminder Email** - Sent 24 hours before booking (future feature)

### ✅ Email Content
- Professional HTML templates with WADDI branding
- Booking receipt with all details
- Venue owner contact information
- Important booking information
- Links to view bookings and contact support

## 🔧 Setup Instructions

### 1. Firebase Functions Setup

#### Install Dependencies
Navigate to the `functions` directory and install nodemailer:
```bash
cd functions
npm install nodemailer @types/nodemailer
```

#### Deploy Functions
Deploy the Firebase Functions to enable email functionality:
```bash
firebase deploy --only functions
```

### 2. Email Configuration

#### Gmail Setup (Recommended)
1. **Enable 2-Factor Authentication** on your Gmail account
2. **Generate App Password**:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate a new app password for "Mail"
3. **Configure Firebase Functions**:
   ```bash
   firebase functions:config:set email.user="your-email@gmail.com" email.password="your-app-password"
   ```

#### Alternative Email Services
You can modify the `transporter` configuration in `functions/src/index.ts` to use other email services:
- **SendGrid**: `service: 'sendgrid'`
- **Mailgun**: `service: 'mailgun'`
- **Custom SMTP**: Configure with your own SMTP settings

### 3. Testing Email Functionality

#### Admin Email Test Page
1. Log in as an admin user
2. Navigate to Admin Dashboard
3. Click on "Email Test" card
4. Enter test email address and name
5. Test different email types:
   - Confirmation Email
   - Cancellation Email
   - Reminder Email

#### Manual Testing
You can also test emails by creating actual bookings in the app.

## 📧 Email Templates

### Booking Confirmation Template
- **Subject**: 🎉 Booking Confirmed - {venueName}
- **Content**: 
  - Booking receipt with all details
  - Venue and room information
  - Date, time, and duration
  - Total price
  - Venue owner contact info
  - Important booking information

### Booking Cancellation Template
- **Subject**: ❌ Booking Cancelled - {venueName}
- **Content**:
  - Cancelled booking details
  - Refund information (if applicable)
  - Contact information

### Booking Reminder Template
- **Subject**: ⏰ Booking Reminder - {venueName}
- **Content**:
  - Upcoming booking details
  - Reminder to arrive early
  - Venue owner contact info

## 🔒 Security Considerations

### Email Security
- Use app passwords instead of regular passwords
- Enable 2FA on email accounts
- Use environment variables for sensitive data
- Implement rate limiting for email sending

### Data Privacy
- Only send emails to verified users
- Include unsubscribe options
- Comply with email regulations (GDPR, CAN-SPAM)

## 🐛 Troubleshooting

### Common Issues

#### 1. Emails Not Sending
- Check Firebase Functions logs: `firebase functions:log`
- Verify email configuration
- Check Gmail app password is correct
- Ensure 2FA is enabled

#### 2. Authentication Errors
- Verify email credentials in Firebase config
- Check if Gmail account has security restrictions
- Try generating a new app password

#### 3. Function Deployment Issues
- Check Node.js version (requires 18+)
- Verify all dependencies are installed
- Check Firebase project configuration

### Debug Steps
1. **Check Function Logs**:
   ```bash
   firebase functions:log --only sendBookingConfirmationEmail
   ```

2. **Test Function Locally**:
   ```bash
   firebase emulators:start --only functions
   ```

3. **Verify Configuration**:
   ```bash
   firebase functions:config:get
   ```

## 📊 Monitoring

### Email Analytics
- Track email delivery rates
- Monitor bounce rates
- Check open and click rates
- Set up alerts for failures

### Performance Monitoring
- Monitor function execution times
- Track email queue performance
- Set up error alerts

## 🔄 Future Enhancements

### Planned Features
1. **Email Templates Management** - Admin interface to edit templates
2. **Email Scheduling** - Send reminders at specific times
3. **Email Preferences** - User control over email types
4. **Email Analytics** - Track email performance
5. **Multi-language Support** - Localized email templates

### Technical Improvements
1. **Email Queue System** - Handle high volume email sending
2. **Template Engine** - More flexible template system
3. **Email Validation** - Better email address validation
4. **Retry Logic** - Automatic retry for failed emails

## 📞 Support

For issues with email functionality:
1. Check the troubleshooting section above
2. Review Firebase Functions logs
3. Test with the admin email test page
4. Contact the development team

---

**Last Updated**: December 2024
**Version**: 1.0.0 