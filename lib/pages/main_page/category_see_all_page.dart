import 'package:flutter/material.dart';
import 'package:quran_book/pages/main_page/book_list_from_category_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class CategorySeeAllPage extends StatelessWidget {
  const CategorySeeAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(kSP20x),
          itemCount: 10,
          itemBuilder: (_, index) {
            return _CategorySeeAllItemView(
              title: 'စိတ်တောင်တန်း',
              index: index + 1,
              suffixText: 'نِ الرَّحِيمِ',
              totalCourse: 7,
              onTap: () {
                context.navigateToNextPage(BookListFromCategoryPage());
              },
            );
          },
          separatorBuilder: (_, index) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: kSP10x,
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySeeAllItemView extends StatelessWidget {
  const _CategorySeeAllItemView({
    required this.index,
    required this.title,
    required this.suffixText,
    required this.totalCourse,
    required this.onTap,
  });

  final int index;
  final String title;
  final String suffixText;
  final int totalCourse;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: kSeeAllCategorySize,
                height: kSeeAllCategorySize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      AssetImageUtils.kSearchStartIcon,
                    ),
                  ),
                ),
                child: EasyTextWidget(
                  text: index.toString(),
                  textColor: kWhiteColor,
                  fontSize: kFontSize12x,
                ),
              ),
              const SizedBox(
                width: kSP10x,
              ),
              EasyTextWidget(
                text: title,
                fontWeight: FontWeight.w600,
                maxLines: 1,
              ),
              const Spacer(),
              EasyTextWidget(
                text: suffixText,
                textColor: kAppPrimaryColor,
                fontSize: kFontSize16x,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(
            height: kSP5x,
          ),
          Row(
            children: [
              const SizedBox(
                width: kSP30x,
              ),
              Flexible(
                child: EasyTextWidget(
                  text: 'Course - $totalCourse',
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
