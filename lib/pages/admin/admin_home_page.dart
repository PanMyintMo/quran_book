import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/pages/admin/banner/admin_banner_home_page.dart';
import 'package:quran_book/pages/admin/category/admin_category_home_page.dart';
import 'package:quran_book/pages/admin/donation/admin_donation_home_page.dart';
import 'package:quran_book/pages/admin/post/admin_post_page.dart';
import 'package:quran_book/pages/admin/reading/admin_reading_page.dart';
import 'package:quran_book/pages/admin/user/admin_user_home_page.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int categoryCount = 0;
  int postCount = 0;
  int readingCount = 0;
  int userCount = 0;
  int bannerCount = 0;
  int donationCount = 0;

  final _firebaseModel = FirebaseModel();

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final categories = await _firebaseModel.getTotalCategoryCount();
    final posts = await _firebaseModel.getTotalBookCount();
    final readings = await _firebaseModel.getTotalReadingCount();
    final users = await _firebaseModel.getTotalUserCount();
    final banners = await _firebaseModel.getTotalBannerCount();
    final donations = await _firebaseModel.getTotalDonationCount();

    if (mounted) {
      setState(() {
        categoryCount = categories;
        postCount = posts;
        readingCount = readings;
        userCount = users;
        bannerCount = banners;
        donationCount = donations;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const EasyTextWidget(text: 'Dashboard Admin View'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // ensures pull-to-refresh works
          padding: const EdgeInsets.all(10),
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
                    count: '$categoryCount',
                    label: 'Categories',
                    iconPath: AssetImageUtils.kAdminCategoryIcon,
                    onTap: () => context.navigateToNextPage(const AdminCategoryHomePage()),
                  ),
                  _CardItemView(
                    count: '$postCount',
                    label: 'Posts',
                    iconPath: AssetImageUtils.kAdminPostIcon,
                    onTap: () => context.navigateToNextPage(const AdminPostPage()),
                  ),
                  _CardItemView(
                    count: '$readingCount',
                    label: 'Reading',
                    iconPath: AssetImageUtils.kAdminReadingIcon,
                    onTap: () => context.navigateToNextPage(const AdminReadingPage()),
                  ),
                  _CardItemView(
                    count: '$userCount',
                    label: 'Users',
                    iconPath: AssetImageUtils.kAdminUserIcon,
                    onTap: () => context.navigateToNextPage(const AdminUserManagementPage()),
                  ),
                  _CardItemView(
                    count: '$bannerCount',
                    label: 'Banners',
                    iconPath: AssetImageUtils.kAdminBannerIcon,
                    onTap: () => context.navigateToNextPage(const AdminBannerManagementPage()),
                  ),
                  _CardItemView(
                    count: '$donationCount',
                    label: 'Donation',
                    iconPath: AssetImageUtils.kAdminDonationIcon,
                    onTap: () => context.navigateToNextPage(const AdminDonationSetupPage()),
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
