import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // FutureBuilder<List<String>>(
          //   future: extractPdfTitlesWithDio(widget.pdfUrl),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(child: CircularProgressIndicator());
          //     } else if (snapshot.hasError) {
          //       return Container(
          //         margin: const EdgeInsets.all(kSP20x),
          //         padding: const EdgeInsets.all(kSP20x),
          //         decoration: BoxDecoration(
          //           color: Colors.red.shade100,
          //           borderRadius: BorderRadius.circular(kSP20x),
          //         ),
          //         child: const Text("Failed to load titles"),
          //       );
          //     } else {
          //       final titles = snapshot.data ?? [];
          //       if (titles.isEmpty) {
          //         return const SizedBox();
          //       }
          //       return IconButton(
          //         icon: const Icon(Icons.menu),
          //         onPressed: () async {
          //           showModalBottomSheet(
          //             backgroundColor: Colors.transparent,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(kSP10x),
          //             ),
          //             context: context,
          //             builder: (_) => _MenuBottomOverView(title: titles),
          //           );
          //         },
          //       );
          //     }
          //   },
          // ),
        ],
        centerTitle: true,
        title: EasyTextWidget(
          text: widget.title,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: GlobalKey(),
      ),
    );
  }
}

class _MenuBottomOverView extends StatelessWidget {
  const _MenuBottomOverView({
    required this.title,
  });

  final List<String> title;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSP20x),
      width: double.infinity,
      margin: const EdgeInsets.all(kSP20x),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSP20x),
        color: kAppPrimaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: kSP20x,
        children: title
            .map(
              (e) => EasyTextWidget(
                text: e,
                fontWeight: FontWeight.w600,
                textColor: kWhiteColor,
              ),
            )
            .toList(),
      ),
    );
  }
}

Future<List<String>> extractPdfTitlesWithDio(String url) async {
  final dio = Dio();
  final response = await dio.get<Uint8List>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );

  final Uint8List bytes = response.data!;
  final PdfDocument document = PdfDocument(inputBytes: bytes);

  String fullText = '';
  for (int i = 0; i < document.pages.count; i++) {
    fullText += PdfTextExtractor(document).extractText(
      startPageIndex: i,
      endPageIndex: i,
    );
  }

  document.dispose();

  final lines = fullText.split('\n');
  final titles = lines.where((line) {
    return line.trim().length > 3 && line.trim().length < 80 && _looksLikeTitle(line);
  }).toList();

  return titles;
}

bool _looksLikeTitle(String line) {
  final trimmed = line.trim();
  final capitalWords = trimmed.split(' ').where((word) => word.isNotEmpty && word[0].toUpperCase() == word[0]).length;
  return capitalWords >= 2;
}
