import 'package:flutter/material.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const EasyTextWidget(text: 'User Management'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: EasyTextWidget(
                text: 'Test User',
                fontWeight: FontWeight.bold,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EasyTextWidget(text: 'thantsin7755@gmail.com'),
                  EasyTextWidget(
                    text: true ? 'Admin' : 'User',
                    textColor: false ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'toggle_admin') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Toggled admin for Test User")),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle_admin',
                    child: Text(true ? 'Revoke Admin' : 'Make Admin'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
