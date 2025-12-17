# Aqvioo Web Admin Dashboard - Implementation Roadmap

**Document Version:** 1.0
**Created:** 2025-11-30
**Project:** Aqvioo Mobile App
**Owner:** Mohamed
**Status:** Planning Phase

---

## EXECUTIVE SUMMARY

This roadmap outlines the complete implementation plan for the Aqvioo Web Admin Dashboard - a web-based control panel for monitoring users, managing credits, tracking payments, and moderating content.

**Key Metrics:**
- **Estimated Build Time:** 10-15 developer days (2-3 weeks)
- **Technology:** Flutter Web (recommended for code reuse)
- **Deployment:** Firebase Hosting
- **Launch Target:** Pre-Production (before mobile app launch)

---

## TECHNOLOGY STACK DECISION

### Recommended: Flutter Web + Firebase

**Rationale:**
1. ✅ **Code Reuse:** Share 60-70% of code with mobile app
2. ✅ **Existing Expertise:** Team already knows Flutter/Dart
3. ✅ **Firebase Integration:** Already configured and working
4. ✅ **Unified Codebase:** Single repo for mobile + web
5. ✅ **No Additional Costs:** Deploy on Firebase Hosting (free tier)

**Architecture:**
```
aqvioo/
├── lib/
│   ├── features/
│   │   ├── admin/              ← NEW: Admin-only features
│   │   │   ├── dashboard/
│   │   │   ├── users/
│   │   │   ├── content/
│   │   │   └── payments/
│   └── core/
│       └── admin_auth/         ← NEW: Admin authentication
├── web/                         ← Flutter Web configuration
└── firebase.json               ← Hosting configuration
```

**Alternative Options (Not Recommended):**
- React: Would require separate codebase, different skillset
- Low-Code (Retool): $50-200/month, vendor lock-in
- Firebase Extensions: Limited customization

---

## IMPLEMENTATION PHASES

### Phase 1: Foundation & MVP (5-7 days) 🔴 CRITICAL PATH

**Goal:** Basic admin dashboard operational for launch monitoring

**Core Features:**
1. Admin authentication (separate from mobile users)
2. Dashboard home with key metrics
3. User management (view, search, credit adjustment)
4. Recent content viewer
5. Basic payment transaction list

**Deliverables:**
- Admin login screen
- Dashboard layout with navigation
- User list with search/filter
- Credit adjustment interface
- Responsive design (desktop + tablet)

---

### Phase 2: Enhanced Monitoring (4-5 days) 🟡 HIGH PRIORITY

**Goal:** Advanced analytics and monitoring capabilities

**Features:**
6. Charts & graphs (revenue, user growth)
7. System health dashboard
8. Content moderation tools
9. Payment analytics
10. Error log viewer

**Deliverables:**
- Interactive charts (fl_chart package)
- Real-time metrics updates
- Content flagging system
- Export data to CSV
- Alert configuration

---

### Phase 3: Operations & Scale (3-4 days) 🟢 FUTURE

**Goal:** Advanced operational features for scale

**Features:**
11. Bulk operations (credit adjustments, notifications)
12. Role-based access control
13. Announcement/banner management
14. Feature flags
15. Support ticket integration

**Deliverables:**
- Multi-admin support
- Audit log system
- Advanced filtering
- Scheduled reports
- API rate limit monitoring

---

## DETAILED TASK BREAKDOWN

### PHASE 1: FOUNDATION & MVP (5-7 DAYS)

#### Task 1.1: Project Setup (0.5 days)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Enable Flutter Web in project (`flutter create . --platforms=web`)
- [ ] Configure Firebase Hosting (`firebase init hosting`)
- [ ] Set up web-specific dependencies
  - `fl_chart: ^0.68.0` (charts)
  - `data_table_2: ^2.5.11` (tables)
  - `csv: ^6.0.0` (export)
- [ ] Create admin route guard (prevent mobile users from accessing)
- [ ] Configure web-specific Firebase initialization
- [ ] Test basic web build (`flutter build web`)

**Acceptance Criteria:**
- ✅ Web app builds successfully
- ✅ Firebase Hosting configured
- ✅ Admin routes separated from mobile routes

