import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/banner_vo.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/picker_delegate_utils.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:uuid/uuid.dart';

class AdminAddBannerPage extends StatefulWidget {
  final String? imageUrl;

  const AdminAddBannerPage({super.key, this.imageUrl});

  @override
  State<AdminAddBannerPage> createState() => _AdminAddBannerPageState();
}

class _AdminAddBannerPageState extends State<AdminAddBannerPage> {
  File? _selectedImage;
  final FirebaseModel _firebaseModel = FirebaseModel();

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
              context.navigateBack(await PickerDelegateUtils.takePhoto(
                isCamera: false,
              ));
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

  Future<void> _submitBanner() async {
    if (_selectedImage != null) {
      final imageUrl = await _firebaseModel.uploadFile(_selectedImage!, 'banners');
      final banner = BannerVO(
        id: const Uuid().v4(),
        image: imageUrl,
        createAt: DateTime.now(),
        updateAt: DateTime.now(),
      );
      await _firebaseModel.createBanner(banner);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Banner saved successfully")),
        );
        Navigator.pop(context);
      }
    } else if (widget.imageUrl != null) {
      final banner = BannerVO(
        id: const Uuid().v4(), // In a real case, pass the existing ID when editing
        image: widget.imageUrl!,
        createAt: DateTime.now(),
        updateAt: DateTime.now(),
      );
      await _firebaseModel.createBanner(banner);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Banner updated successfully")),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
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
      appBar: AppBar(title: const EasyTextWidget(text: "Add Banner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBanner,
                child: const Text("Save Banner"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
