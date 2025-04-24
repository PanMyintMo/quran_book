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
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  User? get currentUser => _auth.currentUser;

  // ---------------------------- Firebase Storage ----------------------------

  Future<String> uploadFile(File file, String folder) async {
    final fileName = const Uuid().v4();
    final storageRef = _storage.ref('$folder/$fileName');
    await storageRef.putFile(file);
    return await storageRef.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  }

  // ---------------------------- Firebase Realtime Database ----------------------------

  // ---------------------------- Book ----------------------------
  Future<void> createBook(BookVO book) async {
    await _database.child('books').child(book.id).set(book.toJson());
  }

  Future<List<BookVO>> getAllBooks() async {
    final snapshot = await _database.child('books').get();
    return (snapshot.value as Map<dynamic, dynamic>?)?.entries.map((e) => BookVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ??
        [];
  }

  Future<void> updateBook(BookVO book) async {
    await _database.child('books').child(book.id).update(book.toJson());
  }

  Future<void> deleteBook(String id) async {
    await _database.child('books').child(id).remove();
  }

  Future<void> toggleBookmark(String bookId, String userId) async {
    final bookSnapshot = await _database.child('books').child(bookId).get();
    if (!bookSnapshot.exists) return;

    final bookData = Map<String, dynamic>.from(bookSnapshot.value as Map);
    final List<String> userIDs = (bookData['userIDOfBookMark'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    if (userIDs.contains(userId)) {
      userIDs.remove(userId);
    } else {
      userIDs.add(userId);
    }

    await _database.child('books').child(bookId).update({'userIDOfBookMark': userIDs});
  }

  // ---------------------------- Category ----------------------------
  Future<void> createCategory(CategoryVO category) async {
    await _database.child('categories').child(category.id).set(category.toJson());
  }

  Future<List<CategoryVO>> getAllCategories() async {
    final snapshot = await _database.child('categories').get();
    return (snapshot.value as Map<dynamic, dynamic>?)
            ?.entries
            .map((e) => CategoryVO.fromJson(Map<String, dynamic>.from(e.value)))
            .toList() ??
        [];
  }

  Future<void> deleteCategory(String id, String imageUrl) async {
    await deleteFile(imageUrl);
    await _database.child('categories').child(id).remove();
  }

  // ---------------------------- User ----------------------------
  Future<void> createUser(UserVO user) async {
    await _database.child('users').child(user.id).set(user.toJson());
  }

  Future<List<UserVO>> getAllUsers() async {
    final snapshot = await _database.child('users').get();
    return (snapshot.value as Map<dynamic, dynamic>?)?.entries.map((e) => UserVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ??
        [];
  }

  Future<void> deleteUser(String id) async {
    await _database.child('users').child(id).remove();
  }

  Future<UserVO?> getCurrentUserVO() async {
    final userId = currentUser?.uid;
    if (userId == null) return null;
    final snapshot = await _database.child('users').child(userId).get();
    if (!snapshot.exists) return null;
    return UserVO.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
  }

  // ---------------------------- Donation ----------------------------
  Future<void> createDonation(DonationVO donation) async {
    await _database.child('donations').child(donation.id).set(donation.toJson());
  }

  Future<List<DonationVO>> getAllDonations() async {
    final snapshot = await _database.child('donations').get();
    return (snapshot.value as Map<dynamic, dynamic>?)
            ?.entries
            .map((e) => DonationVO.fromJson(Map<String, dynamic>.from(e.value)))
            .toList() ??
        [];
  }

  Future<void> deleteDonation(String id, String imageUrl) async {
    await deleteFile(imageUrl);
    await _database.child('donations').child(id).remove();
  }

  // ---------------------------- Banner ----------------------------
  Future<void> createBanner(BannerVO banner) async {
    await _database.child('banners').child(banner.id).set(banner.toJson());
  }

  Future<List<BannerVO>> getAllBanners() async {
    final snapshot = await _database.child('banners').get();
    return (snapshot.value as Map<dynamic, dynamic>?)?.entries.map((e) => BannerVO.fromJson(Map<String, dynamic>.from(e.value))).toList() ??
        [];
  }

  Future<void> deleteBanner(String id, String imageUrl) async {
    await deleteFile(imageUrl);
    await _database.child('banners').child(id).remove();
  }

  // Total Categories Count
  Future<int> getTotalCategoryCount() async {
    final snapshot = await _database.child('categories').get();
    final map = snapshot.value as Map<dynamic, dynamic>?;
    return map?.length ?? 0;
  }

// Total Book (Post) Count
  Future<int> getTotalBookCount() async {
    final snapshot = await _database.child('books').get();
    final map = snapshot.value as Map<dynamic, dynamic>?;
    return map?.length ?? 0;
  }

// Total Reading Count (Unique Users Who Read Books)
  Future<int> getTotalReadingCount() async {
    final books = await getAllBooks();
    final readerIds = <String>{};

    for (final book in books) {
      readerIds.addAll(book.readBy.map((user) => user.id));
    }

    return readerIds.length;
  }

// Total User Count
  Future<int> getTotalUserCount() async {
    final snapshot = await _database.child('users').get();
    final map = snapshot.value as Map<dynamic, dynamic>?;
    return map?.length ?? 0;
  }

// Total Banner Count
  Future<int> getTotalBannerCount() async {
    final snapshot = await _database.child('banners').get();
    final map = snapshot.value as Map<dynamic, dynamic>?;
    return map?.length ?? 0;
  }

// Total Donation Count
  Future<int> getTotalDonationCount() async {
    final snapshot = await _database.child('donations').get();
    final map = snapshot.value as Map<dynamic, dynamic>?;
    return map?.length ?? 0;
  }
}
