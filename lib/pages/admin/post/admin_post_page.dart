import 'package:flutter/material.dart';
import 'package:quran_book/pages/admin/post/admin_add_post_page.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/dialog/prompt_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPostPage extends StatelessWidget {
  const AdminPostPage({super.key});

  void _openPdf(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openAudio(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Management')),
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
                  const AdminAddPostPage(
                    name: 'Sample Book',
                    author: 'Author A',
                    overview: 'This is a sample overview.',
                    imageUrl: 'https://t4.ftcdn.net/jpg/00/81/38/59/360_F_81385977_wNaDMtgrIj5uU5QEQLcC9UNzkJc57xbu.jpg',
                    pdfName: 'https://example.com/sample.pdf',
                    audioName: 'https://example.com/sample.mp3',
                    category: 'Tafsir',
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
                    onPositivePressed: () {},
                    negativeButtonText: 'Cancel',
                    onNegativePressed: () {},
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
                          imageUrl: 'https://t4.ftcdn.net/jpg/00/81/38/59/360_F_81385977_wNaDMtgrIj5uU5QEQLcC9UNzkJc57xbu.jpg',
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EasyTextWidget(text: 'Sample Book', fontWeight: FontWeight.bold),
                              SizedBox(height: 4),
                              EasyTextWidget(text: 'By Author A'),
                              SizedBox(height: 4),
                              EasyTextWidget(text: 'Category: Tafsir'),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    const EasyTextWidget(text: 'Overview: This is a sample overview.'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _openPdf('https://example.com/sample.pdf'),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Open PDF'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _openAudio('https://example.com/sample.mp3'),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //context.navigateToNextPage(const AdminAddPostPage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
