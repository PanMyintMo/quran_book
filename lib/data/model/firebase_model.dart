import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/data/vos/donation_vo.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:uuid/uuid.dart';

class FirebaseModel {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  final _storage = FirebaseStorage.instance;

  // ---------------------------- Firebase Auth ----------------------------

  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Re-throw the original exception so UI can read `e.code` (wrong-password, user-not-found, etc.)
      throw e;
    } catch (e) {
      throw Exception('Unexpected error during login: ${e.toString()}');
    }
  }

  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Unexpected error during registration: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  User? get currentUser => _auth.currentUser;

  // ---------------------------- Firebase Storage ----------------------------

  Future<String> uploadFile(File file, String folder) async {
    try {
      final fileName = const Uuid().v4();
      final storageRef = _storage.ref('$folder/$fileName');
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('File upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during file upload: ${e.toString()}');
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('File deletion failed: ${e.toString()}');
    }
  }

  // ---------------------------- Book ----------------------------

  Future<void> createBook(BookVO book) async {
    try {
      await _database.child('books').child(book.id).set(book.toJson());
    } catch (e) {
      throw Exception('Failed to create book: ${e.toString()}');
    }
  }

  Future<List<BookVO>> getAllBooks() async {
    try {
      final snapshot = await _database.child('books').get();
      return (snapshot.value as Map<dynamic, dynamic>?)?.entries.map((e) => BookVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch books: ${e.toString()}');
    }
  }

  Stream<List<BookVO>> watchAllBooks() {
    return _database.child('books').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return data?.entries.map((e) => BookVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ?? [];
    });
  }

  Future<void> updateBook(BookVO book) async {
    try {
      await _database.child('books').child(book.id).update(book.toJson());
    } catch (e) {
      throw Exception('Failed to update book: ${e.toString()}');
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _database.child('books').child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete book: ${e.toString()}');
    }
  }

  Future<void> toggleBookmark(String bookId, String userId) async {
    try {
      final bookmarkRef =
          _database.child('books').child(bookId).child('userIDOfBookMark');

      await bookmarkRef.runTransaction((currentData) {
        final List<String> userIDs = [];

        // Support both Firebase list and map-like shapes safely.
        if (currentData is List) {
          for (final value in currentData) {
            if (value != null) {
              userIDs.add(value.toString());
            }
          }
        } else if (currentData is Map) {
          for (final value in currentData.values) {
            if (value != null) {
              userIDs.add(value.toString());
            }
          }
        }

        if (userIDs.contains(userId)) {
          userIDs.remove(userId);
        } else {
          userIDs.add(userId);
        }

        // Save as list consistently.
        return Transaction.success(userIDs);
      });
    } catch (e) {
      throw Exception('Failed to toggle bookmark: ${e.toString()}');
    }
  }

  String _normalizeBookType(String? rawType) {
    final value = (rawType ?? '').trim().toLowerCase();
    if (value.isEmpty || value == 'new') return 'new';
    if (value == 'popular') return 'popular';
    if (value == 'premium' ||
        value == 'preminum' ||
        value == 'preminus' ||
        value == 'premius') {
      return 'premium';
    }
    return 'new';
  }

  Future<int> migrateBookTypes() async {
    try {
      final snapshot = await _database.child('books').get();
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null || data.isEmpty) return 0;

      int updatedCount = 0;
      for (final entry in data.entries) {
        final bookId = entry.key.toString();
        final raw = Map<String, dynamic>.from(entry.value as Map);
        final normalizedType = _normalizeBookType(raw['bookType']?.toString());
        final existingType = raw['bookType']?.toString().trim().toLowerCase();

        if (existingType != normalizedType) {
          await _database
              .child('books')
              .child(bookId)
              .update({'bookType': normalizedType});
          updatedCount++;
        }
      }
      return updatedCount;
    } catch (e) {
      throw Exception('Failed to migrate book types: ${e.toString()}');
    }
  }

  // ---------------------------- Category ----------------------------

  Future<void> createCategory(CategoryVO category) async {
    try {
      await _database.child('categories').child(category.id).set(category.toJson());
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }

  Future<List<CategoryVO>> getAllCategories() async {
    try {
      final snapshot = await _database.child('categories').get();
      return (snapshot.value as Map<dynamic, dynamic>?)
              ?.entries
              .map((e) => CategoryVO.fromJson(Map<String, dynamic>.from(e.value)))
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  Stream<List<CategoryVO>> watchAllCategories() {
    return _database.child('categories').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return data?.entries.map((e) => CategoryVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ?? [];
    });
  }

  Future<void> deleteCategory(String id, String imageUrl) async {
    try {
      await deleteFile(imageUrl);
      await _database.child('categories').child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  Future<void> updateCategory(CategoryVO category) async {
    try {
      await _database
          .child('categories')
          .child(category.id)
          .update(category.toJson());
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }

  // ---------------------------- User ----------------------------

  Future<void> createUser(UserVO user) async {
    try {
      await _database.child('users').child(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<List<UserVO>> getAllUsers() async {
    try {
      final snapshot = await _database.child('users').get();
      return (snapshot.value as Map<dynamic, dynamic>?)?.entries.map((e) => UserVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Stream<List<UserVO>> watchAllUsers() {
    return _database.child('users').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return data?.entries.map((e) => UserVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ?? [];
    });
  }

  Future<void> deleteUser(String id) async {
    try {
      await _database.child('users').child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  Future<UserVO?> getCurrentUserVO() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) return null;
      final snapshot = await _database.child('users').child(userId).get();
      if (!snapshot.exists) return null;
      return UserVO.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  /// Updates display name in Realtime Database and Firebase Auth profile.
  Future<void> updateCurrentUserName(String newName) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception('Not signed in');
    }
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    try {
      await _database.child('users').child(uid).update({
        'name': trimmed,
        'updateAt': DateTime.now().toIso8601String(),
      });
      final authUser = currentUser;
      if (authUser != null) {
        await authUser.updateDisplayName(trimmed);
        await authUser.reload();
      }
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // ---------------------------- Donation ----------------------------

  Future<void> createDonation(DonationVO donation) async {
    try {
      await _database.child('donations').child(donation.id).set(donation.toJson());
    } catch (e) {
      throw Exception('Failed to create donation: ${e.toString()}');
    }
  }

  Future<void> updateDonation(DonationVO donation) async {
    try {
      await _database
          .child('donations')
          .child(donation.id)
          .update(donation.toJson());
    } catch (e) {
      throw Exception('Failed to update donation: ${e.toString()}');
    }
  }

  Future<List<DonationVO>> getAllDonations() async {
    try {
      final snapshot = await _database.child('donations').get();
      return (snapshot.value as Map<dynamic, dynamic>?)
              ?.entries
              .map((e) => DonationVO.fromJson(Map<String, dynamic>.from(e.value)))
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch donations: ${e.toString()}');
    }
  }

  Stream<List<DonationVO>> watchAllDonations() {
    return _database.child('donations').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return data?.entries.map((e) => DonationVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ?? [];
    });
  }

  Future<void> deleteDonation(String id, String imageUrl) async {
    try {
      await deleteFile(imageUrl);
      await _database.child('donations').child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete donation: ${e.toString()}');
    }
  }

  // ---------------------------- Banner ----------------------------

  Future<void> createBanner(BannerVO banner) async {
    try {
      await _database.child('banners').child(banner.id).set(banner.toJson());
    } catch (e) {
      throw Exception('Failed to create banner: ${e.toString()}');
    }
  }

  Future<void> updateBanner(BannerVO banner) async {
    try {
      await _database.child('banners').child(banner.id).update(banner.toJson());
    } catch (e) {
      throw Exception('Failed to update banner: ${e.toString()}');
    }
  }

  Future<List<BannerVO>> getAllBanners() async {
    try {
      final snapshot = await _database.child('banners').get();
      return (snapshot.value as Map<dynamic, dynamic>?)
              ?.entries
              .map((e) => BannerVO.fromJson(Map<String, dynamic>.from(e.value)))
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch banners: ${e.toString()}');
    }
  }

  Stream<List<BannerVO>> watchAllBanners() {
    return _database.child('banners').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return data?.entries.map((e) => BannerVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ?? [];
    });
  }

  Future<void> deleteBanner(String id, String imageUrl) async {
    try {
      await deleteFile(imageUrl);
      await _database.child('banners').child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete banner: ${e.toString()}');
    }
  }

  // ---------------------------- Total Count Methods ----------------------------

  Future<int> getTotalCategoryCount() async {
    try {
      final snapshot = await _database.child('categories').get();
      final map = snapshot.value as Map<dynamic, dynamic>?;
      return map?.length ?? 0;
    } catch (e) {
      throw Exception('Failed to get category count: ${e.toString()}');
    }
  }

  Future<int> getTotalBookCount() async {
    try {
      final snapshot = await _database.child('books').get();
      final map = snapshot.value as Map<dynamic, dynamic>?;
      return map?.length ?? 0;
    } catch (e) {
      throw Exception('Failed to get book count: ${e.toString()}');
    }
  }

  Future<int> getTotalReadingCount() async {
    try {
      final books = await getAllBooks();
      final readerIds = <String>{};

      for (final book in books) {
        readerIds.addAll(book.readBy.map((user) => user.id));
      }

      return readerIds.length;
    } catch (e) {
      throw Exception('Failed to get total reading count: ${e.toString()}');
    }
  }

  Future<int> getTotalUserCount() async {
    try {
      final snapshot = await _database.child('users').get();
      final map = snapshot.value as Map<dynamic, dynamic>?;
      return map?.length ?? 0;
    } catch (e) {
      throw Exception('Failed to get user count: ${e.toString()}');
    }
  }

  Future<int> getTotalBannerCount() async {
    try {
      final snapshot = await _database.child('banners').get();
      final map = snapshot.value as Map<dynamic, dynamic>?;
      return map?.length ?? 0;
    } catch (e) {
      throw Exception('Failed to get banner count: ${e.toString()}');
    }
  }

  Future<int> getTotalDonationCount() async {
    try {
      final snapshot = await _database.child('donations').get();
      final map = snapshot.value as Map<dynamic, dynamic>?;
      return map?.length ?? 0;
    } catch (e) {
      throw Exception('Failed to get donation count: ${e.toString()}');
    }
  }
}
