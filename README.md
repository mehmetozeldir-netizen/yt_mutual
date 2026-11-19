# YT MUTUAL

Flutter + Firebase Android app. The visual identity is red and white.

## Current implemented flows
- Firebase email/password registration and sign-in.
- Firestore user profile creation and profile-name editing.
- Content submission to Firestore with pending moderation state.
- Active content discovery and opening valid YouTube links in the external app/browser.
- User submission history and deletion of pending submissions.
- Admin moderation screen gated by the Firebase Authentication custom claim `admin: true`.
- Firestore security rules protect user points/roles and moderation status from ordinary users.

## Firebase setup required
1. In Firebase Console, enable **Authentication → Email/Password**.
2. Create/enable **Cloud Firestore** in the same Firebase project as the Android app.
3. Deploy rules from the repository root with Firebase CLI: `firebase deploy --only firestore:rules`.
4. To grant an administrator, set the Firebase Auth custom claim `admin: true` using a trusted server/Admin SDK. Never let the mobile client assign this claim.
5. Confirm the Android app is registered with package `com.mycompany.ytmutual` and that `android/app/google-services.json` belongs to that Firebase project.

## Important product limitation
The app does not award points for YouTube views, likes, comments, or subscriptions. That would incentivize artificial engagement. The current wallet display is informational; no points are minted or spent in this build.

## Build
GitHub Actions runs `flutter build apk --release` on pushes to `main`. A successful build confirms compilation only; Firebase Console configuration and real-device acceptance tests are still required.
