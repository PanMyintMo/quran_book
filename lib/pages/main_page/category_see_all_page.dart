import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class BookSeeAllPage extends StatefulWidget {
  const BookSeeAllPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<BookSeeAllPage> createState() => _BookSeeAllPageState();
}

class _BookSeeAllPageState extends State<BookSeeAllPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  List<BookVO> _bookList = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await _firebaseModel.getAllBooks();
    setState(() {
      _bookList = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EasyTextWidget(
          text: widget.title,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(kSP20x),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: kSP20x,
          mainAxisSpacing: kSP20x,
        ),
        itemCount: _bookList.length,
        itemBuilder: (_, index) {
          final book = _bookList[index];
          return GestureDetector(
            onTap: () {
              context.navigateToNextPage(BookOverviewPage(isPlay: false, book: book));
            },
            child: CacheNetworkImageWidget(
              radius: kSP10x,
              imageUrl: book.image,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
