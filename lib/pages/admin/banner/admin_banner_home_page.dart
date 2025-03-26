import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/pages/admin/banner/admin_add_banner_page.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/dialog/prompt_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminBannerManagementPage extends StatefulWidget {
  const AdminBannerManagementPage({super.key});

  @override
  State<AdminBannerManagementPage> createState() => _AdminBannerManagementPageState();
}

class _AdminBannerManagementPageState extends State<AdminBannerManagementPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  List<BannerVO> _banners = [];

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    final banners = await _firebaseModel.getAllBanners();
    setState(() {
      _banners = banners;
    });
  }

  Future<void> _deleteBanner(BannerVO banner) async {
    await _firebaseModel.deleteBanner(banner.id, banner.image);
    await _loadBanners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Banner Management')),
      body: _banners.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Dismissible(
                  key: Key(banner.id),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      context.navigateToNextPage(AdminAddBannerPage(imageUrl: banner.image));
                      return false;
                    } else {
                      return await showDialog(
                        context: context,
                        builder: (context) => PromptDialogWidget.twoBtnDialog(
                          title: 'Confirm Deletion',
                          content: 'Are you sure you want to delete this banner?',
                          positiveButtonText: 'Delete',
                          onPositivePressed: () async {
                            Navigator.pop(context);
                            await _deleteBanner(banner);
                          },
                          negativeButtonText: 'Cancel',
                          onNegativePressed: () => Navigator.pop(context),
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CacheNetworkImageWidget(
                      width: double.infinity,
                      height: 150,
                      imageUrl: banner.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.navigateToNextPage(const AdminAddBannerPage());
          await _loadBanners();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
