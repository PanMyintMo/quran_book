import 'package:flutter/material.dart';
import 'package:quran_book/pages/admin/banner/admin_banner_home_page.dart';
import 'package:quran_book/pages/admin/category/admin_category_home_page.dart';
import 'package:quran_book/pages/admin/donation/admin_donation_home_page.dart';
import 'package:quran_book/pages/admin/post/admin_post_page.dart';
import 'package:quran_book/pages/admin/reading/admin_reading_page.dart';
import 'package:quran_book/pages/admin/user/admin_user_home_page.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: EasyTextWidget(text: 'Dashboard amdin view'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              EasyTextWidget(
                text: 'Activity',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              GridView.count(
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 5 / 3,
                children: [
                  _CardItemView(
                    count: EasyTextWidget(
                      text: '30',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    label: 'Categories',
                    iconPath: AssetImageUtils.kAdminCategoryIcon,
                    onTap: () {
                      context.navigateToNextPage(AdminCategoryHomePage());
                    },
                  ),
                  _CardItemView(
                    count: EasyTextWidget(
                      text: '30',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    label: 'Posts',
                    iconPath: AssetImageUtils.kAdminPostIcon,
                    onTap: () {
                      context.navigateToNextPage(AdminPostPage());
                    },
                  ),
                  _CardItemView(
                    count: EasyTextWidget(
                      text: '30',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    label: 'Reading',
                    iconPath: AssetImageUtils.kAdminReadingIcon,
                    onTap: () {
                      context.navigateBack(AdminReadingPage());
                    },
                  ),
                  _CardItemView(
                    count: EasyTextWidget(
                      text: '30',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    label: 'Users',
                    iconPath: AssetImageUtils.kAdminUserIcon,
                    onTap: () {
                      context.navigateToNextPage(AdminUserManagementPage());
                    },
                  ),
                  _CardItemView(
                    count: EasyTextWidget(
                      text: '30',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    label: 'Banners',
                    iconPath: AssetImageUtils.kAdminBannerIcon,
                    onTap: () {
                      context.navigateToNextPage(AdminBannerManagementPage());
                    },
                  ),
                  _CardItemView(
                    count: EasyTextWidget(
                      text: '30',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    label: 'Donation',
                    iconPath: AssetImageUtils.kAdminDonationIcon,
                    onTap: () {
                      context.navigateToNextPage(AdminDonationSetupPage());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardItemView extends StatelessWidget {
  const _CardItemView({
    required this.count,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final Widget count;
  final String label;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Image.asset(
                iconPath,
                width: 30,
                height: 30,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  count,
                  EasyTextWidget(
                    text: label,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
