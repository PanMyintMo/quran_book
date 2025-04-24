import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/admin/post/admin_add_post_page.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/dialog/prompt_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPostPage extends StatefulWidget {
  const AdminPostPage({super.key});

  @override
  State<AdminPostPage> createState() => _AdminPostPageState();
}

class _AdminPostPageState extends State<AdminPostPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();

  Future<void> _deleteBook(String id) async {
    try {
      context.showLoadingDialog();
      await _firebaseModel.deleteBook(id);
      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar("Book deleted successfully");
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed to delete book: $e");
      }
    }
  }

  void _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      context.showErrorSnackBar("Could not open PDF link.");
    }
  }

  void _openAudio(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      context.showErrorSnackBar("Could not open audio link.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Management')),
      body: StreamBuilder<List<BookVO>>(
        stream: _firebaseModel.watchAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(child: Text("No books available"));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Dismissible(
                key: Key(book.id),
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
                    await context.navigateToNextPage(
                      AdminAddPostPage(
                        name: book.name,
                        author: book.author,
                        overview: book.overview,
                        imageUrl: book.image,
                        pdfName: book.pdf.name,
                        audioName: book.audio?.name,
                        category: book.category,
                        userIDOfBookMark: book.userIDOfBookMark,
                      ),
                    );
                    return false;
                  } else {
                    return await showDialog(
                      context: context,
                      builder: (context) => PromptDialogWidget.twoBtnDialog(
                        title: 'Confirm Deletion',
                        content: 'Are you sure you want to delete this post?',
                        positiveButtonText: 'Delete',
                        onPositivePressed: () async {
                          Navigator.pop(context);
                          await _deleteBook(book.id);
                        },
                        negativeButtonText: 'Cancel',
                        onNegativePressed: () => Navigator.pop(context),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CacheNetworkImageWidget(
                              width: 60,
                              height: 60,
                              imageUrl: book.image,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  EasyTextWidget(text: book.name, fontWeight: FontWeight.bold),
                                  const SizedBox(height: 4),
                                  EasyTextWidget(text: 'By ${book.author}'),
                                  const SizedBox(height: 4),
                                  EasyTextWidget(text: 'Category: ${book.category.name}'),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        EasyTextWidget(text: 'Overview: ${book.overview}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => _openPdf(book.pdf.url),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Open PDF'),
                            ),
                            const SizedBox(width: 8),
                            if (book.audio != null)
                              TextButton.icon(
                                onPressed: () => _openAudio(book.audio!.url),
                                icon: const Icon(Icons.audiotrack),
                                label: const Text('Play Audio'),
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.navigateToNextPage(const AdminAddPostPage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
