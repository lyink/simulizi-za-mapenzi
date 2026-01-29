# Firestore Index Error Fix

## The Error
You saw this error:
```
Error loading stories
[cloud_firestore/failed-precondition] The query requires an index.
```

This happens because Firestore requires composite indexes when querying with multiple fields (like filtering by category AND ordering by publishedDate).

## ✅ Solution Applied

I've created and deployed the required indexes. The indexes are now being built in Firebase.

### What was done:

1. **Created `firestore.indexes.json`** with all required indexes for:
   - Stories by category + publishedDate
   - Featured stories + publishedDate
   - Stories by views (for popular stories)
   - Stories by title (for search)

2. **Deployed indexes to Firebase** using:
   ```bash
   firebase deploy --only firestore:indexes
   ```

## ⏱️ Wait Time

**Index creation takes 2-5 minutes**. The indexes are being built in the background.

You can check the status at:
https://console.firebase.google.com/project/bible-53642/firestore/indexes

## 🔄 After Indexes are Ready

Once the indexes show as "Enabled" (green checkmark) in Firebase Console:

1. **Restart your app** (hot reload might not be enough)
2. The stories should load without errors
3. All queries will work properly:
   - Load all stories
   - Filter by category
   - Featured stories
   - Popular stories
   - Search

## 📋 Quick Check

Go to: https://console.firebase.google.com/project/bible-53642/firestore/indexes

You should see indexes in either:
- 🟡 **Building** status (wait a few minutes)
- 🟢 **Enabled** status (ready to use)

## Alternative Quick Fix

If you see the error again with a different query, the error message will include a direct link like:
```
https://console.firebase.google.com/v1/r/project/bible-53642/firestore/indexes?create_composite=...
```

Just click that link and it will create the specific index needed.

## For Future Queries

If you add new queries to your app that combine:
- WHERE clauses with ORDER BY
- Multiple WHERE clauses on different fields

You'll need to create indexes for those too. The error message will always provide a direct link to create the required index.

---

**Status**: ✅ Indexes deployed and building
**Expected Ready**: 2-5 minutes from now
**Next Step**: Wait for indexes to finish building, then restart the app
