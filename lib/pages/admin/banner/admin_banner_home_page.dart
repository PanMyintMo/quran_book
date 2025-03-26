import 'package:flutter/material.dart';
import 'package:quran_book/pages/admin/banner/admin_add_banner_page.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/dialog/prompt_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminBannerManagementPage extends StatelessWidget {
  const AdminBannerManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Banner Management')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(index.toString()),
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
                context.navigateToNextPage(
                  const AdminAddBannerPage(
                    imageUrl: 'https://via.placeholder.com/100',
                  ),
                );
                return false;
              } else {
                return await showDialog(
                  context: context,
                  builder: (context) => PromptDialogWidget.twoBtnDialog(
                    title: 'Confirm Deletion',
                    content: 'Are you sure you want to delete this banner?',
                    positiveButtonText: 'Delete',
                    onPositivePressed: () {},
                    negativeButtonText: 'Cancel',
                    onNegativePressed: () {},
                  ),
                );
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CacheNetworkImageWidget(
                width: double.infinity,
                height: 150,
                imageUrl: 'https://via.placeholder.com/100',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.navigateToNextPage(const AdminAddBannerPage()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
