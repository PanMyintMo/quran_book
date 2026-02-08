import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/main_page/book_read_details_page.dart';
import 'package:quran_book/pages/main_page/donate_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class BookOverviewPage extends StatefulWidget {
  const BookOverviewPage({super.key, required this.isPlay, required this.book});

  final bool isPlay;
  final BookVO book;

  @override
  State<BookOverviewPage> createState() => _BookOverviewPageState();
}

class _BookOverviewPageState extends State<BookOverviewPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseModel _firebaseModel = FirebaseModel();
  bool isPlaying = false;
  bool showMiniPlayer = false;
  bool _isBookmarked = false;
  String? _currentUserId;
  String? _unbookmarkedBookId;

  @override
  void initState() {
    super.initState();
    isPlaying = widget.isPlay;
    showMiniPlayer = widget.isPlay;
    if (widget.book.audio?.url.isNotEmpty ?? false) {
      _audioPlayer.setUrl(widget.book.audio!.url);
    }
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    final user = await _firebaseModel.getCurrentUserVO();
    if (!mounted) return;
    setState(() {
      _currentUserId = user?.id;
      _isBookmarked = _currentUserId != null &&
          widget.book.userIDOfBookMark.contains(_currentUserId);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      if (mounted) setState(() => isPlaying = !isPlaying);
    } catch (e) {
      if (mounted) context.showErrorSnackBar("Playback error: $e");
    }
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
  }

  void _showMiniPlayer() => setState(() => showMiniPlayer = true);

  Future<void> _downloadPdf() async {
    final book = widget.book;
    final pdfUrl = book.pdf.url;
    if (pdfUrl.isEmpty) {
      if (mounted) context.showErrorSnackBar("No PDF available to download.");
      return;
    }

    try {
      if (mounted) context.showLoadingDialog(message: "Downloading...");
      final dir = await getApplicationDocumentsDirectory();
      final sanitizedName =
          book.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim().replaceAll(' ', '_');
      final fileName = '${sanitizedName}_${book.id}.pdf';
      final filePath = '${dir.path}/$fileName';

      await Dio().download(pdfUrl, filePath);
      if (!mounted) return;
      context.hideLoadingDialog();
      context.showSuccessSnackBar("Downloaded: $fileName");
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar("Download failed: $e");
      }
    }
  }

  void _hideMiniPlayer() {
    setState(() {
      showMiniPlayer = false;
      isPlaying = false;
    });
    _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_unbookmarkedBookId);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  final userId = _currentUserId ??
                      (await _firebaseModel.getCurrentUserVO())?.id;

                  if (userId == null) {
                    if (mounted)
                      context.showErrorSnackBar("Please login first.");
                    return;
                  }

                  await _firebaseModel.toggleBookmark(book.id, userId);
                  if (!mounted) return;

                  setState(() {
                    _isBookmarked = !_isBookmarked;

                    if (_isBookmarked) {
                      book.userIDOfBookMark.add(userId); // ✅ ADD locally
                    } else {
                      book.userIDOfBookMark.remove(userId); // ✅ REMOVE locally
                      _unbookmarkedBookId = book.id;
                    }
                  });

                  context.showSuccessSnackBar(
                    _isBookmarked
                        ? "Bookmarked successfully!"
                        : "Removed from bookmarks.",
                  );
                } catch (e) {
                  if (mounted) context.showErrorSnackBar("Bookmark failed: $e");
                }
              },
              icon:
                  Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            ),
            IconButton(
              onPressed: _downloadPdf,
              icon: const Icon(Icons.save_alt),
            ),
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _DonateDialogView(
                    title: 'Are you sure about the donation?'),
              ),
              icon: const Icon(Icons.card_giftcard),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(kSP20x),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CacheNetworkImageWidget(
                      width: kBookDetailsOverViewImageWidth,
                      height: kBookDetailsOverViewImageHeight,
                      imageUrl: book.image,
                    ),
                  ),
                  const SizedBox(height: kSP10x),
                  EasyTextWidget(
                    text: book.name,
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSize16x,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSP5x),
                  EasyTextWidget(
                    text: 'by ${book.author}',
                    fontSize: kFontSize12x,
                    textColor: Colors.black54,
                  ),
                  const SizedBox(height: kSP10x),
                  _HorizontalInfoSlider(author: book.author),
                  const SizedBox(height: kSP20x),
                  _ReadAndPlayButtonView(
                    icon: Icons.laptop_chromebook,
                    buttonText: kReadText.tr(),
                    isGhost: true,
                    onTap: () => context.navigateToNextPage(BookReadDetailsPage(
                      title: book.name,
                      pdfUrl: book.pdf.url,
                    )),
                  ),
                  const SizedBox(height: kSP10x),
                  _ReadAndPlayButtonView(
                    icon: Icons.play_arrow,
                    buttonText: kListenText.tr(),
                    isGhost: false,
                    onTap: () {
                      requestPermissions().then((_) {
                        _togglePlayPause();
                        _showMiniPlayer();
                      });
                    },
                  ),
                  const SizedBox(height: kSP30x),
                  Align(
                    alignment: Alignment.topLeft,
                    child: EasyTextWidget(
                      text: book.name,
                      fontWeight: FontWeight.w700,
                      fontSize: kFontSize16x,
                    ),
                  ),
                  const SizedBox(height: kSP10x),
                  EasyTextWidget(
                    textAlign: TextAlign.center,
                    textColor: Colors.black54,
                    text: book.overview,
                    maxLines: 7,
                  ),
                  const SizedBox(height: kSP40x),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: _MiniPlayerUI(
                audioPlayer: _audioPlayer,
                onClose: _hideMiniPlayer,
                bookImage: book.image,
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: showMiniPlayer
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(seconds: 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal slider so users can see at a glance that content scrolls horizontally.
class _HorizontalInfoSlider extends StatelessWidget {
  const _HorizontalInfoSlider({required this.author});

  final String author;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 6),
          clipBehavior: Clip.none,
          children: [
            _InfoChip(
              icon: Icons.laptop_chromebook,
              label: kOverviewText.tr(),
            ),
            const SizedBox(width: kSP10x),
            _InfoChip(
              icon: Icons.access_time_outlined,
              label: '38 m',
            ),
            const SizedBox(width: kSP10x),
            _InfoChip(
              icon: Icons.person_outline,
              label: author,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSP10x, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSP20x),
        color: kBoxColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: kBookDetailsOverViewAndTimeIconSize),
          const SizedBox(width: kSP5x),
          Flexible(
            child: EasyTextWidget(
              text: label,
              fontSize: kFontSize12x,
              fontWeight: FontWeight.w600,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonateDialogView extends StatelessWidget {
  const _DonateDialogView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kAppPrimaryColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: kSP30x),
          EasyTextWidget(
            textAlign: TextAlign.center,
            text: title,
            fontSize: kFontSize16x,
            fontWeight: FontWeight.w600,
            textColor: kWhiteColor,
            maxLines: 2,
          ),
          const SizedBox(height: kSP20x),
          PrimaryButtonWidget(
            radius: kSP5x,
            width: kBookOverviewDonateButtonWidth,
            height: kBookOverviewDonateButtonHeight,
            backgroundColor: kWhiteColor,
            onPressed: () {
              context.navigateBack();
              context.navigateToNextPage(const DonatePage());
            },
            buttonText: kYes.tr(),
          ),
          const SizedBox(height: kSP10x),
          PrimaryButtonWidget(
            radius: kSP5x,
            width: kBookOverviewDonateButtonWidth,
            height: kBookOverviewDonateButtonHeight,
            backgroundColor: kAppYellowButtonColor,
            onPressed: () => context.navigateBack(),
            buttonText: kNo.tr(),
          ),
          const SizedBox(height: kSP30x),
        ],
      ),
    );
  }
}

