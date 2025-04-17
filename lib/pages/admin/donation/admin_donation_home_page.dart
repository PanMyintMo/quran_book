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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    try {
      setState(() => _isLoading = true);
      final donations = await _firebaseModel.getAllDonations();
      if (mounted) {
        setState(() {
          _donations = donations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackBar("Failed to load donations: $e");
      }
    }
  }

  Future<void> _deleteDonation(DonationVO donation) async {
    try {
      context.showLoadingDialog();
      await _firebaseModel.deleteDonation(donation.id, donation.image);
      await _loadDonations();
      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar("Donation setup deleted successfully");
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed to delete donation: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: 'Donation Setup')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
              ? const Center(child: Text("No donation setup found"))
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
                          await context.navigateToNextPage(
                            AdminAddDonationPage(
                              name: donation.name,
                              accountNumber: donation.accNumber,
                              imageUrl: donation.image,
                            ),
                          );
                          await _loadDonations();
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
