import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminReadingPage extends StatefulWidget {
  const AdminReadingPage({super.key});

  @override
  State<AdminReadingPage> createState() => _AdminReadingPageState();
}

class _AdminReadingPageState extends State<AdminReadingPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  int _totalReads = 0;
  final List<UserVO> _readers = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final books = await _firebaseModel.getAllBooks();
    final allUsers = await _firebaseModel.getAllUsers();

    final readerIds = <String>{};

    for (final book in books) {
      readerIds.addAll(book.readBy.map((user) => user.id));
    }

    final readers = allUsers.where((user) => readerIds.contains(user.id)).toList();

    setState(() {
      _totalReads = readerIds.length;
      _readers.clear();
      _readers.addAll(readers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Reading Analytics')),
      body: Padding(
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
                      text: '$_totalReads times',
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
              child: _readers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _readers.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = _readers[index];
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
      ),
    );
  }
}
