import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/pages/main_page/book_types_see_all_page.dart';
import 'package:quran_book/pages/main_page/category_see_all_page.dart';
import 'package:quran_book/pages/main_page/search_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomePageDrawerView(),
      body: SafeArea(
        child: StreamBuilder<List<dynamic>>(
          stream: Rx.combineLatest3(
            _firebaseModel.watchAllBooks(),
            _firebaseModel.watchAllCategories(),
            _firebaseModel.watchAllBanners(),
            (List<BookVO> books, List<CategoryVO> categories,
                    List<BannerVO> banners) =>
                [books, categories, banners],
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final books = snapshot.data![0] as List<BookVO>;
            final categories = snapshot.data![1] as List<CategoryVO>;
            final banners = snapshot.data![2] as List<BannerVO>;

            return Column(
              children: [
                // ── AppBar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSP5x),
                  child: Builder(
                    builder: (context) => HomePageAppbarView(
                      onTapLeadingIcon: () =>
                          Scaffold.of(context).openDrawer(),
                      onTapSearch: () =>
                          context.navigateToNextPage(const SearchPage()),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    children: [
                      // ── Banner (full width, no horizontal padding) ──
                      if (banners.isNotEmpty) ...[
                        SizedBox(
                          height: kHomePageBannerViewHeight,
                          child: PageView.builder(
                            controller: _bannerController,
                            itemCount: banners.length,
                            onPageChanged: (i) =>
                                setState(() => _currentBannerIndex = i),
                            itemBuilder: (_, index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: kSP10x),
                              child: CacheNetworkImageWidget(
                                radius: kSP10x,
                                imageUrl: banners[index].image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: kSP10x),
                        // Dot indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(banners.length, (i) {
                            final active = i == _currentBannerIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active
                                    ? kAppPrimaryColor
                                    : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: kSP10x),
                      ],

                      // ── Padded content ──
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: kSP10x),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Book Types ──
                            if (categories.isNotEmpty) ...[
                              _SectionHeader(
                                title: 'Book Types',
                                onTap: () => context.navigateToNextPage(
                                  const BookTypesSeeAllPage(),
                                ),
                              ),
                              const SizedBox(height: kSP10x),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: categories.length > 4
                                    ? 4
                                    : categories.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: kSP10x,
                                  mainAxisSpacing: kSP10x,
                                  childAspectRatio: 8/2,
                                ),
                                itemBuilder: (_, index) => _BookTypeCard(
                                    category: categories[index]),
                              ),
                              const SizedBox(height: kSP20x),
                            ],

                            // ── New Books ──
                            if (books.isNotEmpty) ...[
                              _SectionHeader(
                                title: 'New books',
                                onTap: () => context.navigateToNextPage(
                                  const BookSeeAllPage(title: 'New books'),
                                ),
                              ),
                              const SizedBox(height: kSP10x),
                              _BooksHorizontalList(
                                books: books,
                                onTap: (book) => context.navigateToNextPage(
                                  BookOverviewPage(isPlay: false, book: book),
                                ),
                              ),
                              const SizedBox(height: kSP20x),
                            ],

                            // ── Popular Books ──
                            if (books.isNotEmpty) ...[
                              _SectionHeader(
                                title: 'Popular books',
                                onTap: () => context.navigateToNextPage(
                                  const BookSeeAllPage(
                                      title: 'Popular books'),
                                ),
                              ),
                              const SizedBox(height: kSP10x),
                              _BooksHorizontalList(
                                books: books,
                                onTap: (book) => context.navigateToNextPage(
                                  BookOverviewPage(isPlay: false, book: book),
                                ),
                              ),
                              const SizedBox(height: kSP20x),
                            ],

                            // ── Premium Books (no arrow per Figma) ──
                            if (books.isNotEmpty) ...[
                              EasyTextWidget(
                                text: 'Premium books',
                                fontWeight: FontWeight.w600,
                                fontSize: kFontSize18x,
                              ),
                              const SizedBox(height: kSP10x),
                              _BooksHorizontalList(
                                books: books,
                                onTap: (book) => context.navigateToNextPage(
                                  BookOverviewPage(isPlay: false, book: book),
                                ),
                              ),
                              const SizedBox(height: kSP20x),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BooksHorizontalList extends StatelessWidget {
  const _BooksHorizontalList({required this.books, required this.onTap});

  final List<BookVO> books;
  final void Function(BookVO) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 114,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: kSP10x),
        itemBuilder: (_, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => onTap(book),
            child: CacheNetworkImageWidget(
              radius: kSP5x,
              imageUrl: book.image,
              width: 82,
              height: 114,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        EasyTextWidget(
          text: title,
          fontWeight: FontWeight.w600,
          fontSize: kFontSize18x,
        ),
        GestureDetector(
          onTap: onTap,
          child: const Icon(Icons.arrow_forward, size: 20),
        ),
      ],
    );
  }
}

class _BookTypeCard extends StatelessWidget {
  const _BookTypeCard({required this.category});

  final CategoryVO category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBoxColor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: kSP10x),
      child: Row(
        children: [
          CacheNetworkImageWidget(
            radius: kSP5x,
            imageUrl: category.image,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: kSP10x),
          Expanded(
            child: EasyTextWidget(
              text: category.name,
              maxLines: 2,
              fontSize: kFontSize12x,
            ),
          ),
        ],
      ),
    );
  }
}
