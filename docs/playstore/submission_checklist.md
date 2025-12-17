# Google Play Store Submission Checklist
# قائمة التحقق لنشر التطبيق على متجر Google Play

---

## Pre-Submission Checklist
 
### 2. Create New App
- [ ] Go to Google Play Console → Create app
- [ ] Select: **App** (not Game)
- [ ] Select: **Free** or **Paid**
- [ ] Declare: App is **not** designed primarily for children
- [ ] Accept Developer Program Policies

---
 
### 4. App Access
- [ ] Select: "All functionality is available without special access"
- [ ] OR provide test credentials if login required

### 5. Ads
- [ ] Select: "No, my app does not contain ads"

### 6. Content Rating
- [ ] Complete IARC questionnaire (use `content_rating_answers.md`)
- [ ] Expected result: Everyone / 3+

### 7. Target Audience
- [ ] Select age groups: 18 and over
- [ ] Confirm app is NOT designed for children

### 8. News App
- [ ] Select: "My app is not a news app"

### 9. COVID-19 Apps
- [ ] Select: "My app is not a COVID-19 contact tracing or status app"

### 10. Data Safety
- [ ] Complete all questions (use `data_safety.md`)
- [ ] Declare data types collected
- [ ] Declare third-party sharing

### 11. Government Apps
- [ ] Select: "My app is not a government app"

### 12. Financial Features
- [ ] If applicable, declare any financial services offered

---

## Store Listing Section

### 13. Main Store Listing (English)
- [ ] App name (30 chars): `Aqvioo - AI Video Creator`
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Use content from `en/store_listing.md`

### 14. Arabic Store Listing
- [ ] Go to: Manage translations → Add language → Arabic
- [ ] Add Arabic app name
- [ ] Add Arabic short description
- [ ] Add Arabic full description
- [ ] Use content from `ar/store_listing.md`

### 15. Graphics
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG/JPG)
- [ ] Phone screenshots (min 2, recommended 4-6)
- [ ] Tablet screenshots (optional)
- [ ] See `screenshot_requirements.md` for specifications

### 16. Categorization
- [ ] App category: **Video Players & Editors**
- [ ] Tags: Select relevant tags (AI, Video, Creative)

### 17. Contact Details
- [ ] Email: support@aqvioo.com
- [ ] Phone (optional)
- [ ] Website (optional): https://aqvioo.com

---

## App Release Section

### 18. Production Track Setup
- [ ] Go to: Release → Production
- [ ] Create new release

### 19. Upload App Bundle
- [ ] Upload `app-release.aab` (92MB)
- [ ] File location: `build/app/outputs/bundle/release/app-release.aab`

### 20. Release Notes
```
Version 1.0.0

• Create AI-powered promotional videos from text
• Transform photos into dynamic video content
• Generate stunning AI images
• Add professional AI voiceovers
• Support for English and Arabic
```

### 21. Review Release
- [ ] Review all warnings/errors
- [ ] Fix any issues flagged

### 22. Roll Out
- [ ] Choose rollout percentage (start with Internal Testing recommended)
- [ ] Or select "Full rollout" for immediate release

---

## Post-Submission

### 23. App Review
- [ ] Wait for Google review (typically 1-7 days for new apps)
- [ ] Monitor email for any rejection reasons
- [ ] Address any policy violations if flagged

### 24. Firebase Configuration
- [ ] Add release SHA-1 to Firebase Console
  ```
  96:FE:44:89:D3:D4:95:60:A1:D1:CD:5F:08:FB:18:27:B7:87:07:03
  ```
- [ ] Download updated `google-services.json` if needed

### 25. Monitor Launch
- [ ] Check crash reports in Play Console
- [ ] Monitor reviews and ratings
- [ ] Respond to user feedback

---
 

## Quick Reference - Key Files

| File | Location |
|------|----------|
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` |
| English Listing | `docs/playstore/en/store_listing.md` |
| Arabic Listing | `docs/playstore/ar/store_listing.md` |

## العربية - ملخص سريع

### الخطوات الرئيسية: 
2. إنشاء تطبيق جديد في Console
3. إكمال قسم "محتوى التطبيق"
4. إضافة قائمة المتجر (إنجليزي + عربي)
5. رفع الرسومات (أيقونة + لقطات شاشة)
6. رفع ملف AAB
7. إرسال للمراجعة
8. انتظار الموافقة (1-7 أيام)

### الملفات المطلوبة:
- ملف التطبيق: `app-release.aab` (92 ميجابايت)
- أيقونة التطبيق: 512×512 بكسل
- صورة العرض: 1024×500 بكسل
- لقطات الشاشة: 4-6 صور (1080×1920)
