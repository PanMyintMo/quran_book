import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  List<BookVO> _books = [];
  List<BannerVO> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final books = await _firebaseModel.getAllBooks();
      final banners = await _firebaseModel.getAllBanners();
      if (mounted) {
        setState(() {
          _books = books;
          _banners = banners;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: \$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(kSP10x),
              children: [
                if (_banners.isNotEmpty)
                  SizedBox(
                    height: kHomePageBannerViewHeight,
                    child: PageView.builder(
                      itemCount: _banners.length,
                      itemBuilder: (_, index) {
                        final banner = _banners[index];
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
                if (_books.isNotEmpty)
                  SizedBox(
                    height: kHomePageBookViewHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _books.length,
                      separatorBuilder: (_, __) => const SizedBox(width: kSP10x),
                      itemBuilder: (_, index) {
                        final book = _books[index];
                        return GestureDetector(
                          onTap: () => context.navigateToNextPage(BookOverviewPage(isPlay: false, book: book)),
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
            ),
    );
  }
}
