import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: EasyTextWidget(
            text: kDonationText.tr(),
            fontWeight: FontWeight.w600,
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(kSP20x),
          itemCount: 5,
          itemBuilder: (_, index) => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kSP10x),
                border: Border.all(
                  color: kBlackColor,
                ),
              ),
              child: ListTile(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: '09254138115'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: EasyTextWidget(
                      text: kCopiedText.tr(),
                    )),
                  );
                },
                contentPadding: const EdgeInsets.all(0),
                leading: CacheNetworkImageWidget(
                  width: kDonatePageImageSize,
                  height: kDonatePageImageSize,
                  imageUrl: 'https://mpics.mgronline.com/pics/Images/564000005890201.JPEG',
                ),
                title: EasyTextWidget(
                  text: 'Thiha Thant Sin',
                  fontSize: kFontSize16x,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EasyTextWidget(
                      text: '09254138115',
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(
                      height: kSP20x,
                    ),
                    EasyTextWidget(
                      text: kClickToCopyText.tr(),
                      fontSize: kFontSize12x,
                    ),
                  ],
                ),
                isThreeLine: true,
              )),
          separatorBuilder: (_, index) => const SizedBox(
            height: kSP20x,
          ),
        ));
  }
}
