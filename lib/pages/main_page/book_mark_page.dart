import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/pages/main_page/language_page.dart';
import 'package:quran_book/pages/main_page/setting_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/random_color_utils.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:timeago/timeago.dart' as time_ago;

class BookMarkPage extends StatefulWidget {
  const BookMarkPage({super.key});

  @override
  State<BookMarkPage> createState() => _BookMarkPageState();
}

class _BookMarkPageState extends State<BookMarkPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final FirebaseModel _firebaseModel = FirebaseModel();
  final _auth = FirebaseAuth.instance;
  List<BookVO> _bookmarkedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedBooks();
  }

  Future<void> _loadBookmarkedBooks() async {
    try {
      setState(() => _isLoading = true);
      final books = await _firebaseModel.getAllBooks();
      final userId = _auth.currentUser?.uid;
      if (mounted && userId != null) {
        final bookmarks = books.where((book) => book.userIDOfBookMark.contains(userId)).toList();
        setState(() {
          _bookmarkedBooks = bookmarks;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar("Failed to load bookmarks: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: const _HomePageDrawerView(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kSP10x),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return _HomePageAppbarView(
                    onTapLeadingIcon: () => Scaffold.of(context).openDrawer(),
                  );
                }),
                const SizedBox(height: kSP20x),
                EasyTextWidget(
                  text: kBookmarkText.tr(),
                  fontWeight: FontWeight.w600,
                  fontSize: kFontSize16x,
                ),
                const SizedBox(height: kSP20x),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _bookmarkedBooks.isEmpty
                        ? const Center(child: Text("No bookmarked books yet."))
                        : Column(
                            children: _bookmarkedBooks
                                .map((book) => GestureDetector(
                                      onTap: () {
                                        context.navigateToNextPage(BookOverviewPage(isPlay: false, book: book));
                                      },
                                      child: _BookMarkItemView(
                                        title: book.name,
                                        subtitle: book.overview,
                                        createdAt: book.createAt,
                                      ),
                                    ))
                                .toList(),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookMarkItemView extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime createdAt;

  const _BookMarkItemView({
    required this.title,
    required this.subtitle,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSP10x),
      margin: const EdgeInsets.only(bottom: kSP20x),
      decoration: BoxDecoration(
        border: Border.all(color: kBlackColor),
        borderRadius: BorderRadius.circular(kSP10x),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.bookmark, color: RandomColorUtils.getRandomColor()),
          const SizedBox(width: kSP20x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EasyTextWidget(
                  text: title,
                  fontWeight: FontWeight.w600,
                  fontSize: kFontSize16x,
                ),
                EasyTextWidget(
                  text: subtitle,
                  fontWeight: FontWeight.w600,
                  fontSize: kFontSize12x,
                ),
                const SizedBox(height: kSP20x),
                EasyTextWidget(
                  text: time_ago.format(createdAt),
                  fontWeight: FontWeight.w600,
                  fontSize: kFontSize12x,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePageDrawerView extends StatelessWidget {
  const _HomePageDrawerView();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetImageUtils.kAppIcon,
                  height: kHomePageDrawerAppIconHeight,
                ),
                const SizedBox(height: kSP10x),
                EasyTextWidget(
                  text: kDrawerWelcomeText.tr(),
                  fontSize: kFontSize18x,
                  fontWeight: FontWeight.bold,
                ),
                const EasyTextWidget(text: 'v 1.0.0'),
              ],
            ),
          ),
          _buildDrawerItem(context, icon: Icons.language, label: kDrawerLanguageText, onTap: () {
            context.navigateToNextPage(const LanguagePage());
          }),
          _buildDrawerItem(context, icon: Icons.notifications, label: kDrawerNotificationText, onTap: () {}),
          _buildDrawerItem(context, icon: Icons.rate_review, label: kDrawerWriteAnAppStoreReviewText, onTap: () {}),
          _buildDrawerItem(context, icon: Icons.share, label: kDrawerShareTheAppText, onTap: () {}),
          _buildDrawerItem(context, icon: Icons.settings, label: kDrawerSettingText, onTap: () {
            context.navigateToNextPage(const SettingPage());
          }),
          _buildDrawerItem(context, icon: Icons.brightness_6, label: kDrawerThemeText, onTap: () {
            context.navigateToNextPage(const SettingPage());
          }),
          _buildDrawerItem(context, icon: Icons.phone, label: kDrawerContactUsText, onTap: () {}),
          _buildDrawerItem(context, icon: Icons.help_outline, label: kDrawerHelpAndSupportText, onTap: () {}),
          _buildDrawerItem(context, icon: Icons.info_outline, label: kDrawerAboutUsText, onTap: () {}),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: EasyTextWidget(text: label),
      onTap: () {
        Scaffold.of(context).closeDrawer();
        onTap();
      },
    );
  }
}

class _HomePageAppbarView extends StatelessWidget {
  const _HomePageAppbarView({required this.onTapLeadingIcon});

  final VoidCallback onTapLeadingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.menu), onPressed: onTapLeadingIcon),
        Image.asset(
          AssetImageUtils.kAppIcon,
          width: kHomePageAppIconWidth,
          height: kHomePageAppIconHeight,
        ),
        const SizedBox(width: kSP40x),
      ],
    );
  }
}
