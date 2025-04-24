import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/pages/admin/category/admin_add_category_page.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/dialog/prompt_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminCategoryHomePage extends StatefulWidget {
  const AdminCategoryHomePage({super.key});

  @override
  State<AdminCategoryHomePage> createState() => _AdminCategoryHomePageState();
}

class _AdminCategoryHomePageState extends State<AdminCategoryHomePage> {
  final FirebaseModel _firebaseModel = FirebaseModel();

  Future<void> _deleteCategory(CategoryVO category) async {
    try {
      context.showLoadingDialog();
      await _firebaseModel.deleteCategory(category.id, category.image);
      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar("Category deleted successfully");
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed to delete category: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Category Management')),
      body: StreamBuilder<List<CategoryVO>>(
        stream: _firebaseModel.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Dismissible(
                key: Key(category.id),
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
                    await context.navigateToNextPage(AdminAddCategoryPage(
                      imageUrl: category.image,
                      name: category.name,
                      subtitle: category.subtitle,
                    ));
                    return false;
                  } else {
                    return await showDialog(
                      context: context,
                      builder: (context) => PromptDialogWidget.twoBtnDialog(
                        title: 'Confirm Deletion',
                        content: 'Are you sure you want to delete this category?',
                        positiveButtonText: 'Delete',
                        onPositivePressed: () async {
                          Navigator.pop(context);
                          await _deleteCategory(category);
                        },
                        negativeButtonText: 'Cancel',
                        onNegativePressed: () => Navigator.pop(context),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CacheNetworkImageWidget(
                      width: 50,
                      imageUrl: category.image,
                    ),
                    title: EasyTextWidget(text: category.name),
                    subtitle: EasyTextWidget(text: category.subtitle),
                    trailing: EasyTextWidget(text: '${category.totalBookCount} Books'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.navigateToNextPage(const AdminAddCategoryPage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
