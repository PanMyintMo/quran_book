import 'package:flutter/material.dart';
import 'package:quran_book/pages/admin/category/admin_add_category_page.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/dialog/prompt_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminCategoryHomePage extends StatelessWidget {
  const AdminCategoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const EasyTextWidget(text: 'Category Management'),
      ),
      body: ListView.builder(
        itemCount: 10,
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
                  AdminAddCategoryPage(
                    imageUrl: 'https://t4.ftcdn.net/jpg/00/81/38/59/360_F_81385977_wNaDMtgrIj5uU5QEQLcC9UNzkJc57xbu.jpg',
                    name: 'Category Title',
                    subtitle: 'Category Subtitle',
                  ),
                );
                return false;
              } else {
                return await showDialog(
                    context: context,
                    builder: (context) {
                      return PromptDialogWidget.twoBtnDialog(
                          title: 'Confirm Deletion',
                          content: 'Are you sure you want to delete this category?',
                          positiveButtonText: 'Delete',
                          onPositivePressed: () {},
                          negativeButtonText: 'Cancel',
                          onNegativePressed: () {});
                    });
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CacheNetworkImageWidget(
                  width: 50,
                  imageUrl: 'https://t4.ftcdn.net/jpg/00/81/38/59/360_F_81385977_wNaDMtgrIj5uU5QEQLcC9UNzkJc57xbu.jpg',
                ),
                title: EasyTextWidget(
                  text: 'Category Title',
                ),
                subtitle: EasyTextWidget(
                  text: 'Category Subtitle',
                ),
                trailing: EasyTextWidget(
                  text: '12 Books',
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.navigateToNextPage(
            AdminAddCategoryPage(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
