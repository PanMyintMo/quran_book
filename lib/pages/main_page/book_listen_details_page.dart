import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';

/// Full-screen audio player for a book (separate from [BookReadDetailsPage]).
class BookListenDetailsPage extends StatefulWidget {
  const BookListenDetailsPage({
    super.key,
    required this.title,
    required this.audioUrl,
    this.coverImageUrl,
    this.autoPlay = true,
  });

  final String title;
  final String audioUrl;
  final String? coverImageUrl;
  final bool autoPlay;

  @override
  State<BookListenDetailsPage> createState() => _BookListenDetailsPageState();
}

class _BookListenDetailsPageState extends State<BookListenDetailsPage> {
  final AudioPlayer _player = AudioPlayer();
  Duration? _duration;
  Duration _position = Duration.zero;
  bool _playing = false;
  bool _ready = false;
  bool _loading = true;
  String? _error;

  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.audioUrl.trim();
    if (url.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No audio URL';
        });
      }
      return;
    }

    try {
      await _player.setUrl(url);
      if (!mounted) return;

      _durationSub = _player.durationStream.listen((d) {
        if (mounted) setState(() => _duration = d);
      });
      _positionSub = _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _stateSub = _player.playerStateStream.listen((s) {
        if (mounted) setState(() => _playing = s.playing);
      });

      setState(() {
        _ready = true;
        _loading = false;
      });

      if (widget.autoPlay) {
        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load audio';
        });
      }
    }
  }

  String _format(Duration d) {
    final s = d.inSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    if (h > 0) return '${two(h)}:${two(m)}:${two(sec)}';
    return '${two(m)}:${two(sec)}';
  }

  Future<void> _togglePlay() async {
    if (!_ready) return;
    if (_playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _skip(Duration delta) async {
    final dur = _duration;
    if (dur == null) return;
    var next = _position + delta;
    if (next < Duration.zero) next = Duration.zero;
    if (next > dur) next = dur;
    await _player.seek(next);
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Listen',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSP20x),
                    child: Column(
                      children: [
                        const SizedBox(height: kSP20x),
                        if (widget.coverImageUrl != null &&
                            widget.coverImageUrl!.trim().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(kSP10x),
                            child: CacheNetworkImageWidget(
                              imageUrl: widget.coverImageUrl!,
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: kBoxColor,
                              borderRadius: BorderRadius.circular(kSP10x),
                            ),
                            child: const Icon(
                              Icons.audiotrack,
                              size: 80,
                              color: kAppPrimaryColor,
                            ),
                          ),
                        const SizedBox(height: kSP30x),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: kFontSize18x,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (_duration != null &&
                            _duration!.inMilliseconds > 0) ...[
                          Slider(
                            value: _position.inMilliseconds
                                .toDouble()
                                .clamp(
                                  0,
                                  _duration!.inMilliseconds.toDouble(),
                                ),
                            min: 0,
                            max: _duration!.inMilliseconds.toDouble(),
                            activeColor: kAppPrimaryColor,
                            onChanged: (v) {
                              _player.seek(Duration(milliseconds: v.round()));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _format(_position),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _format(_duration!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else
                          const SizedBox(height: 48),
                        const SizedBox(height: kSP20x),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              iconSize: 40,
                              onPressed: _duration == null
                                  ? null
                                  : () => _skip(const Duration(seconds: -10)),
                              icon: const Icon(Icons.replay_10),
                            ),
                            const SizedBox(width: kSP20x),
                            IconButton(
                              iconSize: 64,
                              onPressed: _ready ? _togglePlay : null,
                              icon: Icon(
                                _playing
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: kAppPrimaryColor,
                              ),
                            ),
                            const SizedBox(width: kSP20x),
                            IconButton(
                              iconSize: 40,
                              onPressed: _duration == null
                                  ? null
                                  : () => _skip(const Duration(seconds: 10)),
                              icon: const Icon(Icons.forward_10),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSP40x),
                      ],
                    ),
                  ),
                ),
    );
  }
}
