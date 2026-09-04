import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:quran_book/services/auth_token_cache_service.dart';
import 'package:quran_book/services/app_cache_service.dart';
import 'package:quran_book/services/auth_proxy_service.dart';
import 'package:quran_book/services/firebase_rest_auth_service.dart';
import 'package:quran_book/services/content_mirror_service.dart';
import 'package:quran_book/services/firebase_rest_database_service.dart';
import 'package:quran_book/services/offline_content_service.dart';
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
  final AuthProxyService _authProxyService = AuthProxyService();
  final FirebaseRestAuthService _restAuthService = FirebaseRestAuthService();
  final FirebaseRestDatabaseService _restDatabaseService =
      FirebaseRestDatabaseService();
  final ContentMirrorService _contentMirrorService = ContentMirrorService();

  // ---------------------------- Firebase Auth ----------------------------

  bool _isLikelyNetworkError(Object error) {
    if (error is FirebaseAuthException) {
      final code = error.code.toLowerCase();
      final message = (error.message ?? '').toLowerCase();
      return code == 'network-request-failed' ||
          message.contains('network') ||
          message.contains('internet') ||
          message.contains('failed to fetch') ||
          message.contains('connection') ||
          message.contains('timeout') ||
          message.contains('unreachable');
    }

    final raw = error.toString().toLowerCase();
    return raw.contains('network') ||
        raw.contains('internet') ||
        raw.contains('failed to fetch') ||
        raw.contains('connection') ||
        raw.contains('timeout') ||
        raw.contains('unreachable') ||
        raw.contains('socketexception');
  }

  Future<void> _loginWithFallbacks(
    String email,
    String password,
  ) async {
    if (_authProxyService.isConfigured) {
      await _authProxyService.login(email, password);
      return;
    }
    await _restAuthService.login(email, password);
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));
      return;
    } on FirebaseAuthException catch (e) {
      if (_isLikelyNetworkError(e)) {
        return _loginWithFallbacks(email, password);
      }
      throw e;
    } on SocketException {
      return _loginWithFallbacks(email, password);
    } on TimeoutException {
      return _loginWithFallbacks(email, password);
    } catch (e) {
      if (_isLikelyNetworkError(e)) {
        return _loginWithFallbacks(email, password);
      }
      throw Exception('Unexpected error during login: ${e.toString()}');
    }
  }

  Future<void> _registerWithFallbacks(
    String email,
    String password,
  ) async {
    if (_authProxyService.isConfigured) {
      await _authProxyService.register(email, password);
      return;
    }
    await _restAuthService.register(email, password);
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));
      return;
    } on FirebaseAuthException catch (e) {
      if (_isLikelyNetworkError(e)) {
        return _registerWithFallbacks(email, password);
      }
      throw e;
    } on SocketException {
      return _registerWithFallbacks(email, password);
    } on TimeoutException {
      return _registerWithFallbacks(email, password);
    } catch (e) {
      if (_isLikelyNetworkError(e)) {
        return _registerWithFallbacks(email, password);
      }
      throw Exception('Unexpected error during registration: ${e.toString()}');
    }
  }

  Future<String> resolveAuthUserId() async {
    final sdkUid = _auth.currentUser?.uid;
    if (sdkUid != null && sdkUid.isNotEmpty) return sdkUid;

    final cachedUid = await AuthTokenCacheService.getCachedUid();
    if (cachedUid != null && cachedUid.isNotEmpty) return cachedUid;

    throw FirebaseAuthException(
      code: 'not-authenticated',
      message: 'Not signed in',
    );
  }

  Future<void> logout() async {
    try {
      await AuthTokenCacheService.clearSession();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  bool isLoggedIn() {
    return _auth.currentUser != null || AuthTokenCacheService.hasActiveSession;
  }

  User? get currentUser => _auth.currentUser;

  static const Duration _databaseTimeout = Duration(seconds: 12);

  List<T> _parseListFromSnapshot<T>(
    DataSnapshot snapshot,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = snapshot.value;
    if (data is! Map) return <T>[];
    return data.entries
        .map((e) => fromJson(Map<String, dynamic>.from(e.value as Map)))
        .toList();
  }

  Stream<List<T>> _resilientWatchList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) {
    return Stream<List<T>>.multi((controller) {
      StreamSubscription<DatabaseEvent>? subscription;

      Future<void> start() async {
        final cached = await AppCacheService.loadList(path, fromJson);
        final fresh =
            await _fetchListWithFallbacks(path, fromJson, toJson);
        final items = fresh.isNotEmpty ? fresh : cached;

        if (!controller.isClosed) {
          controller.add(items);
        }

        subscription = _database.child(path).onValue.listen(
          (event) {
            if (controller.isClosed) return;
            final list = _parseListFromSnapshot(event.snapshot, fromJson);
            controller.add(list);
            unawaited(
              AppCacheService.saveList(
                path,
                list.map((item) => toJson(item)).toList(),
              ),
            );
          },
          onError: (_) {},
        );
      }

      start();
      controller.onCancel = () => subscription?.cancel();
    });
  }

  Future<List<T>> _fetchListWithFallbacks<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    Future<List<T>?> tryMirror() async {
      try {
        return await _contentMirrorService.fetchList(path, fromJson);
      } catch (_) {
        return null;
      }
    }

    final mirrored = await tryMirror();
    if (mirrored != null) {
      if (mirrored.isNotEmpty) {
        await AppCacheService.saveList(
          path,
          mirrored.map((item) => toJson(item)).toList(),
        );
        return mirrored;
      }
      final cached = await AppCacheService.loadList(path, fromJson);
      if (cached.isNotEmpty) return cached;
      return mirrored;
    }

    Future<List<T>> tryRest() async {
      try {
        final list = await _restDatabaseService.fetchList(path, fromJson);
        if (list.isNotEmpty) {
          await AppCacheService.saveList(
            path,
            list.map((item) => toJson(item)).toList(),
          );
        }
        return list;
      } catch (_) {
        return <T>[];
      }
    }

    Future<List<T>> trySdk() async {
      try {
        final snapshot = await _database
            .child(path)
            .get()
            .timeout(_databaseTimeout);
        final list = _parseListFromSnapshot(snapshot, fromJson);
        if (list.isNotEmpty) {
          await AppCacheService.saveList(
            path,
            list.map((item) => toJson(item)).toList(),
          );
        }
        return list;
      } catch (_) {
        return <T>[];
      }
    }

    final results = await Future.wait([tryRest(), trySdk()]);
    for (final list in results) {
      if (list.isNotEmpty) return list;
    }

    return AppCacheService.loadList(path, fromJson);
  }

  /// Prefetches books, categories, and banners for the home screen.
  Future<void> refreshHomeContent() async {
    final results = await Future.wait([
      _fetchListWithFallbacks('books', BookVO.fromJson, (b) => b.toJson()),
      _fetchListWithFallbacks(
        'categories',
        CategoryVO.fromJson,
        (c) => c.toJson(),
      ),
      _fetchListWithFallbacks('banners', BannerVO.fromJson, (b) => b.toJson()),
    ]);

    final books = results[0] as List<BookVO>;
    final categories = results[1] as List<CategoryVO>;
    final banners = results[2] as List<BannerVO>;

    await OfflineContentService.prefetchHomeImages(
      books: books,
      categories: categories,
      banners: banners,
    );
  }

  Stream<List<T>> _safeWatchList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) {
    return _resilientWatchList(path, fromJson, toJson);
  }

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
    return _fetchListWithFallbacks('books', BookVO.fromJson, (b) => b.toJson());
  }

  Stream<List<BookVO>> watchAllBooks() {
    return _safeWatchList('books', BookVO.fromJson, (b) => b.toJson());
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
      final books = await getAllBooks();
      if (books.isEmpty) return 0;

      int updatedCount = 0;
      for (final book in books) {
        final normalizedType = _normalizeBookType(book.bookType);
        final existingType = book.bookType?.trim().toLowerCase();
        if (existingType != normalizedType) {
          try {
            await _database
                .child('books')
                .child(book.id)
                .update({'bookType': normalizedType})
                .timeout(_databaseTimeout);
            updatedCount++;
          } catch (_) {}
        }
      }
      return updatedCount;
    } catch (_) {
      return 0;
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
    return _fetchListWithFallbacks(
      'categories',
      CategoryVO.fromJson,
      (c) => c.toJson(),
    );
  }

  Stream<List<CategoryVO>> watchAllCategories() {
    return _safeWatchList(
      'categories',
      CategoryVO.fromJson,
      (c) => c.toJson(),
    );
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

  Future<bool> tryCreateUser(UserVO user) async {
    try {
      await _database
          .child('users')
          .child(user.id)
          .set(user.toJson())
          .timeout(_databaseTimeout);
      return true;
    } catch (_) {
      return _restDatabaseService.setValue(
        'users/${user.id}',
        user.toJson(),
      );
    }
  }

  Future<void> createUser(UserVO user) async {
    try {
      await _database.child('users').child(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<List<UserVO>> getAllUsers() async {
    return _fetchListWithFallbacks('users', UserVO.fromJson, (u) => u.toJson());
  }

  Stream<List<UserVO>> watchAllUsers() {
    return _safeWatchList('users', UserVO.fromJson, (u) => u.toJson());
  }

  Future<void> deleteUser(String id) async {
    try {
      await _database.child('users').child(id).remove();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  UserVO _userVoFromAuthUser(User authUser) {
    final email = authUser.email ?? '';
    final displayName = authUser.displayName?.trim();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (email.isNotEmpty ? email.split('@').first : 'User');

    return UserVO(
      id: authUser.uid,
      name: name,
      email: email,
      password: '',
      isAdmin: false,
      isDeleteAccount: false,
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    );
  }

  Future<UserVO?> getCurrentUserVO() async {
    final authUser = currentUser;
    final cachedUid = await AuthTokenCacheService.getCachedUid();
    final uid = authUser?.uid ?? cachedUid;
    if (uid == null) return null;

    try {
      final snapshot = await _database
          .child('users')
          .child(uid)
          .get()
          .timeout(_databaseTimeout);
      if (snapshot.exists) {
        return UserVO.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
        );
      }
    } catch (_) {}

    try {
      final data = await _restDatabaseService.fetchObject('users/$uid');
      if (data != null) {
        return UserVO.fromJson(data);
      }
    } catch (_) {}

    if (authUser != null) {
      return _userVoFromAuthUser(authUser);
    }
    return null;
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
    return _fetchListWithFallbacks(
      'donations',
      DonationVO.fromJson,
      (d) => d.toJson(),
    );
  }

  Stream<List<DonationVO>> watchAllDonations() {
    return _safeWatchList(
      'donations',
      DonationVO.fromJson,
      (d) => d.toJson(),
    );
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
    return _fetchListWithFallbacks(
      'banners',
      BannerVO.fromJson,
      (b) => b.toJson(),
    );
  }

  Stream<List<BannerVO>> watchAllBanners() {
    return _safeWatchList('banners', BannerVO.fromJson, (b) => b.toJson());
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
