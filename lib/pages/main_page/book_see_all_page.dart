import 'package:flutter/material.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class BookSeeAllPage extends StatelessWidget {
  const BookSeeAllPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EasyTextWidget(
          text: title,
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
        itemCount: 8,
        itemBuilder: (_, index) {
          return CacheNetworkImageWidget(
            radius: kSP10x,
            imageUrl:
                'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
