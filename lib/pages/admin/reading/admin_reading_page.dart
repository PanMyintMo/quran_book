import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:rxdart/rxdart.dart';

class AdminReadingPage extends StatefulWidget {
  const AdminReadingPage({super.key});

  @override
  State<AdminReadingPage> createState() => _AdminReadingPageState();
}

class _AdminReadingPageState extends State<AdminReadingPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Reading Analytics')),
      body: StreamBuilder<List<dynamic>>(
        stream: Rx.combineLatest2(
          _firebaseModel.watchAllBooks(),
          _firebaseModel.watchAllUsers(),
          (List<BookVO> books, List<UserVO> users) {
            final readerIds = <String>{};
            for (final book in books) {
              readerIds.addAll(book.readBy.map((user) => user.id));
            }
            final readers = users.where((user) => readerIds.contains(user.id)).toList();
            return [readerIds.length, readers];
          },
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }

          final totalReads = snapshot.data![0] as int;
          final readers = snapshot.data![1] as List<UserVO>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EasyTextWidget(
                          text: '📊 Total Reads',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 8),
                        EasyTextWidget(
                          text: '$totalReads times',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          textColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const EasyTextWidget(
                  text: '👥 Readers List',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: readers.isEmpty
                      ? const Center(child: Text("No readers found yet."))
                      : ListView.separated(
                          itemCount: readers.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final user = readers[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: EasyTextWidget(text: user.name),
                              subtitle: EasyTextWidget(text: user.email),
                            );
                          },
                        ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
