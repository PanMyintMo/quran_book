import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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

  @override
  void initState() {
    super.initState();
    isPlaying = widget.isPlay;
    showMiniPlayer = widget.isPlay;
    if (widget.book.audio?.url.isNotEmpty ?? false) {
      _audioPlayer.setUrl(widget.book.audio!.url);
    }
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final currentUserID = (await _firebaseModel.getCurrentUserVO())?.id;
                if (currentUserID == null) {
                  if (context.mounted) {
                    context.showErrorSnackBar("Please login first.");
                  }
                  return;
                }
                await _firebaseModel.toggleBookmark(book.id, currentUserID);
                if (mounted) context.showSuccessSnackBar("Bookmarked successfully!");
              } catch (e) {
                if (mounted) context.showErrorSnackBar("Bookmark failed: $e");
              }
            },
            icon: const Icon(Icons.bookmark),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.save_alt),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const _DonateDialogView(title: 'Are you sure about the donation?'),
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
                const _OverViewAndTimeView(),
                const SizedBox(height: kSP20x),
                _ReadAndPlayButtonView(
                  icon: Icons.laptop_chromebook,
                  buttonText: kReadText.tr(),
                  isGhost: true,
                  onTap: () => context.navigateToNextPage(BookReadDetailsPage(title: book.name)),
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
            crossFadeState: showMiniPlayer ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(seconds: 1),
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

  const _MiniPlayerUI({required this.audioPlayer, required this.onClose, required this.bookImage});

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
                      text: "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')} left",
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
                    audioPlayer.seek(audioPlayer.position - const Duration(seconds: 10));
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
                    audioPlayer.seek(audioPlayer.position + const Duration(seconds: 10));
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
  const _ReadAndPlayButtonView({required this.onTap, required this.icon, required this.buttonText, required this.isGhost});

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
            EasyTextWidget(text: buttonText, textColor: isGhost ? kBlackColor : kWhiteColor),
          ],
        ),
      ),
    );
  }
}

class _OverViewAndTimeView extends StatelessWidget {
  const _OverViewAndTimeView();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kSP10x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kSP20x),
            color: kBoxColor,
          ),
          child: Row(
            children: [
              const Icon(Icons.laptop_chromebook, size: kBookDetailsOverViewAndTimeIconSize),
              const SizedBox(width: kSP5x),
              EasyTextWidget(
                text: kOverviewText.tr(),
                fontSize: kFontSize12x,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        const SizedBox(width: kSP10x),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kSP10x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kSP20x),
            color: kBoxColor,
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_outlined, size: kBookDetailsOverViewAndTimeIconSize),
              const SizedBox(width: kSP5x),
              const EasyTextWidget(
                text: '38 m',
                fontSize: kFontSize12x,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
