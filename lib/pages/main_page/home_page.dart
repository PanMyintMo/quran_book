import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/pages/main_page/book_list_from_category_page.dart';
import 'package:quran_book/pages/main_page/book_overview_page.dart';
import 'package:quran_book/pages/main_page/book_see_all_page.dart';
import 'package:quran_book/pages/main_page/category_see_all_page.dart';
import 'package:quran_book/pages/main_page/language_page.dart';
import 'package:quran_book/pages/main_page/search_page.dart';
import 'package:quran_book/pages/main_page/setting_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.transparent,
            content: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset(
                  AssetImageUtils.kBlessedImage,
                  fit: BoxFit.cover,
                ),
                IconButton(
                    onPressed: () {
                      context.navigateBack();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: kWhiteColor,
                    )),
              ],
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: _HomePageDrawerView(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kSP10x),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return _HomePageAppbarView(
                    onTapLeadingIcon: () {
                      Scaffold.of(context).openDrawer();
                    },
                    onTapSearch: () {
                      context.navigateToNextPage(SearchPage());
                    },
                  );
                }),
                const SizedBox(
                  height: kSP20x,
                ),
                SizedBox(
                  width: double.infinity,
                  height: kHomePageBannerViewHeight,
                  child: _HomePageBannerView(
                    bannerList: [
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                    ],
                  ),
                ),
                const SizedBox(
                  height: kSP20x,
                ),
                SizedBox(
                  width: double.infinity,
                  height: kHomePageCategoryViewHeight,
                  child: _HomePageCategoryView(
                    title: 'Book Types',
                    onTapSeeAll: () {
                      context.navigateToNextPage(CategorySeeAllPage());
                    },
                    onTapCategory: () {
                      context.navigateToNextPage(BookListFromCategoryPage());
                    },
                  ),
                ),
                const SizedBox(
                  height: kSP20x,
                ),
                SizedBox(
                  width: double.infinity,
                  height: kHomePageBookViewHeight,
                  child: _HomePageBooksView(
                    title: 'New books',
                    onTapBook: () async {
                      if (context.mounted) {
                        context.navigateToNextPage(
                          BookOverviewPage(
                            isPlay: false,
                            // audioHandler: audioHandler,
                          ),
                        );
                      }
                    },
                    onTapSeeAll: () {
                      context.navigateToNextPage(
                        BookSeeAllPage(
                          title: 'New books',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: kSP20x,
                ),
                SizedBox(
                  width: double.infinity,
                  height: kHomePageBookViewHeight,
                  child: _HomePageBooksView(
                    title: 'Popular books',
                    onTapBook: () async {
                      if (context.mounted) {
                        context.navigateToNextPage(
                          BookOverviewPage(
                            isPlay: false,
                          ),
                        );
                      }
                    },
                    onTapSeeAll: () {
                      context.navigateToNextPage(
                        BookSeeAllPage(
                          title: 'Popular books',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: kSP20x,
                ),
                SizedBox(
                  width: double.infinity,
                  height: kHomePageBookViewHeight,
                  child: _HomePageBooksView(
                    title: 'Premium books',
                    onTapBook: () async {
                      if (context.mounted) {
                        context.navigateToNextPage(
                          BookOverviewPage(
                            isPlay: false,
                          ),
                        );
                      }
                    },
                    onTapSeeAll: () {
                      context.navigateToNextPage(
                        BookSeeAllPage(
                          title: 'Premium books',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: kSP20x,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomePageDrawerView extends StatelessWidget {
  const _HomePageDrawerView();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AssetImageUtils.kAppIcon,
                  height: kHomePageDrawerAppIconHeight,
                ),
                const SizedBox(
                  height: kSP10x,
                ),
                EasyTextWidget(
                  text: kDrawerWelcomeText.tr(),
                  fontSize: kFontSize18x,
                  fontWeight: FontWeight.bold,
                ),
                const EasyTextWidget(
                  text: 'v 1.0.0',
                ),
              ],
            ),
          ),
          // Drawer Items
          _buildDrawerItem(
            context,
            icon: Icons.language,
            label: kDrawerLanguageText.tr(),
            onTap: () {
              context.navigateToNextPage(LanguagePage());
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.notifications,
            label: kDrawerNotificationText.tr(),
            onTap: () {},
          ),
          _buildDrawerItem(
            context,
            icon: Icons.rate_review,
            label: kDrawerWriteAnAppStoreReviewText.tr(),
            onTap: () {},
          ),
          _buildDrawerItem(
            context,
            icon: Icons.share,
            label: kDrawerShareTheAppText.tr(),
            onTap: () {},
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            label: kDrawerSettingText.tr(),
            onTap: () {
              context.navigateToNextPage(SettingPage());
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.brightness_6,
            label: kDrawerThemeText.tr(),
            onTap: () {
              context.navigateToNextPage(SettingPage());
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.phone,
            label: kDrawerContactUsText.tr(),
            onTap: () {},
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help_outline,
            label: kDrawerHelpAndSupportText.tr(),
            onTap: () {},
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            label: kDrawerAboutUsText.tr(),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: EasyTextWidget(
        text: label,
      ),
      onTap: () {
        Scaffold.of(context).closeDrawer();
        onTap();
      },
    );
  }
}

class _HomePageCategoryView extends StatelessWidget {
  const _HomePageCategoryView({
    required this.title,
    required this.onTapSeeAll,
    required this.onTapCategory,
  });

  final String title;
  final Function onTapSeeAll;
  final Function onTapCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomePageTitleAndSeeAllView(
          title: title,
          onTapSeeAll: () {
            onTapSeeAll();
          },
        ),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: kSP10x,
              mainAxisSpacing: kSP10x,
              childAspectRatio: 5,
            ),
            itemCount: 4,
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  onTapCategory();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSP10x,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kSP10x),
                    color: kBoxColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ac_unit),
                      const SizedBox(
                        width: kSP10x,
                      ),
                      Flexible(
                        child: EasyTextWidget(
                          text: 'Category',
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomePageBooksView extends StatelessWidget {
  const _HomePageBooksView({
    required this.onTapSeeAll,
    required this.title,
    required this.onTapBook,
  });

  final String title;
  final Function onTapSeeAll;
  final Function onTapBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomePageTitleAndSeeAllView(
          title: title,
          onTapSeeAll: () {
            onTapSeeAll();
          },
        ),
        const SizedBox(
          height: kSP10x,
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, index) => const SizedBox(
              width: kSP10x,
            ),
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  onTapBook();
                },
                child: CacheNetworkImageWidget(
                  radius: kSP10x,
                  imageUrl:
                      'https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3JtNjAzLWVsZW1lbnQtMTg2LnBuZw.png',
                  width: kHomePageBookImageWidth,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomePageTitleAndSeeAllView extends StatelessWidget {
  const _HomePageTitleAndSeeAllView({
    required this.title,
    required this.onTapSeeAll,
  });

  final String title;
  final Function onTapSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        EasyTextWidget(
          text: title,
          fontWeight: FontWeight.w600,
        ),
        IconButton(
          onPressed: () {
            onTapSeeAll();
          },
          icon: const Icon(
            Icons.arrow_forward,
          ),
        )
      ],
    );
  }
}

class _HomePageBannerView extends StatefulWidget {
  const _HomePageBannerView({
    required this.bannerList,
  });

  final List<String> bannerList;

  @override
  State<_HomePageBannerView> createState() => _HomePageBannerViewState();
}

class _HomePageBannerViewState extends State<_HomePageBannerView> {
  final _pageController = PageController();

  @override
  void initState() {
    int count = 0;
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (count + 1 == widget.bannerList.length) {
        _pageController.jumpToPage(0);
        count = 0;
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }

      count++;
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSP10x),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.bannerList.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: EdgeInsets.only(right: kSP10x),
                  child: CacheNetworkImageWidget(
                    radius: kSP10x,
                    imageUrl: widget.bannerList[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: kSP10x,
          ),
          SmoothPageIndicator(
            controller: _pageController, // PageController
            count: widget.bannerList.length,
            effect: SlideEffect(
              dotWidth: kSP10x,
              dotHeight: kSP10x,
              paintStyle: PaintingStyle.stroke,
            ), // your preferred effect
            onDotClicked: (index) {},
          )
        ],
      ),
    );
  }
}

class _HomePageAppbarView extends StatelessWidget {
  const _HomePageAppbarView({
    required this.onTapLeadingIcon,
    required this.onTapSearch,
  });

  final Function onTapLeadingIcon;
  final Function onTapSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.menu,
          ),
          onPressed: () {
            onTapLeadingIcon();
          },
        ),
        Image.asset(
          AssetImageUtils.kAppIcon,
          width: kHomePageAppIconWidth,
          height: kHomePageAppIconHeight,
        ),
        IconButton(
          icon: Icon(
            Icons.search,
          ),
          onPressed: () {
            onTapSearch();
          },
        ),
      ],
    );
  }
}
