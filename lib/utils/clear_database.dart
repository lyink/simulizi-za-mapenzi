import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Utility class to clear all data from Firebase Firestore and Storage
///
/// WARNING: This will permanently delete all data!
/// Use only when you want to start fresh with a clean database.
class DatabaseCleaner {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Delete all documents in a collection
  static Future<int> _deleteCollection(String collectionPath) async {
    debugPrint('🗑️  Deleting collection: $collectionPath');

    int deletedCount = 0;
    try {
      final collection = _firestore.collection(collectionPath);
      final snapshots = await collection.get();

      debugPrint('   Found ${snapshots.docs.length} documents');

      // Delete in batches of 500 (Firestore limit)
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
        deletedCount++;

        if (deletedCount % 10 == 0) {
          debugPrint('   Deleted $deletedCount documents...');
        }
      }

      debugPrint('✅ Deleted $deletedCount documents from $collectionPath');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Error deleting $collectionPath: $e');
      return deletedCount;
    }
  }

  /// Delete all files in a Firebase Storage folder
  static Future<int> _deleteStorageFolder(String folderPath) async {
    debugPrint('🗑️  Deleting storage folder: $folderPath');

    int deletedCount = 0;
    try {
      final ref = _storage.ref().child(folderPath);
      final result = await ref.listAll();

      debugPrint('   Found ${result.items.length} files');

      for (var item in result.items) {
        try {
          await item.delete();
          deletedCount++;

          if (deletedCount % 5 == 0) {
            debugPrint('   Deleted $deletedCount files...');
          }
        } catch (e) {
          debugPrint('   Failed to delete ${item.fullPath}: $e');
        }
      }

      // Recursively delete subfolders
      for (var prefix in result.prefixes) {
        final subFolderCount = await _deleteStorageFolder(prefix.fullPath);
        deletedCount += subFolderCount;
      }

      debugPrint('✅ Deleted $deletedCount files from $folderPath');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Error deleting storage folder $folderPath: $e');
      return deletedCount;
    }
  }

  /// Clear all Firestore collections
  static Future<Map<String, int>> clearAllCollections() async {
    debugPrint('🧹 Starting Firestore cleanup...');
    debugPrint('═' * 50);

    final results = <String, int>{};

    // List of collections to delete
    final collections = [
      'stories',
      'categories',
      'bible',
      'users',
      'notifications',
      // Add any other collections you have
    ];

    for (var collection in collections) {
      final count = await _deleteCollection(collection);
      results[collection] = count;

      // Small delay to avoid overwhelming Firestore
      await Future.delayed(const Duration(milliseconds: 500));
    }

    debugPrint('═' * 50);
    debugPrint('✅ Firestore cleanup complete!');
    debugPrint('Summary:');
    results.forEach((collection, count) {
      debugPrint('   $collection: $count documents deleted');
    });

    return results;
  }

  /// Clear all Firebase Storage files
  static Future<Map<String, int>> clearAllStorage() async {
    debugPrint('🧹 Starting Firebase Storage cleanup...');
    debugPrint('═' * 50);

    final results = <String, int>{};

    // List of storage folders to delete
    final folders = [
      'covers',
      'images',
      'thumbnails',
      'uploads',
      // Add any other storage folders you have
    ];

    for (var folder in folders) {
      try {
        final count = await _deleteStorageFolder(folder);
        results[folder] = count;

        // Small delay to avoid overwhelming Storage
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('⚠️  Folder $folder might not exist or is empty');
        results[folder] = 0;
      }
    }

    debugPrint('═' * 50);
    debugPrint('✅ Firebase Storage cleanup complete!');
    debugPrint('Summary:');
    results.forEach((folder, count) {
      debugPrint('   $folder: $count files deleted');
    });

    return results;
  }

  /// Clear EVERYTHING - Firestore + Storage
  ///
  /// WARNING: This is irreversible!
  static Future<void> clearEverything() async {
    debugPrint('');
    debugPrint('🚨 STARTING COMPLETE DATABASE CLEANUP 🚨');
    debugPrint('⚠️  This will delete ALL data permanently!');
    debugPrint('');

    try {
      // Step 1: Clear Firestore
      final firestoreResults = await clearAllCollections();
      final totalDocuments = firestoreResults.values.reduce((a, b) => a + b);

      // Step 2: Clear Storage
      final storageResults = await clearAllStorage();
      final totalFiles = storageResults.values.reduce((a, b) => a + b);

      debugPrint('');
      debugPrint('═' * 50);
      debugPrint('🎉 CLEANUP COMPLETE!');
      debugPrint('═' * 50);
      debugPrint('📊 Total deleted:');
      debugPrint('   • Firestore documents: $totalDocuments');
      debugPrint('   • Storage files: $totalFiles');
      debugPrint('');
      debugPrint('✨ Your database is now clean and ready for fresh data!');
      debugPrint('═' * 50);
    } catch (e) {
      debugPrint('');
      debugPrint('❌ ERROR during cleanup: $e');
      debugPrint('Some data may not have been deleted.');
    }
  }

  /// Get database statistics before cleanup
  static Future<Map<String, int>> getDatabaseStats() async {
    debugPrint('📊 Gathering database statistics...');

    final stats = <String, int>{};

    final collections = ['stories', 'categories', 'bible', 'users'];

    for (var collection in collections) {
      try {
        final snapshot = await _firestore.collection(collection).get();
        stats[collection] = snapshot.docs.length;
      } catch (e) {
        stats[collection] = 0;
      }
    }

    debugPrint('Current database contents:');
    stats.forEach((collection, count) {
      debugPrint('   $collection: $count documents');
    });

    return stats;
  }
}

/// Widget to provide a UI for database cleanup
class DatabaseCleanupScreen extends StatefulWidget {
  const DatabaseCleanupScreen({super.key});

  @override
  State<DatabaseCleanupScreen> createState() => _DatabaseCleanupScreenState();
}

class _DatabaseCleanupScreenState extends State<DatabaseCleanupScreen> {
  bool _isProcessing = false;
  Map<String, int>? _stats;
  String _statusMessage = 'Ready to clean database';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await DatabaseCleaner.getDatabaseStats();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _clearDatabase() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm Deletion'),
        content: const Text(
          'This will permanently delete ALL data:\n\n'
          '• All stories\n'
          '• All categories\n'
          '• All Bible content\n'
          '• All images in storage\n\n'
          'This action CANNOT be undone!\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Deleting all data...';
    });

    try {
      await DatabaseCleaner.clearEverything();

      setState(() {
        _isProcessing = false;
        _statusMessage = '✅ Database cleared successfully!';
      });

      // Reload stats
      await _loadStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Cleanup'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning card
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.warning, size: 48, color: Colors.red.shade700),
                    const SizedBox(height: 8),
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will permanently delete ALL data from your database and storage. This action cannot be undone!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats card
            if (_stats != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Database Contents:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._stats!.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                '${entry.value} documents',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Status message
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _statusMessage.contains('Error') ? Colors.red : Colors.black87,
              ),
            ),

            const Spacer(),

            // Delete button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _clearDatabase,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete_forever),
              label: Text(_isProcessing ? 'Deleting...' : 'Clear All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // Refresh stats button
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Stats'),
            ),
          ],
        ),
      ),
    );
  }
}