**Dependencies:** None
**Risk:** Low

---

#### Task 1.2: Admin Authentication (1.5 days)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Create `AdminAuthProvider` (separate from mobile auth)
- [ ] Design admin login screen
  - Email/password only (no phone/guest for admins)
  - "Admin Dashboard" branding
  - Remember me checkbox
- [ ] Implement Firestore admin user collection
  ```
  admins/
    └── {adminId}/
        ├── email
        ├── displayName
        ├── role (admin, moderator, support)
        ├── permissions[]
        └── createdAt
  ```
- [ ] Create admin role verification middleware
- [ ] Add session persistence for web
- [ ] Implement logout functionality
- [ ] Add password reset flow

**Acceptance Criteria:**
- ✅ Admin can login with email/password
- ✅ Only users in `admins` collection can access
- ✅ Session persists across page refreshes
- ✅ Non-admin users redirected to error page

**Dependencies:** Task 1.1
**Risk:** Medium (security must be tight)

**Security Checklist:**
- [ ] Firestore rules prevent non-admins from reading admin collection
- [ ] Admin routes require authentication
- [ ] Admin emails stored securely (not in client code)

---

#### Task 1.3: Dashboard Layout & Navigation (1 day)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Create responsive sidebar navigation
  - Dashboard (home icon)
  - Users (people icon)
  - Content (video icon)
  - Payments (credit card icon)
  - Settings (gear icon)
- [ ] Build top app bar
  - Current admin name
  - Notifications bell (future)
  - Logout button
- [ ] Implement main content area (responsive grid)
- [ ] Add mobile hamburger menu (for tablet/small screens)
- [ ] Design footer (version number, links)

**UI Components:**
```dart
AdminScaffold(
  sidebar: AdminSidebar(),
  topBar: AdminAppBar(),
  body: PageContent(),
  footer: AdminFooter(),
)
```

**Acceptance Criteria:**
- ✅ Sidebar navigation works on all pages
- ✅ Layout responsive (1024px+, 768px, 480px)
- ✅ Active page highlighted in nav
- ✅ Smooth transitions between pages

**Dependencies:** Task 1.2
**Risk:** Low

---

#### Task 1.4: Dashboard Home Screen (1 day)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Create `DashboardProvider` to fetch metrics
- [ ] Design metric cards:
  - Total Users (with 24h change)
  - Total Revenue (SAR)
  - Videos Generated Today
  - Active Generations (processing)
  - Average Credits per User
  - Success Rate (%)
- [ ] Add real-time listeners for live updates
- [ ] Implement loading states
- [ ] Design error states
- [ ] Add refresh button

**Data Sources:**
```dart
// Firestore queries
- users/ collection count
- users/{uid}/data/credits aggregate
- users/{uid}/creations/ count (today)
- users/{uid}/creations/ where status == processing
```

**Acceptance Criteria:**
- ✅ Metrics display correctly
- ✅ Numbers update in real-time
- ✅ Loading skeleton while fetching
- ✅ Error message if Firebase fails

**Dependencies:** Task 1.3
**Risk:** Low

---

#### Task 1.5: User Management - List View (1.5 days)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Create `UsersProvider` to manage user data
- [ ] Build user list table with columns:
  - Profile Image (or initials)
  - Name / Email
  - Phone Number
  - Credits Balance
  - Last Active
  - Status (Active/Banned)
  - Actions (View, Edit, Ban)
- [ ] Implement pagination (20 users per page)
- [ ] Add search functionality (by name, email, phone)
- [ ] Add filter dropdowns:
  - Status (All, Active, Banned)
  - Credits (All, <10, 10-50, 50+)
  - Date range (Last 7 days, 30 days, All time)
- [ ] Add sort functionality (by name, credits, date)
- [ ] Implement "Export to CSV" button

**Table Package:** `data_table_2: ^2.5.11`

**Acceptance Criteria:**
- ✅ User list loads with pagination
- ✅ Search works (case-insensitive)
- ✅ Filters work (can combine multiple)
- ✅ Sort works on all columns
- ✅ Export generates CSV file

**Dependencies:** Task 1.3
**Risk:** Medium (performance with large user base)

