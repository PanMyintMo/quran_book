import 'package:flutter/material.dart';
import 'package:quran_book/pages/main_page/book_list_from_category_page.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/pages/main_page/category_detail_page.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/cache_network_image_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

class BookTypesSeeAllPage extends StatefulWidget {
  const BookTypesSeeAllPage({super.key});

  @override
  State<BookTypesSeeAllPage> createState() => _BookTypesSeeAllPageState();
}

class _BookTypesSeeAllPageState extends State<BookTypesSeeAllPage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  List<CategoryVO> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cats = await _firebaseModel.getAllCategories();
      if (mounted) setState(() { _categories = cats; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const EasyTextWidget(
          text: 'Book Types',
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(kSP10x),
              child: GridView.builder(
                itemCount: _categories.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: kSP10x,
                  mainAxisSpacing: kSP10x,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (_, index) {
                  final category = _categories[index];

                  return GestureDetector(
                    onTap: () => context.navigateToNextPage(
                      BookListFromCategoryPage(category: category),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kBoxColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: kSP10x, vertical: kSP5x),
                      child: Row(
                        children: [
                          CacheNetworkImageWidget(
                            radius: kSP5x,
                            imageUrl: category.image,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: kSP10x),
                          Expanded(
                            child: EasyTextWidget(
                              text: category.name,
                              maxLines: 2,
                              fontSize: kFontSize12x,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
