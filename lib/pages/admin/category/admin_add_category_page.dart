import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:uuid/uuid.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/picker_delegate_utils.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class AdminAddCategoryPage extends StatefulWidget {
  final String? name;
  final String? subtitle;
  final String? imageUrl;

  const AdminAddCategoryPage({super.key, this.name, this.subtitle, this.imageUrl});

  @override
  State<AdminAddCategoryPage> createState() => _AdminAddCategoryPageState();
}

class _AdminAddCategoryPageState extends State<AdminAddCategoryPage> {
  File? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final FirebaseModel _firebaseModel = FirebaseModel();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _subtitleController.text = widget.subtitle ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
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

  Future<void> _submitCategory() async {
    final name = _nameController.text.trim();
    final subtitle = _subtitleController.text.trim();

    if ((_selectedImage != null || widget.imageUrl != null) && name.isNotEmpty && subtitle.isNotEmpty) {
      try {
        context.showLoadingDialog();

        String imageUrl = widget.imageUrl ?? '';
        if (_selectedImage != null) {
          imageUrl = await _firebaseModel.uploadFile(_selectedImage!, 'categories');
        }

        final category = CategoryVO(
          id: const Uuid().v4(),
          image: imageUrl,
          name: name,
          subtitle: subtitle,
          totalBookCount: 0,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
        );

        await _firebaseModel.createCategory(category);

        if (mounted) {
          context.hideLoadingDialog();
          context.showSuccessSnackBar("Category added successfully");
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          context.hideLoadingDialog();
          context.showErrorSnackBar("Failed to add category: $e");
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
      appBar: AppBar(title: const EasyTextWidget(text: "Add New Category")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Subtitle'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitCategory,
                child: const Text("Add Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
