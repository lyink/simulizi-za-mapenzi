import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  /// Generates a new document ID locally — no network call needed.
  String generateId() {
    return _firestore.collection(_collection).doc().id;
  }

  /// Save a book with a pre-generated ID using set() — single network call at the end.
  Future<void> setBook(Book book) async {
    await _firestore
        .collection(_collection)
        .doc(book.id)
        .set(book.toFirestore());
  }

  Stream<List<Book>> getBooks() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> getFeaturedBooks() {
    return _firestore
        .collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> getBooksByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Future<String> addBook(Book book) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(book.toFirestore());
    return docRef.id;
  }

  Future<void> updateBook(Book book) async {
    await _firestore
        .collection(_collection)
        .doc(book.id)
        .update(book.toFirestore());
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection(_collection).doc(bookId).delete();
  }

  Future<void> incrementViews(String bookId) async {
    await _firestore.collection(_collection).doc(bookId).update({
      'views': FieldValue.increment(1),
    });
  }

  Future<Book?> getBookById(String bookId) async {
    final doc =
        await _firestore.collection(_collection).doc(bookId).get();
    if (doc.exists) {
      return Book.fromFirestore(doc);
    }
    return null;
  }
}
