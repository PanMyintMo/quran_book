import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/donation_vo.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final FirebaseModel _firebaseModel = FirebaseModel();

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
      body: StreamBuilder<List<DonationVO>>(
        stream: _firebaseModel.watchAllDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data ?? [];

          if (donations.isEmpty) {
            return Center(child: EasyTextWidget(text: 'No donations available yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(kSP20x),
            itemCount: donations.length,
            itemBuilder: (_, index) {
              final donation = donations[index];
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kSP10x),
                  border: Border.all(color: adaptiveBorderColor(context)),
                ),
                child: ListTile(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: donation.accNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: EasyTextWidget(text: kCopiedText.tr()),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.all(0),
                  leading: CacheNetworkImageWidget(
                    width: kDonatePageImageSize,
                    height: kDonatePageImageSize,
                    imageUrl: donation.image,
                  ),
                  title: EasyTextWidget(
                    text: donation.name,
                    fontSize: kFontSize16x,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EasyTextWidget(
                        text: donation.accNumber,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: kSP20x),
                      EasyTextWidget(
                        text: kClickToCopyText.tr(),
                        fontSize: kFontSize12x,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: kSP20x),
          );
        },
      ),
    );
  }
}
