# How to Check Your Firebase Story Data

## Method 1: Firebase Console (Recommended)

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/project/bible-53642/firestore/data

2. **Navigate to Stories Collection**
   - Click on `stories` collection
   - You'll see all your stories

3. **Check Image URLs**
   - Open any story document
   - Look for the `coverImageUrl` field
   - Check if it has a value or is empty

## Method 2: In Your App

1. **Open Admin Panel**
   - Run your app
   - Open the drawer menu
   - Go to Admin Panel

2. **Manage Stories**
   - Click "Manage Stories"
   - Click "Edit" on any story
   - Scroll to "Cover Image URL" field
   - Check if it's empty

## What You'll See

### If Empty:
```
coverImageUrl: ""
```
- No image will load
- Placeholder (gradient with heart) will show

### If Has URL:
```
coverImageUrl: "https://example.com/image.jpg"
```
- Will try to load the image
- If URL works: Image shows
- If URL fails: Placeholder shows

## Current Status

Based on your sample stories code:
- ❌ All stories have **EMPTY** `coverImageUrl` fields
- ✅ That's why placeholders are showing
- ✅ The field exists and is ready to use

## To Add Images

### Option 1: Manual Entry (Current)
1. Go to Admin Panel → Manage Stories
2. Edit any story
3. Paste image URL in "Cover Image URL" field
4. Save

### Option 2: JSON Import
When importing stories, include `coverImageUrl` in JSON:
```json
{
  "title": "Story Title",
  "coverImageUrl": "https://your-image-url.com/image.jpg",
  ...
}
```

### Option 3: Firebase Storage (Recommended)
Upload images to Firebase Storage and use those URLs.

## Recommended Image Sources

### Good URLs (Will Work):
- ✅ `https://i.imgur.com/abc123.jpg`
- ✅ `https://firebasestorage.googleapis.com/...`
- ✅ Direct image URLs ending in .jpg, .png, .gif

### Bad URLs (Won't Work):
- ❌ Instagram URLs (blocked)
- ❌ Facebook images (blocked)
- ❌ Some social media images
- ❌ URLs requiring authentication

## Quick Test

To test if an image URL works:
1. Copy the URL
2. Paste it in a new browser tab
3. If image shows directly → URL works ✅
4. If shows webpage/error → URL won't work ❌

## Next Steps

1. **Check Firebase Console** to confirm data
2. **Upload images** to Firebase Storage OR
3. **Find public image URLs** that work
4. **Update stories** with image URLs via Admin Panel