**Performance Optimization:**
- Use Firestore pagination (cursor-based)
- Limit to 20 results per query
- Cache previous pages

---

#### Task 1.6: User Management - Detail View & Credit Adjustment (1 day)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Create user detail screen (route: `/admin/users/:userId`)
- [ ] Display user information:
  - Profile section (name, email, phone, joined date)
  - Credit balance (large, prominent)
  - Generation history (table: date, type, status, cost)
  - Payment history (table: date, amount, credits purchased)
  - Account status (active/banned toggle)
- [ ] Build credit adjustment dialog:
  - Amount input (+ or -)
  - Reason dropdown (Refund, Bonus, Correction, Other)
  - Notes field (optional)
  - Confirm button
- [ ] Implement adjustment logic:
  - Update Firestore `users/{uid}/data/credits`
  - Create audit log entry
  - Show success notification
- [ ] Add ban/unban user button
- [ ] Add "Send Notification" button (future)

**Acceptance Criteria:**
- ✅ User detail loads all information
- ✅ Credit adjustment updates Firestore
- ✅ Audit log created for all changes
- ✅ Changes reflected in user list immediately
- ✅ Ban status updates successfully

**Dependencies:** Task 1.5
**Risk:** Medium (security critical)

**Security:**
- [ ] Verify admin permissions before adjustment
- [ ] Validate adjustment amount (prevent negative balances)
- [ ] Log admin user ID with adjustment

---

#### Task 1.7: Content Viewer - Recent Generations (1 day)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Create `ContentProvider` to fetch creations
- [ ] Build content grid:
  - Thumbnail image/video
  - User name (link to user detail)
  - Prompt text (truncated, expandable)
  - Creation date
  - Status badge (Success, Processing, Failed)
  - Type badge (Video, Image)
  - Actions (View, Delete)
- [ ] Implement pagination (24 items per page)
- [ ] Add filters:
  - Type (All, Video, Image)
  - Status (All, Success, Processing, Failed)
  - Date range
- [ ] Add search by prompt text
- [ ] Implement delete functionality (with confirmation)

**Data Source:**
```dart
// Firestore query
users/{userId}/creations/
  .orderBy('createdAt', descending: true)
  .limit(24)
```

**Acceptance Criteria:**
- ✅ Content grid displays thumbnails
- ✅ Filters work correctly
- ✅ Delete removes from grid immediately
- ✅ Pagination works smoothly

**Dependencies:** Task 1.3
**Risk:** Low

---

#### Task 1.8: Payment Transaction List (0.5 days)
**Owner:** Developer
**Priority:** 🔴 Critical

**Subtasks:**
- [ ] Create `PaymentsProvider` to fetch transactions
- [ ] Build transaction table:
  - Date & Time
  - User (link to user detail)
  - Amount (SAR)
  - Credits Purchased
  - Payment Method (Tabby)
  - Status (Success, Pending, Failed)
  - Transaction ID
- [ ] Add filters:
  - Status (All, Success, Failed)
  - Date range
- [ ] Add total revenue summary card
- [ ] Implement search by transaction ID

**Data Source:**
```dart
// Firestore collection (need to create)
transactions/
  └── {transactionId}/
      ├── userId
      ├── amount
      ├── credits
      ├── status
      ├── paymentMethod
      └── createdAt
```

**Note:** This collection doesn't exist yet - need to create it when implementing Tabby webhooks.

**Acceptance Criteria:**
- ✅ Transaction list displays all payments
- ✅ Filters work correctly
- ✅ Revenue summary calculates correctly
- ✅ Links to user detail work

**Dependencies:** Task 1.3, Tabby webhook implementation
**Risk:** High (depends on webhook integration)

**Workaround for MVP:**
- Query user credit history from Firestore
- Calculate transactions from credit changes
- Mark as "estimated" until webhooks implemented

---

### PHASE 2: ENHANCED MONITORING (4-5 DAYS)

#### Task 2.1: Charts & Analytics (2 days)
**Owner:** Developer
**Priority:** 🟡 High

