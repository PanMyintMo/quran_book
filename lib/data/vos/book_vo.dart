import 'package:quran_book/data/vos/audio_vo.dart';
import 'package:quran_book/data/vos/category_vo.dart';
import 'package:quran_book/data/vos/pdf_vo.dart';
import 'package:quran_book/data/vos/user_vo.dart';

class BookVO {
  final String id;
  final String name;
  final String overview;
  final String author;
  final String image;
  final PdfVO pdf;
  final AudioVO? audio;
  final CategoryVO category;
  final Map<String, String> pages;
  final List<UserVO> readBy;
  final DateTime createAt;
  final DateTime updateAt;
  final List<String> userIDOfBookMark;

  BookVO({
    required this.id,
    required this.name,
    required this.overview,
    required this.author,
    required this.image,
    required this.pdf,
    this.audio,
    required this.category,
    required this.pages,
    required this.readBy,
    required this.createAt,
    required this.updateAt,
    required this.userIDOfBookMark,
  });

  factory BookVO.fromJson(Map<String, dynamic> json) {
    final originalPDFMap = json['pdf'];
    final Map<String, dynamic> convertedPDFMap = Map.from(originalPDFMap as Map);

    final originalAudioMap = json['audio'];
    final Map<String, dynamic> convertedAudioMap = Map.from(originalAudioMap as Map);

    final originalCategoryMap = json['category'];
    final Map<String, dynamic> convertedCategoryMap = Map.from(originalCategoryMap as Map);

    return BookVO(
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      author: json['author'],
      image: json['image'],
      pdf: PdfVO.fromJson(convertedPDFMap),
      audio: json['audio'] != null ? AudioVO.fromJson(convertedAudioMap) : null,
      category: CategoryVO.fromJson(convertedCategoryMap),
      pages: Map<String, String>.from(json['pages'] ?? {}),
      readBy: (json['readBy'] as List<dynamic>?)?.map((e) => UserVO.fromJson(e)).toList() ?? [],
      createAt: DateTime.parse(json['createAt']),
      updateAt: DateTime.parse(json['updateAt']),
      userIDOfBookMark: (json['userIDOfBookMark'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'overview': overview,
        'author': author,
        'image': image,
        'pdf': pdf.toJson(),
        'audio': audio?.toJson(),
        'category': category.toJson(),
        'pages': pages,
        'readBy': readBy.map((e) => e.toJson()).toList(),
        'createAt': createAt.toIso8601String(),
        'updateAt': updateAt.toIso8601String(),
        'userIDOfBookMark': userIDOfBookMark,
      };
}
