<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Hello,

Thank you for your resubmission. Upon further review, we identified additional issues that need your attention. See below for more information.

If you have any questions, we are here to help. Reply to this message in App Store Connect and let us know.

Review Environment
Submission ID: f1bccd9b-da94-4346-afd3-e01c3af51e39
Review date: February 17, 2026
Review Device: iPad Air 11-inch (M3)
Version reviewed: 1.0

Guideline 2.1 - Performance - App Completeness
Issue Description

The app exhibited one or more bugs that would negatively impact users.

Bug description: Specifically, an error message appeared when we tapped on "Create".

Review device details:

- Device type: iPad Air 11-inch (M3)
- OS version: iPadOS 26.2.1
- Internet Connection: Active

Next Steps

Test the app on supported devices to identify and resolve bugs and stability issues before submitting for review.

Guideline 2.1 - Information Needed
We have started our review, but we need additional information to continue. Specifically, it appears your app may access or include paid digital content or services, and we want to understand your business model before completing our review.

Next Steps

Please review the following questions and provide as much detailed information about your business model as you can.

1. Who are the users that will use the paid content, subscriptions, features, and services in the app?
2. Where can users purchase the content, subscriptions, features, and services that can be accessed in the app?
3. What specific types of previously purchased content, subscriptions, features, and services can a user access in the app?
4. What paid content, subscriptions, or features are unlocked within your app that do not use in-app purchase?

Support