**Subtasks:**
- [ ] Install `fl_chart: ^0.68.0`
- [ ] Create analytics screen (`/admin/analytics`)
- [ ] Implement charts:
  1. **Revenue Line Chart** (last 30 days)
     - X-axis: Date
     - Y-axis: Revenue (SAR)
  2. **User Growth Line Chart** (last 30 days)
     - X-axis: Date
     - Y-axis: New users
  3. **Generation Breakdown Pie Chart**
     - Videos vs Images
  4. **Success Rate Bar Chart**
     - Success vs Failed generations
  5. **Popular Styles Bar Chart**
     - Top 5 video/image styles
- [ ] Add date range selector (7 days, 30 days, 90 days, custom)
- [ ] Implement export chart to PNG
- [ ] Add loading states for each chart
- [ ] Make charts responsive

**Acceptance Criteria:**
- ✅ All charts render correctly
- ✅ Data updates when date range changes
- ✅ Charts are interactive (hover tooltips)
- ✅ Export functionality works

**Dependencies:** Phase 1 complete
**Risk:** Medium (chart library learning curve)

---

#### Task 2.2: System Health Dashboard (1 day)
**Owner:** Developer
**Priority:** 🟡 High

**Subtasks:**
- [ ] Create system status screen (`/admin/system`)
- [ ] Implement API health checks:
  - Kie AI API (ping endpoint)
  - Firebase (already connected)
  - Tabby API (test connection)
- [ ] Display service status cards:
  - Status indicator (green/yellow/red)
  - Last checked timestamp
  - Response time (ms)
  - Error rate (last 24h)
- [ ] Create generation queue monitor:
  - Processing tasks count
  - Average processing time
  - Failed tasks (last hour)
- [ ] Add error log table:
  - Timestamp
  - Service
  - Error message
  - User affected (if applicable)
- [ ] Implement manual health check button
- [ ] Add auto-refresh (every 30 seconds)

**Acceptance Criteria:**
- ✅ Health checks run successfully
- ✅ Status indicators update in real-time
- ✅ Error logs display correctly
- ✅ Manual refresh works

**Dependencies:** Phase 1 complete
**Risk:** Medium (requires API changes)

---

#### Task 2.3: Content Moderation Tools (1 day)
**Owner:** Developer
**Priority:** 🟡 High

**Subtasks:**
- [ ] Add "Flag" button to content viewer
- [ ] Create flagged content screen (`/admin/moderation`)
- [ ] Build moderation queue:
  - Thumbnail
  - Prompt text
  - User info
  - Flag reason
  - Date flagged
  - Actions (Approve, Delete, Ban User)
- [ ] Implement bulk actions:
  - Select multiple items
  - Delete selected
  - Approve selected
- [ ] Add moderation notes (internal)
- [ ] Create Firestore collection for flags:
  ```
  flags/
    └── {flagId}/
        ├── contentId
        ├── userId
        ├── reason
        ├── status (pending/approved/deleted)
        └── createdAt
  ```

**Acceptance Criteria:**
- ✅ Flag button works on content
- ✅ Moderation queue displays flagged items
- ✅ Bulk actions work correctly
- ✅ Notes saved successfully

**Dependencies:** Task 1.7
**Risk:** Low

---

#### Task 2.4: Payment Analytics & Export (0.5 days)
**Owner:** Developer
**Priority:** 🟡 High

**Subtasks:**
- [ ] Add revenue analytics cards:
  - Today's revenue
  - This week's revenue
  - This month's revenue
  - Average transaction value
- [ ] Create revenue breakdown chart:
  - By credit package (50, 100, 200 credits)
- [ ] Implement "Export to CSV" for transactions
- [ ] Add payment method breakdown (when multiple methods added)
- [ ] Create monthly revenue report generator

**Acceptance Criteria:**
- ✅ Revenue metrics calculate correctly
- ✅ Charts display payment data
- ✅ CSV export includes all fields
- ✅ Monthly report generates PDF

**Dependencies:** Task 1.8, Task 2.1
**Risk:** Low

---

### PHASE 3: OPERATIONS & SCALE (3-4 DAYS)

#### Task 3.1: Role-Based Access Control (1.5 days)
**Owner:** Developer
**Priority:** 🟢 Future

**Subtasks:**
- [ ] Define admin roles:
  - **Super Admin:** Full access
  - **Admin:** Users, content, payments (no settings)
  - **Moderator:** Content moderation only
  - **Support:** View users, adjust credits
