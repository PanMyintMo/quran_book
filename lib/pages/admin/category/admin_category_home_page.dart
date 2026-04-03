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
    if (!mounted) return;
    context.showLoadingDialog();
    try {
      await _firebaseModel.deleteCategory(category.id, category.image);
      if (mounted) context.showSuccessSnackBar("Category deleted successfully");
    } catch (e) {
      if (mounted) context.showErrorSnackBar("Failed to delete category: $e");
    } finally {
      if (mounted) context.hideLoadingDialog();
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CacheNetworkImageWidget(
                    width: 50,
                    imageUrl: category.image,
                  ),
                  title: EasyTextWidget(text: category.name),
                  subtitle: EasyTextWidget(text: category.subtitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EasyTextWidget(text: '${category.totalBookCount} Books'),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Edit category',
                        onPressed: () async {
                          await context.navigateToNextPage(AdminAddCategoryPage(
                            id: category.id,
                            imageUrl: category.image,
                            name: category.name,
                            subtitle: category.subtitle,
                            totalBookCount: category.totalBookCount,
                            createAt: category.createAt,
                            updateAt: category.updateAt,
                          ));
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        tooltip: 'Delete category',
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            builder: (context) =>
                                PromptDialogWidget.twoBtnDialog(
                              title: 'Confirm Deletion',
                              content:
                                  'Are you sure you want to delete this category?',
                              positiveButtonText: 'Delete',
                              onPositivePressed: () async {
                                Navigator.pop(context);
                                await _deleteCategory(category);
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
