import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/data/vos/book_vo.dart';
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
      body: StreamBuilder<List<dynamic>>(
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

          return ListView(
            padding: const EdgeInsets.all(kSP10x),
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
              const EasyTextWidget(
                text: 'New Books',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: kSP10x),
              if (books.isNotEmpty)
                SizedBox(
                  height: kHomePageBookViewHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(width: kSP10x),
                    itemBuilder: (_, index) {
                      final book = books[index];
                      return GestureDetector(
                        onTap: () => context.navigateToNextPage(
                          BookOverviewPage(isPlay: false, book: book),
                        ),
                        child: CacheNetworkImageWidget(
                          radius: kSP10x,
                          imageUrl: book.image,
                          width: kHomePageBookImageWidth,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
