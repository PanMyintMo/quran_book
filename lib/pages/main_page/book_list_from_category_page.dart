import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/pages/main_page/book_listen_details_page.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class BookListFromCategoryPage extends StatefulWidget {
  const BookListFromCategoryPage({
    super.key,
    this.category,
    this.embedInParent = false,
  });

  final CategoryVO? category;

  /// When true, only the list/search body is built (no [Scaffold]); used inside [CategoryDetailPage].
  final bool embedInParent;

  @override
  State<BookListFromCategoryPage> createState() =>
      _BookListFromCategoryPageState();
}

class _BookListFromCategoryPageState extends State<BookListFromCategoryPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  List<BookVO> _books = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      setState(() => _isLoading = true);
      final books = await _firebaseModel.getAllBooks();
      if (mounted) {
        setState(() {
          _books = books;
          _isLoading = false;
          _currentUserId = FirebaseAuth.instance.currentUser?.uid;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar("Failed to load books: $e");
      }
    }
  }

  bool _isBookmarked(BookVO book) {
    final userId = _currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    return book.userIDOfBookMark.contains(userId);
  }

  Future<void> _onTapSave(BookVO book) async {
    final userId = _currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showDialog(
        context: context,
        builder: (_) => const _NeedToRegisterDialogView(
          title: kRegisterAlertTextForSaveText,
        ),
      );
      return;
    }

    final alreadyBookmarked = book.userIDOfBookMark.contains(userId);

    try {
      await _firebaseModel.toggleBookmark(book.id, userId);
      // Optimistic local update for instant UI response.
      setState(() {
        if (alreadyBookmarked) {
          book.userIDOfBookMark.remove(userId);
        } else {
          if (!book.userIDOfBookMark.contains(userId)) {
            book.userIDOfBookMark.add(userId);
          }
        }
        _currentUserId = userId;
      });

      if (!mounted) return;
      context.showSuccessSnackBar(
        alreadyBookmarked ? "Removed from bookmarks." : "Bookmarked successfully!",
      );
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar("Bookmark failed: $e");
    }
  }

  Future<void> _requestListenPermissions() async {
    await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final categoryId = widget.category?.id;

    final byCategory = categoryId == null
        ? _books
        : _books.where((b) => b.category.id == categoryId).toList();

    final filteredBooks = query.isEmpty
        ? byCategory
        : byCategory.where((b) {
            final name = b.name.toLowerCase();
            final author = b.author.toLowerCase();
            final overview = b.overview.toLowerCase();
            return name.contains(query) ||
                author.contains(query) ||
                overview.contains(query);
          }).toList();

    final body = Padding(
      // Keep vertical spacing but let the list/dividers use full screen width.
      padding: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: widget.embedInParent ? kSP10x : kSP20x,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  _searchQuery = text;
                });
              },
              style: const TextStyle(color: kWhiteColor),
              decoration: InputDecoration(
                fillColor: kAppPrimaryColor,
                filled: true,
                hintText: kSearchHintText.tr(),
                hintStyle: const TextStyle(color: kWhiteColor),
                prefixIcon: const Icon(Icons.search, color: kWhiteColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kSP10x),
                ),
              ),
            ),
          ),
          SizedBox(height: widget.embedInParent ? kSP10x : kSP20x),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: kSP40x),
                    itemCount: filteredBooks.length,
                    itemBuilder: (_, index) {
                      final book = filteredBooks[index];
                      return _BookListFromCategoryItemView(
                        index: index + 1,
                        title: book.name,
                        translateBy: book.author,
                        description: book.overview,
                        isSave: _isBookmarked(book),
                        onTapDetail: () {
                          context.navigateToNextPage(
                            BookOverviewPage(
                              isPlay: false,
                              book: book,
                            ),
                          );
                        },
                        onTapSave: () {
                          _onTapSave(book);
                        },
                        onTapPlay: () {
                          final uid = _currentUserId ??
                              FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) {
                            showDialog(
                              context: context,
                              builder: (_) => const _NeedToRegisterDialogView(
                                title: kRegisterAlertTextForPlayText,
                              ),
                            );
                            return;
                          }
                          final audioUrl = book.audio?.url;
                          if (audioUrl == null || audioUrl.isEmpty) {
                            context.showErrorSnackBar('No audio available.');
                            return;
                          }
                          _requestListenPermissions().then((_) {
                            if (!mounted || !context.mounted) return;
                            context.navigateToNextPage(
                              BookListenDetailsPage(
                                title: book.name,
                                audioUrl: audioUrl,
                                coverImageUrl: book.image,
                                autoPlay: true,
                              ),
                            );
                          });
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(
                      height: kSP40x,
                      color: Colors.grey,
                      thickness: 0.3,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ),
          ),
        ],
      ),
    );

    if (widget.embedInParent) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(),
      body: body,
    );
  }
}

class _NeedToRegisterDialogView extends StatelessWidget {
  const _NeedToRegisterDialogView({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kAppPrimaryColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => context.navigateBack(),
              child: const Icon(Icons.close, color: kWhiteColor),
            ),
          ),
          const SizedBox(height: kSP30x),
          EasyTextWidget(
            text: title,
            fontSize: kFontSize16x,
            fontWeight: FontWeight.w600,
            textColor: kWhiteColor,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: kSP20x),
          PrimaryButtonWidget(
            radius: kSP5x,
            width: kSeeAllCategoryRegisterNowButtonWidth,
            height: kSeeAllCategoryRegisterNowButtonHeight,
            backgroundColor: kAppYellowButtonColor,
            onPressed: () {
              context.navigateBack();
              context.navigateToNextPage(const LoginPage());
            },
            buttonText: kRegisterNowText,
          ),
          const SizedBox(height: kSP30x),
        ],
      ),
    );
  }
}

class _BookListFromCategoryItemView extends StatelessWidget {
  const _BookListFromCategoryItemView({
    required this.index,
    required this.title,
    required this.translateBy,
    required this.isSave,
    required this.onTapDetail,
    required this.onTapSave,
    required this.onTapPlay,
    required this.description,
  });

  final int index;
  final String title;
  final String translateBy;
  final bool isSave;
  final VoidCallback onTapDetail;
  final VoidCallback onTapSave;
  final VoidCallback onTapPlay;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(horizontal: kSP40x),
              child: EasyTextWidget(
                text: index.toString(),
                textAlign: TextAlign.center,
                fontSize: kFontSize18x,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: kSP10x),
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.symmetric(horizontal: kSP40x),
              child: EasyTextWidget(
                text: title,
                textAlign: TextAlign.center,
                textColor: kAppPrimaryColor,
                fontSize: kFontSize21x,
                fontWeight: FontWeight.w600,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: kSP20x),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: EasyTextWidget(
                      text: 'Translation by $translateBy',
                      fontSize: kFontSize12x,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTapSave,
                    child: Padding(
                      padding: const EdgeInsets.all(kSP5x),
                      child: Icon(
                        isSave ? Icons.bookmark : Icons.bookmark_border,
                        color:
                            isSave ? kAppYellowButtonColor : kAppPrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: kSP5x),
                  GestureDetector(
                    onTap: onTapPlay,
                    child: const Padding(
                      padding: EdgeInsets.all(kSP5x),
                      child: Icon(Icons.play_arrow),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSP40x),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kSP40x),
              child: EasyTextWidget(
                text: description,
                maxLines: 6,
                textColor: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