- [ ] Update `admins` collection schema:
  ```dart
  admins/
    └── {adminId}/
        ├── role (string)
        └── permissions: {
            canManageUsers: bool,
            canAdjustCredits: bool,
            canModerateContent: bool,
            canViewPayments: bool,
            canManageAdmins: bool,
            canConfigureSettings: bool,
          }
  ```
- [ ] Implement permission guards on all routes
- [ ] Create admin management screen:
  - List admins
  - Add new admin
  - Edit permissions
  - Deactivate admin
- [ ] Add audit log for admin actions
- [ ] Implement activity log viewer

**Acceptance Criteria:**
- ✅ Different roles have correct access
- ✅ Unauthorized actions show error
- ✅ Audit log tracks all admin actions

**Dependencies:** Phase 1 & 2 complete
**Risk:** Medium (complex permissions logic)

---

#### Task 3.2: Bulk Operations (1 day)
**Owner:** Developer
**Priority:** 🟢 Future

**Subtasks:**
- [ ] Add bulk credit adjustment:
  - Select multiple users
  - Apply same adjustment to all
  - Add reason (applies to all)
- [ ] Implement bulk notifications:
  - Select users
  - Compose message
  - Send via Firebase Cloud Messaging
- [ ] Add bulk export:
  - Export selected users to CSV
  - Export date range of transactions
- [ ] Create scheduled operations:
  - Recurring credit bonuses
  - Automatic cleanup of old content

**Acceptance Criteria:**
- ✅ Bulk operations work on 100+ items
- ✅ Progress indicator shows during bulk ops
- ✅ Error handling for partial failures

**Dependencies:** Task 3.1
**Risk:** Medium (performance concerns)

---

#### Task 3.3: Feature Flags & Configuration (0.5 days)
**Owner:** Developer
**Priority:** 🟢 Future

**Subtasks:**
- [ ] Create settings screen (`/admin/settings`)
- [ ] Implement feature flags:
  - Enable/disable new user registrations
  - Enable/disable video generation
  - Enable/disable image generation
  - Enable/disable guest mode
  - Maintenance mode (show banner in app)
- [ ] Add configuration options:
  - Credit pricing (per video/image)
  - Initial credits for new users
  - Maximum generation queue length
- [ ] Store in Firestore collection:
  ```
  settings/
    └── app-config/
        ├── featureFlags: {}
        └── config: {}
  ```
- [ ] Mobile app reads from this collection

**Acceptance Criteria:**
- ✅ Settings save successfully
- ✅ Mobile app reflects changes
- ✅ Only authorized admins can change settings

**Dependencies:** Task 3.1
**Risk:** Low

---

#### Task 3.4: Announcement & Banner Management (0.5 days)
**Owner:** Developer
**Priority:** 🟢 Future

**Subtasks:**
- [ ] Create announcements screen
- [ ] Build banner editor:
  - Message text (Arabic + English)
  - Banner color (info, warning, error)
  - Show/hide toggle
  - Expiration date
- [ ] Add banner preview
- [ ] Mobile app fetches active banner on launch
- [ ] Store in Firestore:
  ```
  settings/
    └── active-banner/
        ├── messageEn
        ├── messageAr
        ├── type
        ├── active
        └── expiresAt
  ```

**Acceptance Criteria:**
- ✅ Banner displays in mobile app
- ✅ Banner auto-hides after expiration
- ✅ Preview shows both languages

**Dependencies:** None
**Risk:** Low

---

## DEPLOYMENT STRATEGY

### Environment Setup

**Development:**
- URL: `http://localhost:5000`
- Firebase Project: `aqvioo-dev` (if separate)
- Testing: Use Firebase Emulators

**Staging:**
- URL: `https://admin-staging.aqvioo.app`
- Firebase Project: `aqvioo-staging`
- Testing: Real data, limited admins

**Production:**
- URL: `https://admin.aqvioo.app`
- Firebase Project: `aqvioo-production`
- Access: Production admins only

### Firebase Hosting Configuration

```json
// firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache, no-store, must-revalidate"
          }
        ]
      }
    ]
  }
}
```

### Deployment Process

