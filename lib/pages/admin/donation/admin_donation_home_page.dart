import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/donation_vo.dart';
import 'package:quran_book/pages/admin/donation/admin_donation_add_page.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/dialog/prompt_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminDonationSetupPage extends StatefulWidget {
  const AdminDonationSetupPage({super.key});

  @override
  State<AdminDonationSetupPage> createState() => _AdminDonationSetupPageState();
}

class _AdminDonationSetupPageState extends State<AdminDonationSetupPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  List<DonationVO> _donations = [];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    final donations = await _firebaseModel.getAllDonations();
    setState(() {
      _donations = donations;
    });
  }

  Future<void> _deleteDonation(DonationVO donation) async {
    await _firebaseModel.deleteDonation(donation.id, donation.image);
    await _loadDonations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Donation Setup')),
      body: _donations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _donations.length,
              itemBuilder: (context, index) {
                final donation = _donations[index];
                return Dismissible(
                  key: Key(donation.id),
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
                        AdminAddDonationPage(
                          name: donation.name,
                          accountNumber: donation.accNumber,
                          imageUrl: donation.image,
                        ),
                      );
                      return false;
                    } else {
                      return await showDialog(
                        context: context,
                        builder: (context) => PromptDialogWidget.twoBtnDialog(
                          title: 'Confirm Deletion',
                          content: 'Are you sure you want to delete this donation setup?',
                          positiveButtonText: 'Delete',
                          onPositivePressed: () async {
                            Navigator.pop(context);
                            await _deleteDonation(donation);
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
                        imageUrl: donation.image,
                      ),
                      title: EasyTextWidget(text: donation.name),
                      subtitle: EasyTextWidget(text: donation.accNumber),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.navigateToNextPage(const AdminAddDonationPage());
          await _loadDonations();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
