import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/audio_vo.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/data/vos/pdf_vo.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/utils/picker_delegate_utils.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:uuid/uuid.dart';

class AdminAddPostPage extends StatefulWidget {
  final String? id;
  final String? name;
  final String? overview;
  final String? author;
  final String? imageUrl;
  final String? pdfUrl;
  final String? pdfName;
  final String? audioUrl;
  final String? audioName;
  final CategoryVO? category;
  final List<String>? userIDOfBookMark;
  final DateTime? createAt;
  final DateTime? updateAt;
  final String? bookType;

  const AdminAddPostPage({
    super.key,
    this.id,
    this.name,
    this.overview,
    this.author,
    this.imageUrl,
    this.pdfUrl,
    this.pdfName,
    this.audioUrl,
    this.audioName,
    this.category,
    this.userIDOfBookMark,
    this.createAt,
    this.updateAt,
    this.bookType,
  });

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
  final FirebaseModel _firebaseModel = FirebaseModel();

  CategoryVO? _selectedCategory;
  List<CategoryVO> _categoryList = [];
  String? _selectedCategoryId;
  String _selectedBookType = 'new'; // new | popular | premium

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _overviewController.text = widget.overview ?? '';
    _authorController.text = widget.author ?? '';
    _pdfController.text = widget.pdfName ?? '';
    _audioController.text = widget.audioName ?? '';
    _selectedCategoryId = widget.category?.id;
    _selectedBookType = widget.bookType ?? 'new';
    _loadCategories();
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

  Future<void> _loadCategories() async {
    final categories = await _firebaseModel.getAllCategories();
    setState(() {
      _categoryList = categories;
      if (_selectedCategoryId == null) {
        _selectedCategory = null;
        return;
      }
      final matched = _categoryList.where((c) => c.id == _selectedCategoryId).toList();
      _selectedCategory = matched.isNotEmpty ? matched.first : null;
    });
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

  Future<void> _submitPost() async {
    final name = _nameController.text.trim();
    final overview = _overviewController.text.trim();
    final author = _authorController.text.trim();
    final category = _selectedCategory;

    // Validate required fields (audio is optional)
    if ((widget.imageUrl == null && _selectedImage == null) ||
        name.isEmpty ||
        overview.isEmpty ||
        author.isEmpty ||
        (_pdfController.text.isEmpty && _selectedPdf == null) ||
        category == null) {
      context.showErrorSnackBar("Please fill all required fields (image, name, overview, author, PDF, category)");
      return;
    }

    try {
      context.showLoadingDialog();
      final id = widget.id ?? const Uuid().v4();
      final createAt = widget.createAt ?? DateTime.now();
      final updateAt = DateTime.now();

      // Upload image
      String imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _firebaseModel.uploadFile(_selectedImage!, 'images');
      } else {
        imageUrl = widget.imageUrl!;
      }

      // Upload PDF if selected
      String pdfUrl = widget.pdfUrl ?? '';
      if (_selectedPdf != null) {
        pdfUrl = await _firebaseModel.uploadFile(_selectedPdf!, 'pdf');
      }

      // Upload audio if selected (optional)
      String audioUrl = widget.audioUrl ?? '';
      if (_selectedAudio != null) {
        audioUrl = await _firebaseModel.uploadFile(_selectedAudio!, 'audio');
      }

      // Create audio VO only if audio is provided
      AudioVO? audioVO;
      if (_audioController.text.isNotEmpty && audioUrl.isNotEmpty) {
        audioVO = AudioVO(
          id: id,
          name: _audioController.text,
          url: audioUrl,
          createAt: DateTime.now(),
          updateAt: DateTime.now(),
        );
      }

      final book = BookVO(
        id: id,
        name: name,
        overview: overview,
        author: author,
        image: imageUrl,
        category: category,
        pdf: PdfVO(
          id: id,
          name: _pdfController.text,
          image: imageUrl,
          url: pdfUrl,
          createAt: createAt,
          updateAt: updateAt,
        ),
        audio: audioVO,
        pages: {},
        readBy: [],
        createAt: createAt,
        updateAt: updateAt,
        userIDOfBookMark: widget.userIDOfBookMark ?? [],
        bookType: _selectedBookType,
      );

      if (widget.id != null) {
        await _firebaseModel.updateBook(book);
      } else {
        await _firebaseModel.createBook(book);
      }

      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar(
          widget.id != null ? "Post updated successfully" : "Post added successfully",
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Failed to add post: $e");
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
        title: Text(widget.id != null ? "Update Post" : "Add New Post"),
      ),
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
            GestureDetector(
              onTap: () {
                _pickPdf();
              },
              child: AbsorbPointer(
                child: TextField(
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
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _pickAudio();
              },
              child: AbsorbPointer(
                child: TextField(
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
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CategoryVO>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              items: _categoryList
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.name),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedCategoryId = value?.id;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBookType,
              decoration: const InputDecoration(labelText: 'Select Book Type'),
              items: const [
                DropdownMenuItem(value: 'new', child: Text('New book')),
                DropdownMenuItem(value: 'popular', child: Text('Popular book')),
                DropdownMenuItem(value: 'premium', child: Text('Premium book')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedBookType = value;
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