**Manual Deployment:**
```bash
# 1. Build web app
flutter build web --release

# 2. Deploy to Firebase Hosting
firebase deploy --only hosting

# 3. Test deployed version
open https://admin.aqvioo.app
```

**CI/CD (Future):**
- GitHub Actions workflow
- Auto-deploy on merge to `main`
- Run tests before deployment

---

## TIMELINE & MILESTONES

### Sprint 1: Foundation (Week 1)
**Days 1-2:**
- Task 1.1: Project setup
- Task 1.2: Admin authentication
- Task 1.3: Layout & navigation

**Days 3-5:**
- Task 1.4: Dashboard home
- Task 1.5: User list
- Task 1.6: User detail & credit adjustment

**Milestone 1:** Basic admin dashboard operational ✅

---

### Sprint 2: Content & Payments (Week 2)
**Days 6-7:**
- Task 1.7: Content viewer
- Task 1.8: Payment transactions

**Days 8-10:**
- Task 2.1: Charts & analytics
- Task 2.2: System health dashboard

**Milestone 2:** Enhanced monitoring live ✅

---

### Sprint 3: Advanced Features (Week 3)
**Days 11-12:**
- Task 2.3: Content moderation
- Task 2.4: Payment analytics

**Days 13-15:**
- Task 3.1: Role-based access
- Task 3.2: Bulk operations
- Task 3.3: Feature flags
- Task 3.4: Announcements

**Milestone 3:** Production-ready admin dashboard ✅

---

## RESOURCE REQUIREMENTS

### Team
- **1 Flutter Developer** (full-time, 3 weeks)
- **1 Designer** (part-time, 2-3 days for UI mockups)
- **1 QA Tester** (part-time, final week)

### Tools & Services
- Firebase Hosting (Free tier sufficient)
- Flutter Web tooling (included)
- Chart library: fl_chart (free)
- Table library: data_table_2 (free)

### Budget
- **Development:** 15 days × daily rate
- **Design:** 3 days × daily rate
- **QA:** 5 days × daily rate
- **Hosting:** $0/month (Firebase free tier)

**Total Cost:** Development time only (no additional software costs)

---

## DEPENDENCIES & BLOCKERS

### Critical Dependencies
1. **Tabby Webhook Integration** (for accurate payment data)
   - Without: Can estimate from credit changes
   - With: Accurate transaction history

2. **Firebase Security Rules** (for admin access control)
   - Must be configured before production
   - Blocks: Task 1.2

3. **Admin User Creation** (first admin account)
   - Manually add to Firestore initially
   - Blocks: All testing

### External Blockers
- None (all dependencies within control)

### Risk Mitigation
- **Payment data incomplete:** Use credit history as fallback
- **Charts too slow:** Implement data aggregation Cloud Functions
- **Large user base:** Add pagination, caching

---

## SUCCESS METRICS

### Technical KPIs
- [ ] Page load time <2 seconds
- [ ] All actions complete <1 second
- [ ] 99.9% uptime
- [ ] Zero security incidents
- [ ] Mobile responsive (768px+)

### Business KPIs
- [ ] 100% of user management tasks possible
- [ ] Revenue tracking accurate to SAR 1
- [ ] Content moderation <5 minutes per item
- [ ] Admin satisfaction rating 4.5+/5

### User Acceptance Criteria
- [ ] Can view all users and search
- [ ] Can adjust credits with audit trail
- [ ] Can view payment history
- [ ] Can monitor system health
- [ ] Can moderate content
- [ ] Can export data to CSV

---

## RISKS & MITIGATION

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Firestore queries slow with large data | High | Medium | Add pagination, indexes, caching |
| Admin authentication bypass | Critical | Low | Security audit, role verification |
| Chart rendering performance issues | Medium | Medium | Lazy load charts, optimize queries |
| Payment data incomplete | High | High | Implement Tabby webhooks first |
| Mobile app changes required | Medium | Low | Keep admin logic separate |

---

## POST-LAUNCH OPTIMIZATION

### Week 1 Post-Launch
- Monitor dashboard performance
- Collect admin feedback
- Fix critical bugs
- Optimize slow queries

