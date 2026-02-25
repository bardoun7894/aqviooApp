# App Store Submission Pack

## 1) Resolution Center Reply (Paste as-is)

Hello App Review Team,

Thank you for your review.

We fixed the issue reported under Guideline 2.1 where an error appeared after tapping **Create** on iPad.

### Fixes included in this build
- Stabilized the Create flow and improved async error/state handling.
- Added safer Firebase credit updates using transactional writes.
- Added idempotency protections for iOS purchase handling to avoid duplicate crediting.
- Improved caching/read behavior to reduce stale data and repeated operations.
- Improved user-facing error handling so failures are clear and recoverable.

### Validation performed before resubmission
- Tested on iPad and iPhone using a release build.
- Re-tested Create flow with normal and failure scenarios (network interruption, retry, timeout).
- Confirmed the app no longer crashes and handles Create failures gracefully.

We have uploaded a new build with these fixes.


## 2) Information Needed (Business Model Answers)

1. **Who are the users that will use the paid content, subscriptions, features, and services in the app?**  
Our users are general consumers and creators who generate AI images/videos in the app.

2. **Where can users purchase the content, subscriptions, features, and services that can be accessed in the app?**  
On iOS, users purchase credits only through Apple In-App Purchase (IAP) inside the app.

3. **What specific types of previously purchased content, subscriptions, features, and services can a user access in the app?**  
Users can access their previously purchased credit balance and use it for new AI generations. Previously generated content remains accessible in the app.

4. **What paid content, subscriptions, or features are unlocked within your app that do not use in-app purchase?**  
None on iOS. No paid digital content or feature is unlocked without Apple IAP.


## 3) App Review Notes (Paste in App Review Notes)

Test account (if login is required):
- Email: `apple.review@aqvioo.com`
- Password: `AqviooReview2026!`

Steps to validate Create:
1. Login.
2. Open Home.
3. Enter a prompt.
4. Tap **Create**.
5. Wait for generation/loading flow.

iOS payments:
- Payment for digital credits is implemented via Apple IAP only.
- Restore Purchases follows Apple IAP restore flow.


## 4) Release Notes (Optional)

- Fixed Create flow reliability on iPad.
- Improved generation error handling and retry behavior.
- Improved purchase safety and credit consistency.
- Performance and stability improvements.
