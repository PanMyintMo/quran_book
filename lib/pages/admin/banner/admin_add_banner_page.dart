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
  final String? id;
  final String? imageUrl;
  final DateTime? createAt;
  final DateTime? updateAt;

  const AdminAddBannerPage({
    super.key,
    this.id,
    this.imageUrl,
    this.createAt,
    this.updateAt,
  });

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

  Future<void> _submitBanner() async {
    try {
      context.showLoadingDialog();

      final String imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _firebaseModel.uploadFile(_selectedImage!, 'banners');
      } else if (widget.imageUrl != null) {
        imageUrl = widget.imageUrl!;
      } else {
        if (mounted) {
          context.hideLoadingDialog();
          context.showErrorSnackBar("Please select an image");
        }
        return;
      }

      final bannerId = widget.id ?? const Uuid().v4();
      final createAt = widget.createAt ?? DateTime.now();
      final updateAt = DateTime.now();

      final banner = BannerVO(
        id: bannerId,
        image: imageUrl,
        createAt: createAt,
        updateAt: updateAt,
      );

      if (widget.id != null) {
        await _firebaseModel.updateBanner(banner);
      } else {
        await _firebaseModel.createBanner(banner);
      }

      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar(
          widget.id != null ? "Banner updated successfully" : "Banner saved successfully",
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed to save banner: $e");
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
      appBar: AppBar(
        title: EasyTextWidget(
          text: widget.id != null ? "Update Banner" : "Add Banner",
        ),
      ),
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
