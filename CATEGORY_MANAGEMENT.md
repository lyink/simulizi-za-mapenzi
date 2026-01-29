# Category Management System

## ✅ Categories Are Now Dynamic!

Categories are no longer hardcoded. They are now stored in Firestore and can be managed through the admin panel.

## 📦 New Files Created

### 1. Models
- ✅ `lib/models/category.dart` - Category data model

### 2. Services
- ✅ `lib/services/category_service.dart` - Firestore operations for categories

### 3. Screens
- ✅ `lib/screens/admin/manage_categories_screen.dart` - Category management UI

## 🎯 Features

### Category Management Screen
- **View All Categories** - See all categories with story counts
- **Add New Category** - Create custom categories with:
  - Name
  - Description
  - Icon selection (8 different icons)
- **Edit Category** - Update existing categories
- **Delete Category** - Remove categories (with warning if stories exist)
- **Initialize Defaults** - One-click setup of 8 default categories

### Available Icons
1. ❤️ Favorite (Mapenzi ya Kwanza)
2. 🎓 School (Mapenzi ya Shule)
3. 💼 Work (Mapenzi ya Kazi)
4. 👨‍👩‍👧 Family (Mapenzi ya Ndoa)
5. 🔍 Search (Mapenzi Yaliyopotea)
6. ⭐ Stars (Mapenzi ya Ajabu)
7. 📱 Modern (Mapenzi ya Kisasa)
8. 🕰️ History (Mapenzi ya Jadi)

## 🔥 Firestore Structure

### Collection: `categories`

```json
{
  "name": "Mapenzi ya Kwanza",
  "description": "Hadithi za mapenzi ya kwanza",
  "iconName": "favorite",
  "storyCount": 3,
  "createdAt": "2024-01-27T10:00:00.000Z"
}
```

### Security Rules

Add these rules to Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Stories collection
    match /stories/{storyId} {
      allow read: if true;
      allow create, delete: if request.auth != null &&
        request.auth.token.admin == true;
      allow update: if request.resource.data.diff(resource.data)
        .affectedKeys().hasOnly(['views', 'likes']);
    }

    // Categories collection
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null &&
        request.auth.token.admin == true;
    }
  }
}
```

## 📱 How to Use

### Access Category Management
1. Open app drawer
2. Tap "Admin Panel"
3. Tap "Dhibiti Makundi" (Manage Categories)

### Initialize Default Categories
1. Go to Category Management
2. If empty, tap "Anza na Makundi ya Msingi" (Start with Default Categories)
3. 8 categories will be created automatically

### Add Custom Category
1. Tap the "+" button (Ongeza Kundi)
2. Enter name and description
3. Select an icon
4. Tap "Ongeza" to save

### Edit Category
1. Tap "Hariri" on any category card
2. Modify name, description, or icon
3. Tap "Hifadhi" to save changes

### Delete Category
1. Tap "Futa" on any category card
2. Confirm deletion
3. Warning will show if stories exist in that category

## 🔧 Integration

### Add/Edit Story Screen
The story form now:
- ✅ Loads categories dynamically from Firestore
- ✅ Shows loading state while fetching
- ✅ Shows warning if no categories exist
- ✅ Validates category selection
- ✅ Updates in real-time when categories change

### Story Service
- Categories are fetched from Firestore
- No hardcoded category lists
- Full CRUD operations available

## 🎨 Default Categories

When initialized, these 8 categories are created:

1. **Mapenzi ya Kwanza** - Hadithi za mapenzi ya kwanza (❤️ Favorite)
2. **Mapenzi ya Shule** - Mapenzi katika mazingira ya shule (🎓 School)
3. **Mapenzi ya Kazi** - Mapenzi kazini au ofisini (💼 Work)
4. **Mapenzi ya Ndoa** - Hadithi za maisha ya ndoa (👨‍👩‍👧 Family)
5. **Mapenzi Yaliyopotea** - Mapenzi yaliyopotea au kupatikana tena (🔍 Search)
6. **Mapenzi ya Ajabu** - Hadithi za ajabu za mapenzi (⭐ Stars)
7. **Mapenzi ya Kisasa** - Mapenzi ya kisasa (📱 Modern)
8. **Mapenzi ya Jadi** - Mapenzi ya kimila (🕰️ History)

## 🚀 Benefits

✅ **Flexible** - Add unlimited custom categories
✅ **Dynamic** - Categories update in real-time
✅ **User-Friendly** - Easy management through admin panel
✅ **Scalable** - No code changes needed to add categories
✅ **Visual** - Each category has a custom icon
✅ **Safe** - Warns before deleting categories with stories

## 📊 Story Count Tracking

Each category tracks the number of stories it contains:
- Updated automatically when stories are added/removed
- Displayed on category cards
- Used to warn before deletion

## 🔄 Workflow

1. **Setup** → Initialize default categories OR add custom ones
2. **Create** → Add stories and assign to categories
3. **Manage** → Edit/delete categories as needed
4. **Scale** → Add more categories as your content grows

## 💡 Tips

- Initialize default categories first for quick start
- Choose descriptive names for easy navigation
- Select appropriate icons for visual recognition
- Delete unused categories to keep things organized
- Categories with 0 stories are safe to delete
