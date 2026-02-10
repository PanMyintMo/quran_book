import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/donation_vo.dart';
import 'package:uuid/uuid.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/picker_delegate_utils.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminAddDonationPage extends StatefulWidget {
  final String? name;
  final String? accountNumber;
  final String? imageUrl;

  const AdminAddDonationPage({super.key, this.name, this.accountNumber, this.imageUrl});

  @override
  State<AdminAddDonationPage> createState() => _AdminAddDonationPageState();
}

class _AdminAddDonationPageState extends State<AdminAddDonationPage> {
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  File? _selectedImage;
  final FirebaseModel _firebaseModel = FirebaseModel();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _accountController.text = widget.accountNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final File? image = await showModalBottomSheet<File?>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () async {
              if (context.mounted) {
                context.navigateBack(await PickerDelegateUtils.takePhoto());
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery"),
            onTap: () async {
              context.navigateBack(await PickerDelegateUtils.takePhoto(isCamera: false));
            },
          ),
        ],
      ),
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitDonation() async {
    final name = _nameController.text.trim();
    final account = _accountController.text.trim();

    if ((_selectedImage != null || widget.imageUrl != null) && name.isNotEmpty && account.isNotEmpty) {
      try {
        context.showLoadingDialog();

        String imageUrl = widget.imageUrl ?? '';
        if (_selectedImage != null) {
          imageUrl = await _firebaseModel.uploadFile(_selectedImage!, 'donations');
        }

        final donation = DonationVO(
          id: const Uuid().v4(),
          name: name,
          accNumber: account,
          image: imageUrl,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
        );

        await _firebaseModel.createDonation(donation);

        if (mounted) {
          context.hideLoadingDialog();
          context.showSuccessSnackBar("Donation setup saved successfully");
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          context.hideLoadingDialog();
          context.showErrorSnackBar("Failed to save donation setup: $e");
        }
      }
    } else {
      if (mounted) {
        context.showErrorSnackBar("Please fill all fields");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _selectedImage != null
        ? Image.file(_selectedImage!, fit: BoxFit.cover)
        : widget.imageUrl != null
            ? CacheNetworkImageWidget(imageUrl: widget.imageUrl!, fit: BoxFit.cover)
            : const Center(child: Text("Tap to select image"));

    return Scaffold(
      appBar: AppBar(title: const EasyTextWidget(text: "Add Donation Setup")),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: imageWidget,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitDonation,
                  child: const Text("Save Setup"),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
