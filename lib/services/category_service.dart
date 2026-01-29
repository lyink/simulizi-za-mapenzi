import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'categories';

  // Get all categories
  Stream<List<Category>> getCategories() {
    return _firestore
        .collection(_collectionName)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Category.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }

  // Add a new category
  Future<String?> addCategory(Category category) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      return null;
    }
  }

  // Update category
  Future<bool> updateCategory(String categoryId, Category category) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(categoryId)
          .update(category.toFirestore());
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  // Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_collectionName).doc(categoryId).delete();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // Get category names only (for dropdowns)
  Future<List<String>> getCategoryNames() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    } catch (e) {
      print('Error fetching category names: $e');
      return [];
    }
  }

  // Initialize default categories (run once)
  Future<void> initializeDefaultCategories() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      if (snapshot.docs.isNotEmpty) {
        return; // Categories already exist
      }

      final defaultCategories = [
        Category(
          id: '',
          name: 'Mapenzi ya Kwanza',
          description: 'Hadithi za mapenzi ya kwanza',
          iconName: 'favorite',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '',
          name: 'Mapenzi ya Shule',
          description: 'Mapenzi katika mazingira ya shule',
          iconName: 'school',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '',
          name: 'Mapenzi ya Kazi',
          description: 'Mapenzi kazini au ofisini',
          iconName: 'work',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '',
          name: 'Mapenzi ya Ndoa',
          description: 'Hadithi za maisha ya ndoa',
          iconName: 'family_restroom',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '',
          name: 'Mapenzi Yaliyopotea',
          description: 'Mapenzi yaliyopotea au kupatikana tena',
          iconName: 'search',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '',
          name: 'Mapenzi ya Ajabu',
          description: 'Hadithi za ajabu za mapenzi',
          iconName: 'stars',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '',
          name: 'Mapenzi ya Kisasa',
          description: 'Mapenzi ya kisasa',
          iconName: 'phone_android',
          createdAt: DateTime.now(),
        ),
        Category(
          id: '',
          name: 'Mapenzi ya Jadi',
          description: 'Mapenzi ya kimila',
          iconName: 'history',
          createdAt: DateTime.now(),
        ),
      ];

      for (final category in defaultCategories) {
        await addCategory(category);
      }

      print('Default categories initialized successfully');
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  // Update story count for a category
  Future<void> updateStoryCount(String categoryName) async {
    try {
      // Get the category document
      final categorySnapshot = await _firestore
          .collection(_collectionName)
          .where('name', isEqualTo: categoryName)
          .limit(1)
          .get();

      if (categorySnapshot.docs.isEmpty) return;

      final categoryId = categorySnapshot.docs.first.id;

      // Count stories in this category
      final storiesSnapshot = await _firestore
          .collection('stories')
          .where('category', isEqualTo: categoryName)
          .get();

      final count = storiesSnapshot.docs.length;

      // Update the category
      await _firestore.collection(_collectionName).doc(categoryId).update({
        'storyCount': count,
      });
    } catch (e) {
      print('Error updating story count: $e');
    }
  }
}