class _MiniPlayerUI extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final VoidCallback onClose;
  final String bookImage;

  const _MiniPlayerUI(
      {required this.audioPlayer,
      required this.onClose,
      required this.bookImage});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: kBookDetailsOverViewMiniPlayHeight,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black54)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CacheNetworkImageWidget(
              width: kBookDetailsOverViewMiniPlayImageWidth,
              height: kBookDetailsOverViewMiniPlayImageHeight,
              imageUrl: bookImage,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EasyTextWidget(
                  text: "What the Says",
                  maxLines: 1,
                  fontWeight: FontWeight.w600,
                ),
                StreamBuilder<Duration?>(
                  stream: audioPlayer.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return EasyTextWidget(
                      text:
                          "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')} left",
                      fontWeight: FontWeight.w600,
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () {
                    audioPlayer.seek(
                        audioPlayer.position - const Duration(seconds: 10));
                  },
                ),
                StreamBuilder<bool>(
                  stream: audioPlayer.playingStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        playing ? audioPlayer.pause() : audioPlayer.play();
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () {
                    audioPlayer.seek(
                        audioPlayer.position + const Duration(seconds: 10));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadAndPlayButtonView extends StatelessWidget {
  const _ReadAndPlayButtonView(
      {required this.onTap,
      required this.icon,
      required this.buttonText,
      required this.isGhost});

  final VoidCallback onTap;
  final IconData icon;
  final String buttonText;
  final bool isGhost;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kBookOverviewDonateReadPlayButtonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSP10x),
        color: isGhost ? kWhiteColor : kAppPrimaryColor,
        border: isGhost ? Border.all(color: kBlackColor) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(kSP10x),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isGhost ? kBlackColor : kWhiteColor),
            const SizedBox(width: kSP10x),
            EasyTextWidget(
                text: buttonText,
                textColor: isGhost ? kBlackColor : kWhiteColor),
          ],
        ),
      ),
    );
  }
}

