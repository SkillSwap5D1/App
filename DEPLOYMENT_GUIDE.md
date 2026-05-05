# Firebase Setup: Option 2 - University Email Verification via Custom Claims

## 🚀 Quick Deployment Steps

### Step 1: Install Firebase CLI (one-time)
```bash
npm install -g firebase-tools
```

### Step 2: Authenticate with Firebase
```bash
firebase login
```
This opens a browser to authenticate with your Google account. Select the appropriate Google account.

### Step 3: Install Cloud Functions Dependencies
```bash
cd /Applications/Software\ Engineering\ /skillswap_app/functions
npm install
```

### Step 4: Deploy to Firebase
**Deploy everything (recommended):**
```bash
firebase deploy --project=cw-skillswap
```

**Or deploy individually:**
```bash
# Cloud Functions only
firebase deploy --only functions --project=cw-skillswap

# Firestore Rules only
firebase deploy --only firestore:rules --project=cw-skillswap
```

### Step 5: Verify Deployment ✓
After deployment completes, check:

**Cloud Functions:** https://console.firebase.google.com/project/cw-skillswap/functions
- Should show 5 functions deployed:
  - `setUniversityUserClaims` ✓
  - `deleteUserData` ✓
  - `verifyUniversityEmail` ✓
  - `sendVerificationEmail` ✓
  - `onEmailChange` ✓

**Firestore Rules:** https://console.firebase.google.com/project/cw-skillswap/firestore/rules
- Should show rules deployed successfully

---

## 🔐 How Option 2 Works

### Authentication Flow

```
Registration:
┌─────────────────────────────────────────────────────┐
│ 1. User enters test@mymyport.ac.uk email                │
│    ↓                                                 │
│ 2. Frontend validates: ends with @mymyport.ac.uk? ✓     │
│    ↓                                                 │
│ 3. User signs up with Firebase Auth                 │
│    ↓                                                 │
│ 4. Cloud Function triggered: setUniversityUserClaims│
│    - Checks email domain: @mymyport.ac.uk? ✓            │
│    - Sets custom JWT claims                         │
│    - Creates Firestore user document                │
│    ↓                                                 │
│ 5. User can now access app                          │
│    All data requests verify custom claims!          │
└─────────────────────────────────────────────────────┘

Non-University User (Blocked):
┌─────────────────────────────────────────────────────┐
│ 1. User enters personal@gmail.com                    │
│    ↓                                                 │
│ 2. Frontend validation fails ✗                      │
│    "Please use your @mymyport.ac.uk email"              │
│ (if they bypass frontend)                           │
│    ↓                                                 │
│ 3. Cloud Function auto-deletes user ✗               │
│    "Only @mymyport.ac.uk emails allowed"                │
└─────────────────────────────────────────────────────┘
```

### Custom Claims Structure

When a university user authenticates, their JWT token includes:
```json
{
  "isUniversityUser": true,
  "emailDomain": "myport.ac.uk",
  "claimsSetAt": "2026-04-28T12:00:00Z"
}
```

These claims are:
- **Set** by `setUniversityUserClaims` Cloud Function on signup
- **Verified** by `_verifyUniversityClaims()` in AuthProvider after signin
- **Enforced** by Firestore Security Rules on every database access

---

## 🧪 Testing the Setup

### Test with Valid University Email

1. **In the SkillSwap app:**
   - Open RegisterScreen
   - Enter email: `test@mymyport.ac.uk`
   - Enter password and confirm
   - Tap "Create Account"
   - Should succeed ✓

2. **Verify in Firebase Console:**
   - Go to Authentication tab
   - Find the user you just created
   - Check custom claims are set

3. **Test Firestore Access:**
   - Create a listing from the app
   - Check Firestore Console → listings collection
   - New document should appear

### Test with Invalid Email

1. **In the app:**
   - Try to register with: `personal@gmail.com`
   - Frontend will reject immediately

2. **If you bypass frontend (testing):**
   - Cloud Function auto-deletes within seconds
   - Check Firebase Console Authentication tab
   - User will be gone

---

## 📋 What Each Cloud Function Does

