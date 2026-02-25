# App Store Connect Response (Ready to Paste)

## 1) Reply to App Review (Guideline 2.1 - Create bug)

Hello App Review Team,

Thank you for the feedback. We fixed the `Create` flow issue that appeared on iPad.

### What we fixed
- Improved `Create` flow error handling and state transitions.
- Prevented duplicate failure UI events and improved retry safety.
- Added stronger payment/purchase idempotency safeguards to avoid duplicated credit updates.
- Improved Firebase read/write reliability with transactional balance updates.
- Added cache and query optimizations to reduce stale/duplicated data risks.

### Validation completed before resubmission
- Tested on iPad and iPhone in release mode.
- Tested create flow with: valid prompt, empty prompt, network interruption, timeout, and retry.
- Verified app does not crash and shows user-friendly errors.

We uploaded a new build with these fixes.


## 2) Reply to "Information Needed" (Business Model)

1. **Who are the users that will use paid content/features/services?**  
   Our users are general consumers and creators who generate AI images/videos in the app.

2. **Where can users purchase content/features/services accessed in the app?**  
   On iOS, users purchase credits **only through Apple In-App Purchase (IAP)** inside the app.

3. **What previously purchased items can users access in the app?**  
   Users can access their previously purchased credit balance and use it to generate new AI content. Previously generated content remains viewable in the app.

4. **What paid content/features are unlocked without IAP?**  
   **None on iOS.** No paid digital content or feature is unlocked without Apple IAP.


## 3) App Review Notes (include in submission)

- Test account (if required):
  - Email: `apple.review@aqvioo.com`
  - Password: `AqviooReview2026!`
- Steps to test `Create`:
  1. Login
  2. Go to Home
  3. Enter prompt
  4. Tap `Create`
  5. Wait for generation screen
- iOS payments:
  - Purchase flow uses Apple IAP only.
  - Restore purchases is supported through Apple purchase restore behavior.


## 4) Pre-Submission Technical Checklist

- `flutter analyze` -> no compile errors
- `flutter test` -> all tests passed
- iPad smoke tests done for create flow and payments
- Confirm iOS build is release and uploaded with a higher build number


## 5) Firebase Deployment Checklist (recommended before submit)

From project root:

```bash
firebase deploy --only firestore:rules
```

This ensures the latest Firestore rules used by the new runtime/cache behavior are active in production.
