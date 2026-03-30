// import 'package:flutter/material.dart';
// import 'package:quran_book/data/vos/category_vo.dart';
// import 'package:quran_book/pages/main_page/book_list_from_category_page.dart';
// import 'package:quran_book/resources/dimens.dart';
// import 'package:quran_book/widgets/cache_network_image_widget.dart';
// import 'package:quran_book/widgets/easy_text_widget.dart';

// /// Category header plus the books in that category.
// class CategoryDetailPage extends StatelessWidget {
//   const CategoryDetailPage({super.key, required this.category});

//   final CategoryVO category;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   centerTitle: true,
//       //   title: EasyTextWidget(
//       //     text: category.name,
//       //     fontWeight: FontWeight.w600,
//       //     maxLines: 1,
//       //   ),
//       // ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Column(
//             children: [
//               CacheNetworkImageWidget(
//                 imageUrl: category.image,
//                 width: 120,
//                 height: 120,
//                 fit: BoxFit.cover,
//                 radius: kSP10x,
//               ),
//               const SizedBox(height: kSP15x),
//               if (category.subtitle.isNotEmpty)
//                 EasyTextWidget(
//                   text: category.subtitle,
//                   textAlign: TextAlign.center,
//                   fontSize: kFontSize14x,
//                   textColor: Colors.black54,
//                   maxLines: 4,
//                 ),
//               const SizedBox(height: kSP10x),
//               EasyTextWidget(
//                 text:
//                     '${category.totalBookCount} ${category.totalBookCount == 1 ? 'book' : 'books'}',
//                 fontSize: kFontSize12x,
//                 fontWeight: FontWeight.w600,
//               ),
//             ],
//           ),
//           const Divider(height: 1),
//           Expanded(
//             child: BookListFromCategoryPage(
//               category: category,
//               embedInParent: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
