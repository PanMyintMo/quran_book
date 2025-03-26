import 'package:flutter/material.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminReadingPage extends StatelessWidget {
  const AdminReadingPage({super.key});

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
                      text: '3 times',
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
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: EasyTextWidget(text: "Test User"),
                    subtitle: EasyTextWidget(text: "thantsin7755@gmail.com"),
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
