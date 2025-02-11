import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
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
  const BookOverviewPage({
    super.key,
    required this.isPlay,
  });

  final bool isPlay;

  @override
  State<BookOverviewPage> createState() => _BookOverviewPageState();
}

class _BookOverviewPageState extends State<BookOverviewPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool showMiniPlayer = false;
  final String musicUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"; // Replace with actual URL

  @override
  void initState() {
    super.initState();
    isPlaying = widget.isPlay;
    showMiniPlayer = widget.isPlay;
    _audioPlayer.setUrl(musicUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
  }

  void _showMiniPlayer() {
    setState(() {
      showMiniPlayer = true;
    });
  }

  void _hideMiniPlayer() {
    setState(() {
      showMiniPlayer = false;
      isPlaying = false;
      _audioPlayer.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.save_alt),
          ),
          IconButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => _DonateDialogView(title: 'Are you sure about the donation?'));
            },
            icon: const Icon(Icons.card_giftcard),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(
                kSP20x,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CacheNetworkImageWidget(
                      width: kBookDetailsOverViewImageWidth,
                      height: kBookDetailsOverViewImageHeight,
                      imageUrl:
                          'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                    ),
                  ),
                  const SizedBox(height: kSP10x),
                  EasyTextWidget(
                    text: 'What they says',
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSize16x,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: kSP5x),
                  EasyTextWidget(
                    text: 'by Thomas',
                    fontSize: kFontSize12x,
                    textColor: Colors.black54,
                  ),
                  const SizedBox(height: kSP10x),
                  _OverViewAndTimeView(),
                  const SizedBox(height: kSP20x),
                  _ReadAndPlayButtonView(
                    icon: Icons.laptop_chromebook,
                    buttonText: kReadText,
                    isGhost: true,
                    onTap: () {
                      context.navigateToNextPage(BookReadDetailsPage(
                        title: 'What they says',
                      ));
                    },
                  ),
                  const SizedBox(height: kSP10x),
                  _ReadAndPlayButtonView(
                    icon: Icons.play_arrow,
                    buttonText: kListenText,
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
                      text: 'စာအုပ်မိတ်ဆက်',
                      fontWeight: FontWeight.w700,
                      fontSize: kFontSize16x,
                    ),
                  ),
                  const SizedBox(height: kSP10x),
                  EasyTextWidget(
                    textAlign: TextAlign.center,
                    textColor: Colors.black54,
                    text:
                        'မြန်မာစာစတင်ဖြစ်ပေါ်လာခြင်းသည် မြန်မာသည် ပျူနှင့်မွန်စာရေးနည်းကို စံတင်ပြီး (၁၂)ရာစုတွင် မြန်မာဘာသာ ပေါ်ထွန်းလာခဲ့ခြင်းဖြစ်သည်။ မြန်မာနိုင်ငံ စတင်တည်ထောင်စဉ်ကာလ အနော်ရထာမင်း၏ လက်ထက်တွင် သက္ကတဘာသာစာဖြင့် ရေးသောအုတ်ခွက်စာများ၊ ပါဠိစာများဖြင့်ရေးသော အုတ်ခွက်စာများကို အထောက်အထားပြုကာ မြန်မာ့တို့သည် မူလက ပါဠိနှင့် သက္ကတဘာသာတို့ကို ရင်းနှီးခဲ့ကြောင်း သိရသည်။ ',
                    maxLines: 7,
                  ),
                  const SizedBox(height: kSP40x),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: _MiniPlayerUI(audioPlayer: _audioPlayer, onClose: _hideMiniPlayer),
            secondChild: const SizedBox.shrink(),
            crossFadeState: showMiniPlayer ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: Duration(seconds: 1),
          )
        ],
      ),
    );
  }
}

class _DonateDialogView extends StatelessWidget {
  const _DonateDialogView({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kAppPrimaryColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: kSP30x,
          ),
          EasyTextWidget(
            textAlign: TextAlign.center,
            text: title,
            fontSize: kFontSize16x,
            fontWeight: FontWeight.w600,
            textColor: kWhiteColor,
            maxLines: 2,
          ),
          const SizedBox(
            height: kSP20x,
          ),
          PrimaryButtonWidget(
            radius: kSP5x,
            width: kBookOverviewDonateButtonWidth,
            height: kBookOverviewDonateButtonHeight,
            backgroundColor: kWhiteColor,
            onPressed: () {
              context.navigateBack();
              context.navigateToNextPage(DonatePage());
            },
            buttonText: kYes,
          ),
          const SizedBox(
            height: kSP10x,
          ),
          PrimaryButtonWidget(
            radius: kSP5x,
            width: kBookOverviewDonateButtonWidth,
            height: kBookOverviewDonateButtonHeight,
            backgroundColor: kAppYellowButtonColor,
            onPressed: () {
              context.navigateBack();
            },
            buttonText: kNo,
          ),
          const SizedBox(
            height: kSP30x,
          ),
        ],
      ),
    );
  }
}

class _MiniPlayerUI extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final VoidCallback onClose;

  const _MiniPlayerUI({required this.audioPlayer, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: kBookDetailsOverViewMiniPlayHeight,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black54,
            ),
          ),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CacheNetworkImageWidget(
              width: kBookDetailsOverViewMiniPlayImageWidth,
              height: kBookDetailsOverViewMiniPlayImageHeight,
              imageUrl:
                  'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EasyTextWidget(
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
                  icon: Icon(
                    Icons.replay_10,
                  ),
                  onPressed: () {
                    audioPlayer.seek(audioPlayer.position - Duration(seconds: 10));
                  },
                ),
                StreamBuilder<bool>(
                  stream: audioPlayer.playingStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
                        playing ? audioPlayer.pause() : audioPlayer.play();
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.forward_10,
                  ),
                  onPressed: () {
                    audioPlayer.seek(audioPlayer.position + Duration(seconds: 10));
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                  ),
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
  const _ReadAndPlayButtonView({
    required this.onTap,
    required this.icon,
    required this.buttonText,
    required this.isGhost,
  });

  final Function onTap;
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
        border: isGhost
            ? Border.all(
                color: kBlackColor,
              )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(kSP10x),
        onTap: () {
          onTap();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isGhost ? kBlackColor : kWhiteColor,
            ),
            const SizedBox(
              width: kSP10x,
            ),
            EasyTextWidget(
              text: buttonText,
              textColor: isGhost ? kBlackColor : kWhiteColor,
            )
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.laptop_chromebook,
                size: kBookDetailsOverViewAndTimeIconSize,
              ),
              const SizedBox(
                width: kSP5x,
              ),
              EasyTextWidget(
                text: kOverviewText,
                fontSize: kFontSize12x,
                fontWeight: FontWeight.w600,
              )
            ],
          ),
        ),
        const SizedBox(
          width: kSP10x,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kSP10x),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kSP20x),
            color: kBoxColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_outlined,
                size: kBookDetailsOverViewAndTimeIconSize,
              ),
              const SizedBox(
                width: kSP5x,
              ),
              EasyTextWidget(
                text: '38 m',
                fontSize: kFontSize12x,
                fontWeight: FontWeight.w600,
              )
            ],
          ),
        ),
      ],
    );
  }
}
