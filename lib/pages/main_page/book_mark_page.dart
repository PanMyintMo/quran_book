import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/help_support_page.dart';
import 'package:quran_book/pages/main_page/about_us_page.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/pages/main_page/language_page.dart';
import 'package:quran_book/pages/main_page/setting_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/get_package_info_utils.dart';
import 'package:quran_book/utils/random_color_utils.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:timeago/timeago.dart' as time_ago;

class BookMarkPage extends StatefulWidget {
  const BookMarkPage({super.key});

  @override
  State<BookMarkPage> createState() => _BookMarkPageState();
}

class _BookMarkPageState extends State<BookMarkPage>
    with RouteAware, WidgetsBindingObserver {
  final FirebaseModel _firebaseModel = FirebaseModel();
  String? _userId;
  List<BookVO>? _bookmarkedBooks;
  StreamSubscription<List<BookVO>>? _booksSubscription;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    WidgetsBinding.instance.addObserver(this);
    _subscribeToBooks();
  }

  void _subscribeToBooks() {
    _booksSubscription?.cancel();
    _booksSubscription = _firebaseModel.watchAllBooks().listen((allBooks) {
      if (!mounted || _userId == null) return;
      final bookmarked = allBooks
          .where((book) => book.userIDOfBookMark.contains(_userId))
          .toList();
      setState(() => _bookmarkedBooks = bookmarked);
    });
  }

  Future<void> _refreshBookmarks() async {
    if (_userId == null) return;
    try {
      final allBooks = await _firebaseModel.getAllBooks();
      if (!mounted) return;
      setState(() {
        _bookmarkedBooks = allBooks
            .where((book) => book.userIDOfBookMark.contains(_userId))
            .toList();
      });
    } catch (_) {
      // Keep current list on error
    }
  }

  @override
  void dispose() {
    _booksSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    BookMarkRouteObserver.instance.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      BookMarkRouteObserver.instance.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // User returned from BookOverviewPage — refresh list so unbookmarked items disappear
    setState(() {
      _userId = FirebaseAuth.instance.currentUser?.uid;
    });
    _refreshBookmarks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _userId = FirebaseAuth.instance.currentUser?.uid;
      });
      _refreshBookmarks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomePageDrawerView(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kSP10x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  return HomePageAppbarView(
                    onTapLeadingIcon: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
              const SizedBox(height: kSP20x),
              EasyTextWidget(
                text: kBookmarkText.tr(),
                fontWeight: FontWeight.w600,
                fontSize: kFontSize16x,
              ),
              const SizedBox(height: kSP20x),
              Expanded(
                child: _userId == null
                    ? const Center(child: Text("User not logged in"))
                    : _bookmarkedBooks == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _bookmarkedBooks!.isEmpty
                            ? const Center(
                                child: Text("No bookmarked books yet."),
                              )
                            : ListView.builder(
                                itemCount: _bookmarkedBooks!.length,
                                itemBuilder: (_, index) {
                                  final book = _bookmarkedBooks![index];
                                  return GestureDetector(
                                    onTap: () async {
                                      final unbookmarkedId = await context
                                          .navigateToNextPage(
                                        BookOverviewPage(
                                            isPlay: false, book: book),
                                      ) as String?;
                                      
                                      if (!mounted) return;
                                      // Remove unbookmarked book from list immediately
                                      if (unbookmarkedId != null &&
                                          _bookmarkedBooks != null) {
                                        setState(() {
                                          _bookmarkedBooks = _bookmarkedBooks!
                                              .where((b) => b.id != unbookmarkedId)
                                              .toList();
                                        });
                                      } else {
                                        _refreshBookmarks();
                                      }
                                    },
                                    child: _BookMarkItemView(
                                      title: book.name,
                                      subtitle: book.overview,
                                      createdAt: book.createAt,
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route observer so BookMarkPage knows when user returns from BookOverviewPage.
class BookMarkRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  BookMarkRouteObserver._();
  static final BookMarkRouteObserver instance = BookMarkRouteObserver._();
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

class HomePageDrawerView extends StatelessWidget {
  const HomePageDrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: SingleChildScrollView(
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
                    textColor: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black,
                  ),
                  FutureBuilder<String>(
                      future: GetPackageInfoUtils.getAppVersion(),
                      builder: (_, snapShot) {
                        if (snapShot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapShot.hasError) {
                          return Center(
                              child: EasyTextWidget(
                                  text: snapShot.error.toString()));
                        }
                        return EasyTextWidget(
                            text: "Version: ${snapShot.data.toString()}");
                      }),
                ],
              ),
            ),
          ),
          _buildDrawerItem(context,
              icon: Icons.language, label: kDrawerLanguageText.tr(), onTap: () {
            context.navigateToNextPage(const LanguagePage());
          }),
          _buildDrawerItem(context,
              icon: Icons.settings, label: kDrawerSettingText.tr(), onTap: () {
            context.navigateToNextPage(const SettingPage());
          }),
          _buildDrawerItem(context,
              icon: Icons.brightness_6,
              label: kDrawerThemeText.tr(), onTap: () {
            context.navigateToNextPage(const SettingPage());
          }),
          // _buildDrawerItem(context, icon: Icons.notifications, label: kDrawerNotificationText.tr(), onTap: () {
          //   _showComingSoonDialog(context);
          // }),
          _buildDrawerItem(context,
              icon: Icons.rate_review,
              label: kDrawerWriteAnAppStoreReviewText.tr(), onTap: () {
            _showComingSoonDialog(context);
          }),
          _buildDrawerItem(context,
              icon: Icons.share, label: kDrawerShareTheAppText.tr(), onTap: () {
            _showComingSoonDialog(context);
          }),
          _buildDrawerItem(context,
              icon: Icons.phone, label: kDrawerContactUsText.tr(), onTap: () {
            _showComingSoonDialog(context);
          }),
          _buildDrawerItem(context,
              icon: Icons.help_outline,
              label: kDrawerHelpAndSupportText.tr(), onTap: () {
            context.navigateToNextPage(HelpSupportPage());
          }),
          _buildDrawerItem(context,
              icon: Icons.info_outline,
              label: kDrawerAboutUsText.tr(), onTap: () {
            context.navigateToNextPage(AboutUsPage());

            // _showComingSoonDialog(context);
          }),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
            'This feature will available after uploading on PlayStore!'),
        actions: [
          TextButton(
            onPressed: () => context.navigateBack(),
            child: const Text('OK'),
          ),
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

class HomePageAppbarView extends StatelessWidget {
  const HomePageAppbarView({super.key, required this.onTapLeadingIcon});

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
