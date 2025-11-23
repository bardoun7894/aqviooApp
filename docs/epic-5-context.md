# Technical Context: Epic 5 - Monetization

## 1. Overview
This epic implements the business logic for monetization. Aqvioo offers **1 Free Trial** video. After that, users must pay to generate more. We will use **Tabby** (Buy Now, Pay Later) as the payment gateway.

**In-Scope:**
- **Credit System:** Track user credits (starts at 1).
- **Paywall:** Block generation if credits < 1.
- **Payment Screen:** UI to select a package (e.g., "5 Videos for 50 SAR").
- **Tabby Integration:** Use `tabby_flutter_inapp_sdk` to process payments.
- **Credit Top-up:** Add credits upon successful payment.

**Out-of-Scope:**
- Subscription Models (One-time purchases only for now).
- Complex Backend Validation (We will trust the client/mock for MVP, but architecture allows moving to Cloud Functions later).

## 2. Architecture Alignment
- **State Management:** `PaymentController` manages `credits` and `paymentStatus`.
- **Persistence:** `SharedPreferences` (for Guest) or `Firestore` (for Auth Users) to store credit balance. *MVP Decision: Use SharedPreferences for simplicity to support Guests easily.*
- **Services:**
    - `PaymentService`: Wraps Tabby SDK.
    - `CreditService`: Manages balance.

## 3. Detailed Design

### 3.1 Module Structure
```
lib/features/payment/
├── data/
│   └── credit_repository.dart # Manages balance (Local/Remote)
├── presentation/
│   ├── providers/
│   │   └── payment_provider.dart # Logic for buying/spending
│   └── screens/
│       └── payment_screen.dart   # Tabby Checkout UI
```

### 3.2 Credit Logic
1.  **Init:** Check storage. If new user, set `credits = 1`.
2.  **Spend:** Before `generateVideo()` in Home, check `credits > 0`.
    - If yes: `credits--`, proceed.
    - If no: Show `PaymentScreen`.
3.  **Buy:** User selects package -> Tabby Checkout -> Success -> `credits += 5`.

### 3.3 Tabby Integration
- **SDK:** `tabby_flutter_inapp_sdk`
- **Flow:**
    1.  Create Session (Mocked or Real API).
    2.  Launch Tabby WebView.
    3.  Handle Return URL (Success/Cancel).

## 4. Non-Functional Requirements
- **Security:** Payment keys must be secure (env variables).
- **UX:** "Out of credits" message should be encouraging, not annoying.
- **Reliability:** Credits must be added *only* if payment is confirmed.

## 5. Dependencies
- `tabby_flutter_inapp_sdk`
- `shared_preferences` (need to add this)
- `flutter_dotenv`

## 6. Acceptance Criteria
1.  **Free Trial:** New install has exactly 1 credit.
2.  **Blocking:** Cannot generate video with 0 credits.
3.  **Payment UI:** Shows correct price and Tabby option.
4.  **Top-up:** Successful payment increases credit balance.
5.  **Persistence:** Credits remain after app restart.

## 7. Risks & Assumptions
- **Risk:** Local storage (SharedPrefs) is easily hackable.
    - *Mitigation:* Acceptable for MVP. Real app needs server-side validation.
- **Assumption:** Tabby Sandbox keys are available or we mock the success response.
