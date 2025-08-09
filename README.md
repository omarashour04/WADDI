# WADDI – Changes in this session (ashour branch)

This document summarizes the changes implemented in this session only.

## New features and flows
- Check‑in
  - User QR scan to check in at the room (Scan tab in bottom nav opens `/check-in`).
  - Venue owner one‑tap check‑in from the owner bookings page.
  - Auto‑cancel bookings not checked in within 15 minutes after start.
- Room QR poster page (Owner)
  - Printable QR per room with encoded `{v:1, vid:<venueId>, rid:<roomId>}`.

## Booking improvements
- Time slots
  - Past slots for “today” are greyed out and not selectable.
  - Slot generation is resilient to missing/invalid venue hours (falls back to 09:00–23:00).
  - Fixed Firestore availability query to avoid composite index errors (filter overlap in memory).
- Open‑ended bookings
  - Disabled in booking form unless venue `allowOpenEndedBookings == true`.
  - Added “Open‑ended only” filter in Venues search.

## Firebase updates
- Project switched to `waddi-platform-dev` with regenerated configs:
  - `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`.
- Push notifications (client)
  - Requests permission, registers FCM token to `users/{uid}.fcmTokens`, handles message taps to booking details.
- Booking reminders (server)
  - Scheduled Cloud Function `scheduleBookingRemindersAndAutoCancel` (every 5m):
    - Sends reminders at 24h, 1h, and 15m before start.
    - Auto‑cancels un‑checked‑in bookings 15m after start.
  - Requires Cloud Scheduler and billing enabled in Firebase.

## Roles and navigation
- Role switching (testing)
  - Venue owner can switch role to Admin or User from Profile for testing.
- Navigation
  - Bottom bar “Scan” shortcut to open the QR scanner quickly.

## Caching and admin
- After admin/owner venue updates (approve/edit), venue caches are invalidated so users see changes immediately.

## How to run
- Web dev: `flutter run -d chrome --web-port 5000`
- Android debug APK: `flutter build apk --debug` (ensure valid `android/app/google-services.json`).

## What to test
- Booking: only future time slots are selectable for today.
- Check‑in: user QR scan and owner one‑tap; auto‑cancel after +15m no‑show.
- Push reminders: verify notifications at 24h/1h/15m; confirm flags prevent duplicates.
- Search filter: “Open‑ended only” returns venues with open‑ended enabled.
- Role switch (Profile → Role Management) for quick testing.
