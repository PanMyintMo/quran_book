import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomePageDrawerView(),
      body: SafeArea(
        child: StreamBuilder<List<dynamic>>(
          stream: Rx.combineLatest2(
            _firebaseModel.watchAllBooks(),
            _firebaseModel.watchAllBanners(),
            (List<BookVO> books, List<BannerVO> banners) => [books, banners],
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final books = snapshot.data![0] as List<BookVO>;
            final banners = snapshot.data![1] as List<BannerVO>;

            return Padding(
              padding: const EdgeInsets.all(kSP10x),
              child: Column(
                children: [
                  /// 🔹 Custom App Bar (menu icon)
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
                        if (banners.isNotEmpty)
                          SizedBox(
                            height: kHomePageBannerViewHeight,
                            child: PageView.builder(
                              itemCount: banners.length,
                              itemBuilder: (_, index) {
                                final banner = banners[index];
                                return CacheNetworkImageWidget(
                                  radius: kSP10x,
                                  imageUrl: banner.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: kSP20x),
                        if (books.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: EasyTextWidget(
                              text: 'Books',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: kSP10x),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: Scrollbar(
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: ListView.builder(
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
                                      width: 150,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: CacheNetworkImageWidget(
                                              radius: kSP10x,
                                              imageUrl: book.image,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          EasyTextWidget(
                                            text: book.name,
                                            maxLines: 2,
                                          ),
                                        ],
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
