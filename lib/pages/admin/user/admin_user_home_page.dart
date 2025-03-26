import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  List<UserVO> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _firebaseModel.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _toggleAdmin(UserVO user) async {
    final updatedUser = user.copyWith(isAdmin: !user.isAdmin);
    await _firebaseModel.createUser(updatedUser);
    await _loadUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${updatedUser.name} is now ${updatedUser.isAdmin ? 'Admin' : 'User'}")),
    );
  }

  Future<void> _toggleDeleteStatus(UserVO user) async {
    final updatedUser = user.copyWith(isDeleteAccount: !user.isDeleteAccount);
    await _firebaseModel.createUser(updatedUser);
    await _loadUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${updatedUser.name} account is now ${updatedUser.isDeleteAccount ? 'Deleted' : 'Active'}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const EasyTextWidget(text: 'User Management'),
      ),
      body: _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: EasyTextWidget(
                      text: user.name,
                      fontWeight: FontWeight.bold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EasyTextWidget(text: user.email),
                        EasyTextWidget(
                          text: user.isAdmin ? 'Admin' : 'User',
                          textColor: user.isAdmin ? Colors.green : Colors.grey,
                        ),
                        EasyTextWidget(
                          text: user.isDeleteAccount ? 'Deleted' : 'Active',
                          textColor: user.isDeleteAccount ? Colors.red : Colors.blue,
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'toggle_admin') {
                          _toggleAdmin(user);
                        } else if (value == 'toggle_delete') {
                          _toggleDeleteStatus(user);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle_admin',
                          child: Text(user.isAdmin ? 'Revoke Admin' : 'Make Admin'),
                        ),
                        PopupMenuItem(
                          value: 'toggle_delete',
                          child: Text(user.isDeleteAccount ? 'Restore Account' : 'Delete Account'),
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
