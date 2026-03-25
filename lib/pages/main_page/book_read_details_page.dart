import 'dart:typed_data';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class BookReadDetailsPage extends StatefulWidget {
  const BookReadDetailsPage({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.audioUrl,
    this.autoPlayAudio = false,
  });

  final String title;
  final String pdfUrl;
  final String? audioUrl;
  final bool autoPlayAudio;

  @override
  State<BookReadDetailsPage> createState() => _BookReadDetailsPageState();
}

class _BookReadDetailsPageState extends State<BookReadDetailsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration? _audioDuration;
  Duration _audioPosition = Duration.zero;
  bool _isAudioPlaying = false;
  bool _isAudioReady = false;

  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  bool _isLoading = true;
  int _currentPageIndex = 0;
  List<String> _pageTexts = const [];

  @override
  void initState() {
    super.initState();
    _loadPdfTexts();
    _initAudio();
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

  Future<void> _initAudio() async {
    final url = widget.audioUrl?.trim();
    if (url == null || url.isEmpty) return;

    try {
      await _audioPlayer.setUrl(url);
      if (!mounted) return;
      setState(() => _isAudioReady = true);

      _durationSub = _audioPlayer.durationStream.listen((d) {
        if (!mounted) return;
        setState(() => _audioDuration = d);
      });

      _positionSub = _audioPlayer.positionStream.listen((p) {
        if (!mounted) return;
        setState(() => _audioPosition = p);

        // Auto sync displayed page with audio position when possible.
        final duration = _audioDuration;
        if (duration == null || _pageTexts.isEmpty) return;

        final msPerPage = duration.inMilliseconds / _pageTexts.length;
        if (msPerPage <= 0) return;
        final idx = (p.inMilliseconds / msPerPage).floor();
        final clamped = idx.clamp(0, _pageTexts.length - 1);
        if (clamped != _currentPageIndex) {
          setState(() => _currentPageIndex = clamped);
        }
      });

      _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() => _isAudioPlaying = state.playing);
      });

      if (widget.autoPlayAudio) {
        await _audioPlayer.play();
      }
    } catch (_) {
      // Non-blocking: reading still works without audio.
    }
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String two(int v) => v.toString().padLeft(2, '0');

    if (hours > 0) {
      return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    }
    return '${two(minutes)}:${two(seconds)}';
  }

  double? get _pageMs =>
      (_audioDuration != null && _pageTexts.isNotEmpty)
          ? (_audioDuration!.inMilliseconds / _pageTexts.length)
          : null;

  Future<void> _seekToPage(int newIndex) async {
    if (_pageTexts.isEmpty) return;
    final clamped = newIndex.clamp(0, _pageTexts.length - 1);
    setState(() => _currentPageIndex = clamped);

    final msPerPage = _pageMs;
    if (msPerPage == null || msPerPage <= 0) return;

    final targetMs = (clamped * msPerPage).round();
    final duration = _audioDuration;
    if (duration == null || duration.inMilliseconds <= 0) return;

    final safeMs = targetMs.clamp(0, duration.inMilliseconds);
    await _audioPlayer.seek(Duration(milliseconds: safeMs));
  }

  Future<void> _togglePlayPause() async {
    if (!_isAudioReady) return;
    if (_isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _skipBy(Duration delta) async {
    if (_audioDuration == null) return;
    final target = _audioPosition + delta;
    final duration = _audioDuration!;
    final safe = target < Duration.zero
        ? Duration.zero
        : (target > duration ? duration : target);
    await _audioPlayer.seek(safe);
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
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
                                ? () => _seekToPage(_currentPageIndex - 1)
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
                                ? () => _seekToPage(_currentPageIndex + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    if ((widget.audioUrl?.trim().isNotEmpty ?? false))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(kSP20x, 0, kSP20x, kSP20x),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10),
                                  tooltip: 'Skip back',
                                  onPressed: _audioDuration == null
                                      ? null
                                      : () => _skipBy(const Duration(seconds: 10)),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isAudioPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    color: kAppPrimaryColor,
                                    size: 44,
                                  ),
                                  tooltip: _isAudioPlaying ? 'Pause' : 'Play',
                                  onPressed: _isAudioReady ? _togglePlayPause : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.forward_10),
                                  tooltip: 'Skip forward',
                                  onPressed: _audioDuration == null
                                      ? null
                                      : () => _skipBy(const Duration(seconds: 10)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (_audioDuration != null && _audioDuration!.inMilliseconds > 0)
                              Column(
                                children: [
                                  Slider(
                                    value: _audioPosition.inMilliseconds
                                        .toDouble()
                                        .clamp(
                                          0,
                                          _audioDuration!.inMilliseconds.toDouble(),
                                        ),
                                    min: 0,
                                    max: _audioDuration!.inMilliseconds.toDouble(),
                                    onChanged: (v) {
                                      final targetMs = v.round();
                                      _audioPlayer.seek(Duration(milliseconds: targetMs));
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(_audioPosition),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(_audioDuration ?? Duration.zero),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
