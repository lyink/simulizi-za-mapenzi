# Fix Firebase Permission Error ⚠️

## Current Error
```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

This means your Firestore database needs to be set up with proper security rules.

## Step-by-Step Fix

### Step 1: Create Firestore Database

1. Open your Firebase Console: https://console.firebase.google.com/project/bible-53642
2. Click on **"Firestore Database"** in the left sidebar menu
3. Click the **"Create database"** button
4. Select **"Start in test mode"** (for development)
5. Choose your preferred location (e.g., us-central)
6. Click **"Enable"**

### Step 2: Set Up Security Rules

Once the database is created:

1. In Firestore Database, click the **"Rules"** tab at the top
2. Replace the existing rules with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Stories collection - public read, authenticated write
    match /stories/{story} {
      allow read: if true;  // Anyone can read stories
      allow create, update, delete: if request.auth != null;  // Only authenticated users can write
    }

    // Categories collection - public read, authenticated write
    match /categories/{category} {
      allow read: if true;  // Anyone can read categories
      allow create, update, delete: if request.auth != null;  // Only authenticated users can write
    }
  }
}
```

3. Click **"Publish"** to save the rules

### Step 3: For Development (Open Access) - OPTIONAL

If you want completely open access for testing (NOT recommended for production):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // DANGER: Open to all - only for testing!
    }
  }
}
```

⚠️ **Warning**: This allows anyone to read and write to your database. Only use for development!

### Step 4: Verify Setup

After setting up rules:

1. Go back to the **"Data"** tab in Firestore
2. You should see an empty database
3. Hot reload or restart your app
4. The error should be gone and you'll see "No Stories Yet"

### Step 5: Add Sample Data

Now you can add stories through the Admin Panel:

1. Open the app
2. Tap the menu icon (☰)
3. Select **"Admin Panel"**
4. Tap **"Manage Categories"**
5. Tap **"Start with Default Categories"**
6. Go back and tap **"Upload Sample Stories"**
7. Confirm to upload 5 sample stories

OR manually add your own:
1. Tap **"Add New Story"**
2. Fill in all fields
3. Tap **"Publish Story"**

## Troubleshooting

### Still Getting Permission Error?

**Check 1**: Verify database is created
- Go to Firebase Console → Firestore Database
- You should see a "Data" tab with collections

**Check 2**: Verify rules are published
- Go to Rules tab
- Check if your rules show `allow read: if true;`
- Make sure you clicked "Publish"

**Check 3**: Wait a moment
- Rules can take a few seconds to propagate
- Try hot reloading the app (press 'r' in terminal)
- Or fully restart the app (press 'R' in terminal)

**Check 4**: Check Firebase project ID
- In Firebase Console, check the project ID is: `bible-53642`
- In `lib/firebase_options.dart`, verify `projectId: 'bible-53642'`

### Alternative: Use Firebase Authentication

For better security, you can set up Firebase Authentication:

1. In Firebase Console → Authentication → Get Started
2. Enable "Email/Password" provider
3. Create a user account for admin access
4. Update security rules to require auth for writes only

## Next Steps After Fix

Once Firestore is set up:

1. ✅ Error will disappear
2. ✅ "No Stories Yet" message will show
3. ✅ You can add categories and stories via Admin Panel
4. ✅ Stories will display on the main screen
5. ✅ Real-time updates will work

## Need Help?

If you're still having issues:
1. Check Firebase Console → Firestore → Usage tab for error logs
2. Verify internet connection is working
3. Check that google-services.json is in android/app/ folder
4. Run `flutter clean && flutter pub get` and rebuild