### Week 2-4 Post-Launch
- Add requested features
- Improve UI/UX based on usage
- Implement automation (scheduled reports)
- Add advanced analytics

### Month 2+
- Scale optimizations
- Advanced search features
- ML-powered insights
- Mobile admin app (optional)

---

## TECHNICAL SPECIFICATIONS

### Firestore Collections (New)

**admins/**
```dart
{
  adminId: string,
  email: string,
  displayName: string,
  role: 'super_admin' | 'admin' | 'moderator' | 'support',
  permissions: {
    canManageUsers: bool,
    canAdjustCredits: bool,
    canModerateContent: bool,
    canViewPayments: bool,
    canManageAdmins: bool,
    canConfigureSettings: bool,
  },
  createdAt: timestamp,
  lastLoginAt: timestamp,
}
```

**audit_logs/**
```dart
{
  logId: string,
  adminId: string,
  action: string, // 'credit_adjustment', 'user_ban', 'content_delete'
  targetType: string, // 'user', 'content', 'setting'
  targetId: string,
  details: map,
  timestamp: timestamp,
}
```

**flags/**
```dart
{
  flagId: string,
  contentId: string,
  userId: string,
  reason: string,
  status: 'pending' | 'approved' | 'deleted',
  moderatorNotes: string,
  createdAt: timestamp,
  resolvedAt: timestamp,
  resolvedBy: string,
}
```

**settings/app-config**
```dart
{
  featureFlags: {
    enableNewUserRegistration: bool,
    enableVideoGeneration: bool,
    enableImageGeneration: bool,
    enableGuestMode: bool,
    maintenanceMode: bool,
  },
  config: {
    creditCostVideo: int,
    creditCostImage: int,
    initialCreditsNewUser: int,
    maxQueueLength: int,
  },
  lastUpdatedBy: string,
  lastUpdatedAt: timestamp,
}
```

**settings/active-banner**
```dart
{
  messageEn: string,
  messageAr: string,
  type: 'info' | 'warning' | 'error',
  active: bool,
  expiresAt: timestamp,
  createdBy: string,
  createdAt: timestamp,
}
```

### Firestore Security Rules (Admin)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Admin collection - only readable by admins
    match /admins/{adminId} {
      allow read: if request.auth != null &&
                     exists(/databases/$(database)/documents/admins/$(request.auth.uid));
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.permissions.canManageAdmins == true;
    }

    // Audit logs - admins only
    match /audit_logs/{logId} {
      allow read: if request.auth != null &&
                     exists(/databases/$(database)/documents/admins/$(request.auth.uid));
      allow create: if request.auth != null &&
                       exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }

    // Flags - moderators and admins
    match /flags/{flagId} {
      allow read: if request.auth != null &&
                     exists(/databases/$(database)/documents/admins/$(request.auth.uid));
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.permissions.canModerateContent == true;
    }

    // Settings - super admins only
    match /settings/{doc} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role == 'super_admin';
    }
  }
}
```

---

## TESTING STRATEGY

### Unit Tests
- [ ] AuthProvider tests
- [ ] DashboardProvider tests
- [ ] UsersProvider tests
- [ ] PaymentsProvider tests
- [ ] ContentProvider tests

### Widget Tests
- [ ] Login screen tests
- [ ] Dashboard layout tests
- [ ] User list table tests
- [ ] Chart rendering tests

### Integration Tests
- [ ] Full user management flow
- [ ] Credit adjustment flow
- [ ] Content moderation flow
- [ ] Payment viewing flow

### E2E Tests
- [ ] Admin login → view users → adjust credits
- [ ] Admin login → view content → delete item
- [ ] Admin login → view payments → export CSV

---

## CONCLUSION

This roadmap provides a complete implementation plan for the Aqvioo Web Admin Dashboard. The phased approach ensures you have a functional MVP quickly while allowing for iterative improvements.

**Next Steps:**
1. Review and approve this roadmap
2. Set up Flutter Web in project (Task 1.1)
3. Create first admin user in Firestore
4. Begin Sprint 1 development

**Questions or Adjustments?**
- Need to prioritize different features?
- Want to add/remove functionality?
- Timeline too aggressive/conservative?

Let's build this! 🚀

---

**Document End**
