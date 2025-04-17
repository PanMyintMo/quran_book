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
        title: const EasyTextWidget(text: 'Dashboard Admin View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EasyTextWidget(
                text: 'Activity',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 5 / 3,
                children: [
                  _CardItemView(
                    count: '30',
                    label: 'Categories',
                    iconPath: AssetImageUtils.kAdminCategoryIcon,
                    onTap: () {
                      context.navigateToNextPage(const AdminCategoryHomePage());
                    },
                  ),
                  _CardItemView(
                    count: '30',
                    label: 'Posts',
                    iconPath: AssetImageUtils.kAdminPostIcon,
                    onTap: () {
                      context.navigateToNextPage(const AdminPostPage());
                    },
                  ),
                  _CardItemView(
                    count: '30',
                    label: 'Reading',
                    iconPath: AssetImageUtils.kAdminReadingIcon,
                    onTap: () {
                      context.navigateToNextPage(const AdminReadingPage());
                    },
                  ),
                  _CardItemView(
                    count: '30',
                    label: 'Users',
                    iconPath: AssetImageUtils.kAdminUserIcon,
                    onTap: () {
                      context.navigateToNextPage(const AdminUserManagementPage());
                    },
                  ),
                  _CardItemView(
                    count: '30',
                    label: 'Banners',
                    iconPath: AssetImageUtils.kAdminBannerIcon,
                    onTap: () {
                      context.navigateToNextPage(const AdminBannerManagementPage());
                    },
                  ),
                  _CardItemView(
                    count: '30',
                    label: 'Donation',
                    iconPath: AssetImageUtils.kAdminDonationIcon,
                    onTap: () {
                      context.navigateToNextPage(const AdminDonationSetupPage());
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
  final String count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EasyTextWidget(
                      text: count,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 4),
                    EasyTextWidget(
                      text: label,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
