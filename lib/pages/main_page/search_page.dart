import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/book_vo.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/asset_image_utils.dart';
import 'package:quran_book/utils/date_time_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<BookVO> _searchResults = [];
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final books = await _firebaseModel.getAllBooks();
      final results = books
          .where(
              (book) => book.name.toLowerCase().contains(query.toLowerCase()) || book.overview.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (mounted) {
        setState(() {
          _query = query;
          _searchResults = results;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kSP10x),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: kWhiteColor),
                decoration: InputDecoration(
                  fillColor: kAppPrimaryColor,
                  filled: true,
                  hintText: kSearchHintText.tr(),
                  hintStyle: const TextStyle(color: kWhiteColor),
                  prefixIcon: const Icon(Icons.search, color: kWhiteColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kSP10x),
                  ),
                ),
              ),
              const SizedBox(height: kSP20x),
              Expanded(
                child: ListView.separated(
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, index) => const SizedBox(height: kSP20x),
                  itemBuilder: (_, index) {
                    final book = _searchResults[index];
                    return _SearchResultItemView(
                      title: book.name,
                      description: book.overview,
                      index: index + 1,
                      updateAt: book.updateAt.getHoursAndMinutes,
                      isSelect: book.userIDOfBookMark.contains(_firebaseModel.currentUser?.uid ?? ''),
                      onTapSave: () async {
                        final userId = _firebaseModel.currentUser?.uid;
                        if (userId != null) {
                          await _firebaseModel.toggleBookmark(book.id, userId);
                          _onSearchChanged(_query); // Refresh results
                        }
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultItemView extends StatelessWidget {
  const _SearchResultItemView({
    required this.title,
    required this.description,
    required this.index,
    required this.onTapSave,
    required this.updateAt,
    required this.isSelect,
  });

  final int index;
  final String title;
  final String description;
  final String updateAt;
  final Function onTapSave;
  final bool isSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kSP10x),
      margin: const EdgeInsets.only(bottom: kSP40x),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSP10x),
        border: Border.all(color: kBlackColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: kSearchIconSize,
                height: kSearchIconSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetImageUtils.kSearchStartIcon),
                  ),
                ),
                child: EasyTextWidget(
                  text: index.toString(),
                  textColor: kWhiteColor,
                  fontSize: kFontSize12x,
                ),
              ),
              const SizedBox(width: kSP10x),
              EasyTextWidget(
                text: title,
                fontWeight: FontWeight.w600,
                maxLines: 1,
              ),
              const Spacer(),
              EasyTextWidget(text: updateAt),
              const SizedBox(width: kSP10x),
              GestureDetector(
                onTap: () => onTapSave(),
                child: Icon(
                  Icons.bookmark,
                  color: isSelect ? kAppYellowButtonColor : kAppPrimaryColor,
                ),
              )
            ],
          ),
          const SizedBox(height: kSP5x),
          Row(
            children: [
              const SizedBox(width: kSP30x),
              Flexible(
                child: EasyTextWidget(
                  text: description,
                  maxLines: 2,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
