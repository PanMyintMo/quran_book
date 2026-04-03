import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Page-by-page text extracted from the book PDF. Use [BookListenDetailsPage] for audio.
class BookReadDetailsPage extends StatefulWidget {
  const BookReadDetailsPage({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  final String title;
  final String pdfUrl;

  @override
  State<BookReadDetailsPage> createState() => _BookReadDetailsPageState();
}

class _BookReadDetailsPageState extends State<BookReadDetailsPage> {
  bool _isLoading = true;
  int _currentPageIndex = 0;
  List<String> _pageTexts = const [];

  @override
  void initState() {
    super.initState();
    _loadPdfTexts();
  }

  Future<void> _loadPdfTexts() async {
    setState(() => _isLoading = true);
    try {
      final pages = await extractPdfPageTextsWithDio(widget.pdfUrl);
      if (!mounted) return;
      setState(() {
        _pageTexts = pages;
        _currentPageIndex = 0;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pageTexts = const [];
        _currentPageIndex = 0;
        _isLoading = false;
      });
    }
  }

  void _goToPage(int newIndex) {
    if (_pageTexts.isEmpty) return;
    final clamped = newIndex.clamp(0, _pageTexts.length - 1);
    setState(() => _currentPageIndex = clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pageTexts.isEmpty
              ? const Center(child: Text('No text available'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(kSP20x),
                        child: Text(
                          _pageTexts[_currentPageIndex],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(kSP20x, 0, kSP20x, kSP20x),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: _currentPageIndex > 0
                                ? () => _goToPage(_currentPageIndex - 1)
                                : null,
                          ),
                          Text(
                            '${_currentPageIndex + 1} of ${_pageTexts.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kAppPrimaryColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: _currentPageIndex < _pageTexts.length - 1
                                ? () => _goToPage(_currentPageIndex + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

Future<List<String>> extractPdfPageTextsWithDio(String url) async {
  final dio = Dio();
  final response = await dio.get<Uint8List>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );

  final Uint8List bytes = response.data!;
  final PdfDocument document = PdfDocument(inputBytes: bytes);

  try {
    final extractor = PdfTextExtractor(document);
    final pages = <String>[];
    for (int i = 0; i < document.pages.count; i++) {
      final text = extractor.extractText(
        startPageIndex: i,
        endPageIndex: i,
      );
      pages.add(text.trim());
    }
    return pages;
  } finally {
    document.dispose();
  }
}
