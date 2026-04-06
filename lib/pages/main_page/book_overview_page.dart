import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/pages/main_page/book_listen_details_page.dart';
import 'package:quran_book/pages/main_page/book_read_details_page.dart';
import 'package:quran_book/pages/main_page/donate_page.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
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
    if (!mounted) return;
    setState(() {
      // Always use FirebaseAuth UID so it matches all other bookmark filters.
      _currentUserId = FirebaseAuth.instance.currentUser?.uid;
      _isBookmarked = _currentUserId != null &&
          widget.book.userIDOfBookMark.contains(_currentUserId);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
  }

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

      // Auto-open the downloaded file
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && mounted) {
        context.showErrorSnackBar("Could not open file: ${result.message}");
      }
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.surface,
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  final userId = _currentUserId ??
                      FirebaseAuth.instance.currentUser?.uid;

                  if (userId == null) {
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: EasyTextWidget(
                          text: 'Login required',
                          fontWeight: FontWeight.w600,
                          fontSize: kFontSize16x,
                        ),
                        content: EasyTextWidget(
                          text: 'Please login to bookmark this book.',
                          fontWeight: FontWeight.w400,
                          fontSize: kFontSize14x,
                          textColor: Colors.grey,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancel'),
                          ),
                          PrimaryButtonWidget(
                            height: 40,
                            radius: 8,
                            width: 110,
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.navigateToNextPageWithRemoveUntil(
                                const LoginPage(),
                              );
                            },
                            buttonText: kLogin.tr(),
                            buttonTextColor: kWhiteColor,
                            backgroundColor: kAppPrimaryColor,
                            buttonFontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  // Use current book data to decide add/remove direction.
                  // This avoids UI desync when `_isBookmarked` hasn't finished loading yet.
                  final alreadyBookmarked =
                      book.userIDOfBookMark.contains(userId);

                  // Set return value immediately so the parent can update
                  // reliably when user goes back (PopScope reads this field).
                  _unbookmarkedBookId = alreadyBookmarked ? book.id : null;

                  await _firebaseModel.toggleBookmark(book.id, userId);
                  if (!mounted) return;

                  setState(() {
                    if (alreadyBookmarked) {
                      book.userIDOfBookMark.remove(userId); // ✅ REMOVE locally
                      _isBookmarked = false;
                    } else {
                      if (!book.userIDOfBookMark.contains(userId)) {
                        book.userIDOfBookMark.add(userId); // ✅ ADD locally
                      }
                      _isBookmarked = true;
                    }
                  });

                  context.showSuccessSnackBar(
                    alreadyBookmarked
                        ? "Removed from bookmarks."
                        : "Bookmarked successfully!",
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
              padding: EdgeInsets.fromLTRB(
                kSP20x,
                kSP5x,
                kSP20x,
                kSP20x + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = (constraints.maxWidth * 0.45)
                          .clamp(158.0, 228.0)
                          .toDouble();
                      final h = w * 1.38;
                      return Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CacheNetworkImageWidget(
                            width: w,
                            height: h,
                            imageUrl: book.image,
                            fit: BoxFit.cover,
                            radius: 18,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: kSP15x),
                  EasyTextWidget(
                    text: book.name,
                    fontWeight: FontWeight.w700,
                    fontSize: kFontSize21x,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSP5x),
                  EasyTextWidget(
                    text: 'by ${book.author}',
                    fontSize: kFontSize14x,
                    textAlign: TextAlign.center,
                    textColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.62),
                  ),
                  const SizedBox(height: kSP10x),
                  _HorizontalInfoSlider(
                    author: book.author,
                    audioPlayer: _audioPlayer,
                    hasAudio: book.audio?.url.isNotEmpty ?? false,
                  ),
                  const SizedBox(height: kSP15x),
                  _ReadAndPlayButtonView(
                    icon: Icons.menu_book_outlined,
                    buttonText: kReadText.tr(),
                    isGhost: true,
                    onTap: () => context.navigateToNextPage(BookReadDetailsPage(
                      title: book.name,
                      pdfUrl: book.pdf.url,
                    )),
                  ),
                  const SizedBox(height: kSP10x),
                  _ReadAndPlayButtonView(
                    icon: Icons.play_circle_outline,
                    buttonText: kListenText.tr(),
                    isGhost: false,
                    onTap: () {
                      final audioUrl = book.audio?.url;
                      if (audioUrl == null || audioUrl.isEmpty) {
                        if (mounted) {
                          context.showErrorSnackBar("No audio available.");
                        }
                        return;
                      }
                      requestPermissions().then((_) {
                        if (!mounted) return;
                        context.navigateToNextPage(BookListenDetailsPage(
                          title: book.name,
                          audioUrl: audioUrl,
                          coverImageUrl: book.image,
                          autoPlay: true,
                        ));
                      });
                    },
                  ),
                  const SizedBox(height: kSP20x),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      kOverviewText.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  const SizedBox(height: kSP5x),
                  Text(
                    book.overview,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.78),
                        ),
                  ),
                  const SizedBox(height: kSP20x),
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
class _HorizontalInfoSlider extends StatefulWidget {
  const _HorizontalInfoSlider({
    required this.author,
    required this.audioPlayer,
    required this.hasAudio,
  });

  final String author;
  final AudioPlayer audioPlayer;
  final bool hasAudio;

  @override
  State<_HorizontalInfoSlider> createState() => _HorizontalInfoSliderState();
}

class _HorizontalInfoSliderState extends State<_HorizontalInfoSlider> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: false,
        trackVisibility: false,
        child: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          children: [
            _InfoChip(
              icon: Icons.menu_book,
              label: kOverviewText.tr(),
            ),
            const SizedBox(width: kSP10x),
            if (widget.hasAudio)
              StreamBuilder<Duration?>(
                stream: widget.audioPlayer.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data;
                  String durationText = 'Audio';
                  if (duration != null) {
                    final minutes = duration.inMinutes;
                    if (minutes > 0) {
                      durationText = '$minutes min';
                    } else {
                      durationText = '${duration.inSeconds} sec';
                    }
                  }
                  return _InfoChip(
                    icon: Icons.access_time_outlined,
                    label: durationText,
                  );
                },
              )
            else
              _InfoChip(
                icon: Icons.access_time_outlined,
                label: 'No Audio',
              ),
            const SizedBox(width: kSP10x),
            _InfoChip(
              icon: Icons.person_outline,
              label: widget.author,
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: kBookDetailsOverViewAndTimeIconSize,
            color: scheme.onSurface.withValues(alpha: 0.75),
          ),
          const SizedBox(width: kSP5x),
          Flexible(
            child: EasyTextWidget(
              text: label,
              fontSize: kFontSize12x,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              textColor: scheme.onSurface.withValues(alpha: 0.88),
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
    final scheme = Theme.of(context).colorScheme;
    final ghostBorder = scheme.outline.withValues(alpha: 0.45);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          height: kBookOverviewDonateReadPlayButtonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isGhost ? scheme.surface : kAppPrimaryColor,
            border: isGhost ? Border.all(color: ghostBorder, width: 1.2) : null,
            boxShadow: isGhost
                ? null
                : [
                    BoxShadow(
                      color: kAppPrimaryColor.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isGhost
                    ? scheme.onSurface.withValues(alpha: 0.9)
                    : kWhiteColor,
              ),
              const SizedBox(width: kSP10x),
              EasyTextWidget(
                text: buttonText,
                fontWeight: FontWeight.w600,
                textColor: isGhost
                    ? scheme.onSurface.withValues(alpha: 0.9)
                    : kWhiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