### `setUniversityUserClaims` (onCreate)
**Triggered:** Every time a new user signs up
**Actions:**
- Validates email ends with @mymyport.ac.uk
- If invalid: AUTO-DELETES user from Firebase Auth
- If valid: Sets custom claims in JWT token
- Creates Firestore user document with privacy settings

**Example:**
```
User: john.smith@mymyport.ac.uk → ✓ Claims set, user document created
User: hacker@evil.com → ✗ Deleted within milliseconds
```

### `deleteUserData` (onDelete)
**Triggered:** When user deletes their account
**Actions:**
- Anonymizes user profile data
- Deletes messages, reviews, reports (GDPR)
- Marks user as inactive

### `verifyUniversityEmail` (Callable)
**Called from:** RegisterScreen before signup
**Returns:** `{ success: true, domain: "myport.ac.uk" }`

### `sendVerificationEmail` (Callable)
**Called from:** RegisterScreen after signup
**Note:** Currently logs to console. Integrate SendGrid/similar for production.

### `onEmailChange` (onUpdate)
**Triggered:** When user updates their email
**Actions:**
- Revokes claims if changed to non-university domain
- Updates claims if changed to another @mymyport.ac.uk email

---

## 🔒 Firestore Security Rules

Every collection (users, listings, requests, messages, etc.) has rules like:

```firestore
match /listings/{id} {
  allow read: if request.auth.token.isUniversityUser == true &&
              request.auth.token.emailDomain == 'myport.ac.uk';
  allow write: if ... (owner only)
}
```

**Result:**
- ❌ Non-university users cannot read ANY data
- ❌ Missing custom claims = database access denied
- ✓ Only verified @mymyport.ac.uk users can access

---

## 🛠️ Troubleshooting

### "Email is required" error in registration
**Solution:** Make sure you're using `@mymyport.ac.uk`, not any other domain

### User appears to register but then disappears
**Expected behavior!** If email isn't @mymyport.ac.uk, Cloud Function deletes them within 1-2 seconds.

### "Custom claims verification failed" on sign-in
**Fix:** User likely registered with non-university email (Firebase deleted them). Try again with @mymyport.ac.uk.

### Firestore Rules show compile error
**Check:** Make sure `firestore.rules` file is saved. Deploy again with:
```bash
firebase deploy --only firestore:rules --project=cw-skillswap
```

### Functions won't deploy
**Check:**
1. Are you in the right directory? `cd functions`
2. Is Node 18 installed? `node --version`
3. Run `npm install` first

---

## ✅ Security Checklist

- [x] Frontend validates @mymyport.ac.uk emails
- [x] Cloud Function auto-deletes non-university users
- [x] Custom claims required for ALL Firestore access
- [x] Blocking system prevents access between blocked users
- [x] User deletion anonymizes data (GDPR)
- [x] All collections enforce university-only access
- [x] No data visible to non-authenticated users

---

## 📱 Testing Checklist

- [ ] Register with `test@mymyport.ac.uk` → Should succeed
- [ ] Sign in with the same credentials → Should work
- [ ] Create a listing → Should appear in Firestore
- [ ] Open app incognito/private mode (unsigned in) → Should show login
- [ ] Frontend rejects `gmail.com` emails → Should show error
- [ ] Check Firebase Console for deployed functions → All 5 visible
- [ ] Check Firestore Rules tab → Shows deployed rules

---

## 🚀 Production Checklist

- [ ] Email verification enabled (Firebase Auth settings)
- [ ] SendGrid/similar integrated for verification emails
- [ ] Firebase billing enabled
- [ ] Firestore daily backup configured
- [ ] Custom domain email provider configured (if needed)
- [ ] GDPR compliance reviewed (right-to-be-forgotten is implemented)
- [ ] Load testing with Firebase Emulator completed
- [ ] Staging environment tested before production

---

## 📞 Support

For issues:
1. Check Firebase Console → Functions → Logs
2. Check Firebase Console → Firestore → Rules → Test Rules
3. Run local emulator: `firebase emulators:start`

**Key URLs:**
- Firebase Console: https://console.firebase.google.com/project/cw-skillswap
- Functions: https://console.firebase.google.com/project/cw-skillswap/functions
- Firestore: https://console.firebase.google.com/project/cw-skillswap/firestore
- Auth: https://console.firebase.google.com/project/cw-skillswap/authentication
