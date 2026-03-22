import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/pages/main_page/book_types_see_all_page.dart';
import 'package:quran_book/pages/main_page/category_see_all_page.dart';
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
  final ScrollController _booksScrollController = ScrollController();

  @override
  void dispose() {
    _booksScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomePageDrawerView(),
      body: SafeArea(
        child: StreamBuilder<List<dynamic>>(
          stream: Rx.combineLatest2(
            _firebaseModel.watchAllBooks(),
            _firebaseModel.watchAllCategories(),
            (List<BookVO> books, List<CategoryVO> categories) =>
                [books, categories],
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final books = snapshot.data![0] as List<BookVO>;
            final categories = snapshot.data![1] as List<CategoryVO>;

            return Padding(
              padding: const EdgeInsets.all(kSP10x),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      return HomePageAppbarView(
                        onTapLeadingIcon: () =>
                            Scaffold.of(context).openDrawer(),
                      );
                    },
                  ),
                  const SizedBox(height: kSP20x),
                  Expanded(
                    child: ListView(
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
                              childAspectRatio: 2.6,
                            ),
                            itemBuilder: (_, index) {
                              final category = categories[index];
                              return _BookTypeCard(category: category);
                            },
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
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.28,
                            child: Scrollbar(
                              controller: _booksScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: ListView.builder(
                                controller: _booksScrollController,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(bottom: 8),
                                itemCount: books.length,
                                itemBuilder: (_, index) {
                                  final book = books[index];
                                  return GestureDetector(
                                    onTap: () => context.navigateToNextPage(
                                      BookOverviewPage(
                                          isPlay: false, book: book),
                                    ),
                                    child: Container(
                                      width: 110,
                                      margin:
                                          const EdgeInsets.only(right: kSP10x),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            kSP10x),
                                        child: CacheNetworkImageWidget(
                                          radius: kSP10x,
                                          imageUrl: book.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(kSP10x),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: kSP10x, vertical: kSP5x),
      child: Row(
        children: [
          CacheNetworkImageWidget(
            radius: kSP5x,
            imageUrl: category.image,
            width: 40,
            height: 40,
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
