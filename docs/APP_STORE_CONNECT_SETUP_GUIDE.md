# App Store Connect Setup Guide - Get Paid by Apple

**Project:** Aqvioo
**Goal:** Enable receiving money from In-App Purchases
**Time Required:** 30-60 minutes

---

## 🎯 Quick Start Checklist

Complete these steps IN ORDER:

- [ ] **Step 1:** Sign Paid Applications Agreement (5 min)
- [ ] **Step 2:** Add Banking Information (10 min)
- [ ] **Step 3:** Complete Tax Forms (15 min)
- [ ] **Step 4:** Add Contact Information (5 min)
- [ ] **Step 5:** Create IAP Products (20 min)
- [ ] **Step 6:** Submit for Review (5 min)

**Total:** ~60 minutes

---

## Step 1: Sign Paid Applications Agreement 📝

**Why:** Without this, Apple won't pay you!

### Instructions:

1. Go to: [App Store Connect](https://appstoreconnect.apple.com/)
2. Click: **Agreements, Tax, and Banking**
3. Find: **Paid Applications** section
4. Status should show:
   - ❌ **"Agreement Not In Effect"** → Need to sign
   - ✅ **"Active"** → Already done, skip to Step 2

5. If not signed:
   - Click **"Request"** or **"View Agreement"**
   - Read the terms
   - Check **"I have read and agree"**
   - Enter your legal name
   - Click **"Submit"**

**⚠️ Note:** The Account Holder must sign this (not just any team member)

---

## Step 2: Add Banking Information 🏦

**Why:** This is where Apple sends your money!

### What You'll Need:

For Saudi Arabia (MADA/SAR):
- Bank name (e.g., "Al Rajhi Bank", "SNB", "Riyad Bank")
- Account holder name (must match App Store Connect account)
- **IBAN number** (starts with "SA" - 24 characters)
- **SWIFT/BIC code** (8-11 characters, e.g., "RJHISARI")
- Bank address

For International:
- Bank name
- Account number
- Routing number (US) or Sort code (UK)
- SWIFT code
- Bank address

### Instructions:

1. Go to: **Agreements, Tax, and Banking** → **Banking**
2. Click: **"Add Bank Account"** or **"Set Up"**
3. Select: **Your Country** (e.g., Saudi Arabia)
4. Select: **Currency** (e.g., SAR - Saudi Riyal)
5. Fill in:
   ```
   Account Holder Name: [Your name as in bank]
   Bank Name: [e.g., Al Rajhi Bank]
   IBAN: SA1234567890123456789012
   SWIFT/BIC: RJHISARI
   Branch Code: [if required]

   Bank Address:
   Street: [Bank branch address]
   City: [e.g., Riyadh]
   Postal Code: [e.g., 11564]
   Country: Saudi Arabia
   ```
6. Click: **"Save"**
7. Verify: Status shows ✅ **"Verified"** (may take 1-2 days)

**💰 Payment Info:**
- Apple pays monthly (around 45 days after month end)
- Minimum: $25 USD equivalent
- Transfer fee: Usually covered by Apple
- Exchange rate: Apple's rate on payment date

---

## Step 3: Complete Tax Forms 📋

**Why:** Avoid 30% tax withholding!

### For Saudi Arabia / Non-US Residents:

**Form Required:** W-8BEN (Certificate of Foreign Status)

### Instructions:

1. Go to: **Agreements, Tax, and Banking** → **Tax Forms**
2. Click: **"Add Tax Form"** → **W-8BEN**
3. Fill out:

   ```
   Part I: Identification
   ├─ Name: [Your legal/business name]
   ├─ Country: Saudi Arabia
   ├─ Address: [Your address]
   ├─ Tax ID: [Your VAT number or Tax ID]
   └─ Date of Birth: [if individual]

   Part II: Claim of Tax Treaty Benefits
   ├─ Check: "Yes" (Saudi Arabia has tax treaty with USA)
   ├─ Treaty Country: Saudi Arabia
   ├─ Article: 12 (Royalties)
   └─ Rate: 0% or 5% (check current treaty)

   Part III: Certification
   ├─ Sign: [Your signature]
   └─ Date: [Today's date]
   ```

4. Click: **"Submit"**
5. Upload supporting documents if requested:
   - VAT certificate
   - Business license
   - National ID

**⚠️ Important:**
- If you DON'T complete this, Apple withholds **30%** of revenue!
- Treaty rate for Saudi Arabia: Usually **0%** or **5%** (verify current rate)
- Renew every **3 years**

### For US Residents:

Use **W-9** form instead (simpler, no withholding)

---

## Step 4: Add Contact Information 📧

**Why:** Apple needs to reach you for important matters.

### Instructions:

1. Go to: **Agreements, Tax, and Banking** → **Contact Information**
2. Add contacts for:

   **Senior Management:**
   ```
   Name: [CEO/Owner name]
   Email: [ceo@aqvioo.com]
   Phone: [+966 5XX XXX XXX]
   ```

   **Financial Contact:**
   ```
   Name: [CFO/Accountant name]
   Email: [finance@aqvioo.com]
   Phone: [+966 5XX XXX XXX]
   ```

   **Technical Contact:**
   ```
   Name: [Your name]
   Email: [mbardouni7894@gmail.com]
   Phone: [Your phone]
   ```

   **Legal Contact:**
   ```
   Name: [Legal advisor or yourself]
   Email: [legal@aqvioo.com]
   Phone: [+966 5XX XXX XXX]
   ```

3. Click: **"Save"**

**Note:** You can use the same person for multiple roles if needed.

---

## Step 5: Create IAP Products 🛍️

**Why:** These are what users actually buy!

### Product Details:

| Product ID | Type | Price | Description |
|------------|------|-------|-------------|
| `credits_package_15` | Consumable | 15 SAR | 5 videos or 7 images |
| `credits_package_30` | Consumable | 30 SAR | 10 videos or 15 images |
| `credits_package_50` | Consumable | 50 SAR | 16 videos or 25 images |
| `credits_package_100` | Consumable | 100 SAR | 33 videos or 50 images |

### Instructions (Repeat for each product):

1. Go to: **My Apps** → **Aqvioo** → **Features** → **In-App Purchases**
2. Click: **"+"** → **Consumable**
3. Fill out:

   **Product Information:**
   ```
   Reference Name: 15 SAR Balance Package
   Product ID: credits_package_15
   ```

   **Pricing:**
   ```
   Base Territory: Saudi Arabia (SAR)
   Base Price: 15.00 SAR
   ```

   (Apple will auto-convert to other currencies)

   **Localization - English:**
   ```
   Display Name: 15 SAR Balance
   Description: Add 15 SAR to your balance. Create 5 AI videos or 7 AI images.
   ```

   **Localization - Arabic:**
   ```
   Display Name: رصيد 15 ريال
   Description: أضف 15 ريال إلى رصيدك. أنشئ 5 فيديوهات أو 7 صور بالذكاء الاصطناعي.
   ```

   **Review Information (Optional but Recommended):**
   - Upload screenshot of payment screen showing this package
   - Add notes: "Consumable balance for AI generation"

4. Click: **"Save"**
5. Click: **"Submit for Review"**

**Repeat for all 4 products.**

### Product Statuses:

- **Ready to Submit** → You can submit for review
- **Waiting for Review** → Submitted, waiting for Apple
- **In Review** → Apple is reviewing
- **Approved** → Live and ready for use
- **Rejected** → Fix issues and resubmit

**⏱️ Review Time:** Usually 1-3 business days

---

## Step 6: Submit App for Review 🚀

**Prerequisites:**
- [ ] Steps 1-5 completed
- [ ] App build uploaded to TestFlight
- [ ] All 4 IAP products created
- [ ] App metadata filled (description, screenshots, etc.)

### Instructions:

1. Go to: **My Apps** → **Aqvioo** → **App Store**
2. Select: **Version 1.0.0**
3. Fill required fields:
   - Description
   - Keywords
   - Screenshots (iPhone 6.7" and 5.5" required)
   - App Icon
   - Category
   - Age Rating

4. Scroll to: **App Review Information**
   ```
   Sign-In Required: No

   Demo Account (if needed):
   Username: [test account]
   Password: [test password]

   Notes:
   In-App Purchase Test Instructions:
   1. All purchases via StoreKit IAP (iOS only)
   2. Products: credits_package_15/30/50/100
   3. Each purchase adds balance for AI generation
   4. Restore Purchases available in payment screen
   5. Video cost: 2.99 SAR, Image cost: 1.99 SAR
   ```

5. Scroll to: **Version Release**
   - Select: **Manually release this version**
   - (Or auto-release if you prefer)

6. Click: **"Add for Review"**
7. Click: **"Submit for Review"**

**⏱️ Review Time:** Usually 1-7 days

---

## ✅ Verification Checklist

After completing all steps, verify:

### In App Store Connect:

**Agreements:**
- [ ] Paid Applications: **Active**
- [ ] Agreement end date: Shows future date

**Banking:**
- [ ] Bank account: **Verified** ✅
- [ ] Currency: SAR (or your currency)
- [ ] Status: Active

**Tax:**
- [ ] W-8BEN: **Approved** ✅
- [ ] Treaty benefits: Claimed
- [ ] Withholding rate: 0% or 5%

**Contacts:**
- [ ] All 4 contacts added
- [ ] Emails verified

**Products:**
- [ ] `credits_package_15`: Approved ✅
- [ ] `credits_package_30`: Approved ✅
- [ ] `credits_package_50`: Approved ✅
- [ ] `credits_package_100`: Approved ✅

**App:**
- [ ] App status: **Ready for Sale** or **In Review**

---

## 💰 First Payment Timeline

**Example Timeline:**

```
January 2026:
├─ User buys 30 SAR package
├─ Apple receives payment: 30 SAR
├─ Apple's cut (30%): 9 SAR
└─ Your revenue: 21 SAR

February 2026:
└─ Revenue accumulates (if more sales)

Mid-March 2026:
└─ Apple sends payment to your bank (January sales)
    Amount: All January revenue minus Apple's cut
    Method: Wire transfer to your IBAN
```

**Payment Cycle:**
- Sales month: January
- Financial report available: Early February
- Payment sent: Mid-March (~45 days after month end)
- Arrives in bank: 3-5 business days later

---

## 🆘 Troubleshooting

### "Paid Applications agreement not available"
**Cause:** Account holder hasn't been verified
**Fix:**
1. Check email for Apple verification
2. Verify phone number in Apple ID
3. Contact Apple Developer Support

### "Banking information rejected"
**Cause:** IBAN/SWIFT doesn't match bank records
**Fix:**
1. Double-check IBAN (exactly 24 characters for Saudi)
2. Verify SWIFT code with your bank
3. Ensure account holder name matches exactly
4. Try removing and re-adding

### "Tax form rejected"
**Cause:** Missing information or invalid tax ID
**Fix:**
1. Verify Tax ID/VAT number is correct
2. Upload supporting documents (VAT certificate)
3. Ensure treaty article is correct (Article 12 for royalties)
4. Contact Apple tax support

### "Product rejected"
**Cause:** Description unclear or violates guidelines
**Fix:**
1. Check rejection reason in App Store Connect
2. Update description to be more specific
3. Add screenshot if missing
4. Resubmit for review

---

## 📞 Support Contacts

### **Apple Developer Support:**
- Phone: Check [Apple Developer Support](https://developer.apple.com/support/)
- Email: Via App Store Connect → Contact Us
- Hours: 24/7 for critical issues

### **Financial/Tax Questions:**
- Go to: App Store Connect → Contact Us → Agreements, Tax, and Banking
- Response time: 1-2 business days

### **IAP Technical Issues:**
- Developer Forums: [https://developer.apple.com/forums/](https://developer.apple.com/forums/)
- Tag: In-App Purchase

---

## 📚 Additional Resources

- [Payments and Financial Reports](https://developer.apple.com/help/app-store-connect/manage-app-store-transactions/view-payments-and-financial-reports)
- [Tax and Banking](https://developer.apple.com/help/app-store-connect/manage-agreements-tax-and-banking-information/agreements-tax-and-banking-overview)
- [In-App Purchase](https://developer.apple.com/in-app-purchase/)
- [Small Business Program](https://developer.apple.com/app-store/small-business-program/) (15% fee instead of 30%)

---

## 🎉 You're All Set!

Once all steps are complete:
- ✅ Apple can pay you
- ✅ Users can buy IAP products
- ✅ Revenue flows to your bank
- ✅ Tax is properly handled

**Next:** Monitor sales in App Store Connect → Sales and Trends

Good luck! 🚀
