import 'package:flutter/material.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class BookListFromCategoryPage extends StatelessWidget {
  const BookListFromCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(kSP20x),
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
                itemBuilder: (_, index) => _BookListFromCategoryItemView(
                  index: index + 1,
                  title: 'إ ِنَّكَ لَمِنَ ٱلْمُرْسَلِينَ ِنَّكَ لَمِنَ ٱلْمُرْسَلِينَ',
                  translateBy: 'Dr. Mustafa Khattab',
                  isSave: false,
                  onTapPlay: () {
                    showDialog(
                      context: context,
                      builder: (_) => _NeedToRegisterDialogView(
                        title: kRegisterAlertTextForPlayText,
                      ),
                    );
                  },
                  onTapSave: () {
                    showDialog(
                      context: context,
                      builder: (_) => _NeedToRegisterDialogView(
                        title: kRegisterAlertTextForSaveText,
                      ),
                    );
                  },
                  description:
                      'မြန်မာစာစတင်ဖြစ်ပေါ်လာခြင်းသည် မြန်မာသည် ပျူနှင့်မွန်စာရေးနည်းကို စံတင်ပြီး (၁၂)ရာစုတွင် မြန်မာဘာသာ ပေါ်ထွန်းလာခဲ့ခြင်းဖြစ်သည်။ မြန်မာနိုင်ငံ စတင်တည်ထောင်စဉ်ကာလ အနော်ရထာမင်း၏ လက်ထက်တွင် သက္ကတဘာသာစာဖြင့် ရေးသောအုတ်ခွက်စာများ၊ ပါဠိစာများဖြင့်ရေးသော အုတ်ခွက်စာများကို အထောက်အထားပြုကာ မြန်မာ့တို့သည် မူလက ပါဠိနှင့် သက္ကတဘာသာတို့ကို ရင်းနှီးခဲ့ကြောင်း သိရသည်။ ',
                ),
                separatorBuilder: (_, index) => const SizedBox(
                  height: kSP40x,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedToRegisterDialogView extends StatelessWidget {
  const _NeedToRegisterDialogView({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kAppPrimaryColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                context.navigateBack();
              },
              child: const Icon(
                Icons.close,
                color: kWhiteColor,
              ),
            ),
          ),
          const SizedBox(
            height: kSP30x,
          ),
          EasyTextWidget(
            textAlign: TextAlign.center,
            text: title,
            fontSize: kFontSize16x,
            fontWeight: FontWeight.w600,
            textColor: kWhiteColor,
            maxLines: 2,
          ),
          const SizedBox(
            height: kSP20x,
          ),
          PrimaryButtonWidget(
            radius: kSP5x,
            width: kSeeAllCategoryRegisterNowButtonWidth,
            height: kSeeAllCategoryRegisterNowButtonHeight,
            backgroundColor: kAppYellowButtonColor,
            onPressed: () {
              context.navigateBack();
              context.navigateToNextPage(LoginPage());
            },
            buttonText: kRegisterNowText,
          ),
          const SizedBox(
            height: kSP30x,
          ),
        ],
      ),
    );
  }
}

class _BookListFromCategoryItemView extends StatelessWidget {
  const _BookListFromCategoryItemView({
    required this.index,
    required this.title,
    required this.translateBy,
    required this.onTapSave,
    required this.isSave,
    required this.onTapPlay,
    required this.description,
  });

  final int index;
  final String title;
  final String translateBy;
  final bool isSave;
  final Function onTapSave;
  final Function onTapPlay;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EasyTextWidget(
          text: index.toString(),
          fontSize: kFontSize18x,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(
          height: kSP10x,
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: kSP40x),
          child: EasyTextWidget(
            textAlign: TextAlign.center,
            text: title.toString(),
            textColor: kAppPrimaryColor,
            fontSize: kFontSize21x,
            fontWeight: FontWeight.w600,
            maxLines: 2,
          ),
        ),
        const SizedBox(
          height: kSP20x,
        ),
        Row(
          children: [
            EasyTextWidget(
              text: 'Translarion by $translateBy',
              fontSize: kFontSize12x,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                onTapSave();
              },
              child: isSave
                  ? const Icon(
                      Icons.bookmark,
                      color: kAppYellowButtonColor,
                    )
                  : const Icon(
                      Icons.bookmark_border,
                      color: kAppPrimaryColor,
                    ),
            ),
            const SizedBox(
              width: kSP10x,
            ),
            GestureDetector(
              onTap: () {
                onTapPlay();
              },
              child: const Icon(Icons.play_arrow),
            )
          ],
        ),
        const SizedBox(
          height: kSP40x,
        ),
        EasyTextWidget(
          text: description,
          maxLines: 6,
          textColor: Colors.black54,
        )
      ],
    );
  }
}
