import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final bool _isPdf;
  WebViewController? _webController;
  bool _webLoading = true;
  bool _webError = false;

  @override
  void initState() {
    super.initState();
    _isPdf = _detectPdf(widget.pdfUrl);
    if (!_isPdf) _initWebView();
  }

  bool _detectPdf(String url) {
    final path = url.split('?').first.toLowerCase();
    return path.endsWith('.pdf') || path.contains('.pdf');
  }

  void _initWebView() {
    final googleDocsUrl =
        'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.pdfUrl)}&embedded=true';

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (mounted) setState(() => _webLoading = false);
        },
        onWebResourceError: (_) {
          if (mounted) {
            setState(() {
              _webLoading = false;
              _webError = true;
            });
          }
        },
      ))
      ..loadRequest(Uri.parse(googleDocsUrl));
  }

  void _retry() {
    setState(() {
      _webLoading = true;
      _webError = false;
    });
    _initWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: EasyTextWidget(
          text: widget.title,
          fontWeight: FontWeight.w600,
          fontSize: kFontSize16x,
        ),
      ),
      body: _isPdf ? _buildPdfViewer() : _buildDocViewer(),
    );
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.network(
      widget.pdfUrl,
      key: GlobalKey(),
      pageLayoutMode: PdfPageLayoutMode.continuous,
      pageSpacing: 0,
    );
  }

  Widget _buildDocViewer() {
    if (_webError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kSP20x),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: kSP20x),
              const EasyTextWidget(
                text: 'Failed to load document. Check your connection.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSP20x),
              ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kAppPrimaryColor),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webController!),
        if (_webLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
