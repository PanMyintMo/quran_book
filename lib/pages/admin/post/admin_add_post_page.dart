import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/picker_delegate_utils.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';

class AdminAddPostPage extends StatefulWidget {
  final String? name;
  final String? overview;
  final String? author;
  final String? imageUrl;
  final String? pdfName;
  final String? audioName;
  final String? category;

  const AdminAddPostPage({super.key, this.name, this.overview, this.author, this.imageUrl, this.pdfName, this.audioName, this.category});

  @override
  State<AdminAddPostPage> createState() => _AdminAddPostPageState();
}

class _AdminAddPostPageState extends State<AdminAddPostPage> {
  File? _selectedImage;
  File? _selectedPdf;
  File? _selectedAudio;
  final _nameController = TextEditingController();
  final _overviewController = TextEditingController();
  final _authorController = TextEditingController();
  final _pdfController = TextEditingController();
  final _audioController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _overviewController.text = widget.overview ?? '';
    _authorController.text = widget.author ?? '';
    _pdfController.text = widget.pdfName ?? '';
    _audioController.text = widget.audioName ?? '';
    _selectedCategory = widget.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _overviewController.dispose();
    _authorController.dispose();
    _pdfController.dispose();
    _audioController.dispose();
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

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
        _pdfController.text = result.files.single.name;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
        _audioController.text = result.files.single.name;
      });
    }
  }

  void _submitPost() {
    final name = _nameController.text;
    final overview = _overviewController.text;
    final author = _authorController.text;
    final pdf = _pdfController.text;
    final audio = _audioController.text;

    if ((_selectedImage != null || widget.imageUrl != null) &&
        name.isNotEmpty &&
        overview.isNotEmpty &&
        author.isNotEmpty &&
        pdf.isNotEmpty &&
        audio.isNotEmpty &&
        _selectedCategory != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post added successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
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
      appBar: AppBar(title: const Text("Add New Post")),
      body: SingleChildScrollView(
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
                child: imageWidget,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Book Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _overviewController,
              decoration: const InputDecoration(labelText: 'Overview'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              controller: _pdfController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'PDF File',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickPdf,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              controller: _audioController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Audio File',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.audiotrack),
                  onPressed: _pickAudio,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              items: ['Tafsir', 'Translation', 'Fiqh']
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitPost,
                child: const Text("Add Post"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