- Reply to this message in your preferred language if you need assistance. If you need additional support, use the [Contact Us module](https://developer.apple.com/contact/topic/#!/topic/select).
- Consult with fellow developers and Apple engineers on the [Apple Developer Forums](https://developer.apple.com/forums/).
- Request an [App Review Appointment at Meet with Apple](https://developer.apple.com/events/view/upcoming-events?search=%22App%20Review%22) to discuss your app's review. Appointments subject to availability during your local business hours on Tuesdays and Thursdays.
- Provide feedback on this message and your review experience by [completing a short survey](https://essentials.applesurveys.com/jfe/form/SV_esVePfih7uqt4NM?campaignid=0001).

Request a phone call from App Review

At your request, we can arrange for an Apple Representative to call you within the next three to five business days to discuss your App Review issue.

[Request a call to discuss your app's review](https://developer.apple.com/contact/request/app-review/call/?teamId=4LGGU2TT4V&appId=6756293641&platform=ios&guideline=124605)
how to make it deployed successffully

لنجاح النشر (تجاوز المراجعة) تحتاج شيئين بشكل أساسي: **إصلاح** خطأ زر “Create” على iPad ثم الرد بوضوح على أسئلة “Business model” بحيث يفهم فريق المراجعة أين يتم الدفع وما الذي يُفتح داخل التطبيق.[^1_1]

## 1) إصلاح خطأ “Create”

- أعد إنتاج المشكلة على iPad (نفس الفئة إن أمكن) ومع نفس السيناريو: تثبيت نظيف للتطبيق + اتصال إنترنت فعال + بيئة Production وليس Debug.
- اجعل زر “Create” لا يُظهر رسالة خطأ عامة/غامضة: اعرض سببًا واضحًا للمستخدم + زر إعادة المحاولة + منع الضغط المتكرر (debounce) + التعامل مع حالات (timeout / 401 / 403 / 5xx / no internet).
- تأكد أن خدمات الباك-إند “live” أثناء المراجعة وأن أي مفاتيح/بيئات (API base URL, Firebase config, Remote Config…) هي الخاصة بالإنتاج وليست بيئة محلية أو معطلة أثناء Review.[^1_1]
- إذا كانت العملية تعتمد على تسجيل دخول، زوّد Apple بحساب تجريبي فعّال أو “demo mode” يتيح كل الميزات المطلوبة للمراجعة.[^1_1]


## 2) إجابات نموذج الأعمال (للرد على Apple)

Apple تحتاج تفهم هل يوجد **محتوى/ميزات رقمية مدفوعة** تُفتح داخل التطبيق أم لا، لأن فتح ميزات رقمية داخل التطبيق يجب أن يتم عبر In‑App Purchase وليس عبر آلياتك الخاصة (مثل مفاتيح ترخيص/أكواد/بوابات دفع خارجية داخل التطبيق).[^1_1]

انسخ/الصق هذا الرد (وعدّله حسب تطبيقك):

1) **من هم المستخدمون الذين سيستخدمون المحتوى/الاشتراك/الميزات المدفوعة؟**
“Users are [general users / businesses / students…]. Paid access is intended for [who], while free users can [what].”
2) **أين يمكن للمستخدمين شراء المحتوى/الاشتراك/الميزات؟**
اختر واحدًا بوضوح:

- “Users purchase inside the iOS app using Apple In‑App Purchase (auto‑renewable subscription / non‑consumable).”[^1_1]
أو
- “Users purchase on our website (outside the app). The iOS app only allows sign‑in and access for users who already have an account.” (ملاحظة: لا تضع أزرار/روابط/CTA للشراء الخارجي داخل التطبيق إلا إذا كنت ضمن استثناءات/صلاحيات الربط المسموح بها؛ في معظم المتاجر غير الولايات المتحدة هذا ممنوع بدون entitlement).[^1_1]

3) **ما أنواع المشتريات السابقة التي يمكن للمستخدم الوصول لها داخل التطبيق؟**
“Previously purchased items include: [subscription plan A], [plan B], [feature X], [content library Y]. After login, the app unlocks: [exact screens/features].”
4) **ما الذي يُفتح داخل التطبيق بدون IAP؟**

- إذا الجواب “لا شيء”: “None. No paid digital content or features are unlocked within the app without using In‑App Purchase.”[^1_1]
- إذا هناك شيء “مدفوع رقميًا” يتم فتحه بطرق أخرى: هذا غالبًا سبب الرفض القادم؛ انقل فتحه إلى IAP أو غيّر التصميم بحيث لا يُعتبر “unlocking” رقمي داخل التطبيق.[^1_1]


## 3) ماذا تكتب في “Notes for Review”

اكتب ملاحظات قصيرة ودقيقة لأن Apple تنصح بشرح الميزات غير الواضحة وطرق الوصول وبيانات الدخول للمراجعة.[^1_1]

- خطوات الوصول لمكان زر “Create” (screen by screen).
- حساب تجريبي: email/password + إن كان هناك OTP اشرح طريقة تجاوزه (أو وفر demo mode).
- إن كان عندك IAP: أين تظهر شاشة الشراء، وكيف تعمل Restore Purchases.


## 4) قائمة تحقق قبل إعادة الإرسال

- ارفع Build جديد (رقم Build أعلى) بعد إصلاح “Create”.
- اختبر على iPad فعليًا (الواجهة + القيود + اتجاه الشاشة) لأن مشكلة ظهرت على iPad Air.
- تأكد أن التطبيق لا “crash” ولا يحتوي مشاكل تقنية واضحة لأن Apple ترفض الحزم غير المكتملة أو التي تظهر مشاكل تقنية.[^1_1]

إذا وصفت لي بسرعة: ما الذي يحدث عند الضغط على “Create” (نص رسالة الخطأ/صورة، وهل هي من API أم Validation أم IAP)، وما هو نموذج الدفع عندك (اشتراك داخل التطبيق؟ موقع؟ محتوى رقمي؟)، أكتب لك ردّ App Review جاهز + تعديل معماري واضح يضمن الالتزام ويقلل فرص رفض جديد.
<span style="display:none">[^1_10][^1_11][^1_12][^1_13][^1_14][^1_15][^1_2][^1_3][^1_4][^1_5][^1_6][^1_7][^1_8][^1_9]</span>

<div align="center">⁂</div>

[^1_1]: https://stackoverflow.com/questions/66269673/app-store-rejection-guideline-2-1-performance-app-completeness

[^1_2]: https://community.revenuecat.com/general-questions-7/apple-store-rejection-guideline-2-1-performance-app-completeness-6493

[^1_3]: https://developer.apple.com/forums/thread/815079

[^1_4]: https://developer.apple.com/app-store/review/guidelines/

[^1_5]: https://wangchujiang.com/app-rejection-fixes/

[^1_6]: https://www.reddit.com/r/iOSProgramming/comments/164leum/what_response_will_allow_approval_of_a_free_app/

[^1_7]: https://www.theverge.com/news/660025/apple-changes-app-store-rules-to-allow-external-purchases

[^1_8]: https://www.reddit.com/r/FlutterDev/comments/1kts3v9/apple_keeps_rejecting_my_app_because_of_my/

[^1_9]: https://stackoverflow.com/questions/65868703/ios-app-review-meta-data-rejected-guideline-2-1-information-needed

[^1_10]: https://www.adweek.com/media/external-payments-now-allowed-by-apple-app-store-following-court-injunction/

[^1_11]: https://buddyboss.com/docs/app-store-guideline-2-1-performance-app-completeness/

[^1_12]: https://developer.apple.com/app-store/business-models/

[^1_13]: https://buddyboss.com/docs/app-store-guideline-3-1-1-business-payments-in-app-purchase/

[^1_14]: https://community.revenuecat.com/sdks-51/ios-reject-guideline-2-1-performance-app-completeness-4272

[^1_15]: https://buddyboss.com/docs/app-store-guideline-2-1-performance-app-completeness-3/

