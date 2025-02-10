import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/date_time_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kSP10x),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (text) {},
                style: TextStyle(
                  color: kWhiteColor,
                ),
                decoration: InputDecoration(
                    fillColor: kAppPrimaryColor,
                    filled: true,
                    hintText: kSearchHintText,
                    hintStyle: TextStyle(
                      color: kWhiteColor,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: kWhiteColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kSP10x),
                    )),
              ),
              const SizedBox(
                height: kSP20x,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: 7,
                  separatorBuilder: (_, index) => const SizedBox(
                    height: kSP20x,
                  ),
                  itemBuilder: (_, index) => _SearchResultItemView(
                    title: 'စိတ်တောင်တန်း',
                    description: 'မွန်းကျပ်လေးလံနေတဲ့ ဘဝတစ်ခုကိ့ မွန်းကျပ်လေးလံနေတဲ့ ဘဝတစ်ခုကိ့ မွန်းကျပ်လေးလံနေတဲ့ ဘဝတစ်ခုကိ့ ',
                    index: index + 1,
                    onTapSave: () {},
                    updateAt: DateTime.now().getHoursAndMinutes,
                    isSelect: false,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultItemView extends StatelessWidget {
  const _SearchResultItemView({
    required this.title,
    required this.description,
    required this.index,
    required this.onTapSave,
    required this.updateAt,
    required this.isSelect,
  });

  final int index;
  final String title;
  final String description;
  final String updateAt;
  final Function onTapSave;
  final bool isSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSP10x),
      margin: const EdgeInsets.only(bottom: kSP40x),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSP10x),
        border: Border.all(
          color: kBlackColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: kSearchIconSize,
                height: kSearchIconSize,
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
                text: updateAt,
              ),
              const SizedBox(
                width: kSP10x,
              ),
              GestureDetector(
                onTap: () {
                  onTapSave();
                },
                child: Icon(
                  Icons.bookmark,
                  color: isSelect ? kAppYellowButtonColor : kAppPrimaryColor,
                ),
              )
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
                  text: description,
                  maxLines: 2,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
