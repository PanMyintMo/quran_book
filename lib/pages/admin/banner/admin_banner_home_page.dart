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

  Future<void> _deleteBanner(BannerVO banner) async {
    try {
      context.showLoadingDialog();
      await _firebaseModel.deleteBanner(banner.id, banner.image);
      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar("Banner deleted successfully");
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed to delete banner: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Banner Management')),
      body: StreamBuilder<List<BannerVO>>(
        stream: _firebaseModel.watchAllBanners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final banners = snapshot.data ?? [];

          if (banners.isEmpty) {
            return const Center(child: Text("No banners found"));
          }

          return ListView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
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
                    await context.navigateToNextPage(AdminAddBannerPage(imageUrl: banner.image));
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.navigateToNextPage(const AdminAddBannerPage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
