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
    if (!mounted) return;
    context.showLoadingDialog();
    try {
      await _firebaseModel.deleteBook(id);
      if (mounted) context.showSuccessSnackBar("Book deleted successfully");
    } catch (e) {
      if (mounted) context.showErrorSnackBar("Failed to delete book: $e");
    } finally {
      if (mounted) context.hideLoadingDialog();
    }
  }

  Future<void> _openPdf(String url) async {
    if (url.isEmpty) {
      if (mounted) context.showErrorSnackBar("PDF URL is not available.");
      return;
    }
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        context.showErrorSnackBar("Could not open PDF link.");
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar("Error opening PDF: $e");
    }
  }

  Future<void> _openAudio(String url) async {
    if (url.isEmpty) {
      if (mounted) context.showErrorSnackBar("Audio URL is not available.");
      return;
    }
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        context.showErrorSnackBar("Could not open audio link.");
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar("Error opening audio: $e");
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                EasyTextWidget(
                                    text: book.name,
                                    fontWeight: FontWeight.bold),
                                const SizedBox(height: 4),
                                EasyTextWidget(text: 'By ${book.author}'),
                                const SizedBox(height: 4),
                                EasyTextWidget(
                                    text: 'Category: ${book.category.name}'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                tooltip: 'Edit post',
                                onPressed: () async {
                                  await context.navigateToNextPage(
                                    AdminAddPostPage(
                                      id: book.id,
                                      name: book.name,
                                      author: book.author,
                                      overview: book.overview,
                                      imageUrl: book.image,
                                      pdfUrl: book.pdf.url,
                                      pdfName: book.pdf.name,
                                      audioUrl: book.audio?.url,
                                      audioName: book.audio?.name,
                                      category: book.category,
                                      userIDOfBookMark: book.userIDOfBookMark,
                                      createAt: book.createAt,
                                      updateAt: book.updateAt,
                                      bookType: book.bookType,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, color: Colors.blue),
                              ),
                              IconButton(
                                tooltip: 'Delete post',
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        PromptDialogWidget.twoBtnDialog(
                                      title: 'Confirm Deletion',
                                      content:
                                          'Are you sure you want to delete this post?',
                                      positiveButtonText: 'Delete',
                                      onPositivePressed: () async {
                                        Navigator.pop(context);
                                        await _deleteBook(book.id);
                                      },
                                      negativeButtonText: 'Cancel',
                                      onNegativePressed: () =>
                                          Navigator.pop(context),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
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
