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
    if (!mounted) return;
    context.showLoadingDialog();
    try {
      await _firebaseModel.deleteBanner(banner.id, banner.image);
      if (mounted) context.showSuccessSnackBar("Banner deleted successfully");
    } catch (e) {
      if (mounted) context.showErrorSnackBar("Failed to delete banner: $e");
    } finally {
      if (mounted) context.hideLoadingDialog();
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    CacheNetworkImageWidget(
                      width: double.infinity,
                      height: 150,
                      imageUrl: banner.image,
                      fit: BoxFit.cover,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Edit banner',
                          onPressed: () async {
                            await context.navigateToNextPage(
                              AdminAddBannerPage(
                                id: banner.id,
                                imageUrl: banner.image,
                                createAt: banner.createAt,
                                updateAt: banner.updateAt,
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          tooltip: 'Delete banner',
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (context) =>
                                  PromptDialogWidget.twoBtnDialog(
                                title: 'Confirm Deletion',
                                content:
                                    'Are you sure you want to delete this banner?',
                                positiveButtonText: 'Delete',
                                onPositivePressed: () async {
                                  Navigator.pop(context);
                                  await _deleteBanner(banner);
                                },
                                negativeButtonText: 'Cancel',
                                onNegativePressed: () => Navigator.pop(context),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
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
