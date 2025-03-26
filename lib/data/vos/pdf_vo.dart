class PdfVO {
  final String id;
  final String name;
  final String image;
  final String url;
  final DateTime createAt;
  final DateTime updateAt;

  PdfVO({
    required this.id,
    required this.name,
    required this.image,
    required this.url,
    required this.createAt,
    required this.updateAt,
  });

  factory PdfVO.fromJson(Map<String, dynamic> json) => PdfVO(
        id: json['id'],
        name: json['name'],
        image: json['image'],
        url: json['url'],
        createAt: DateTime.parse(json['createAt']),
        updateAt: DateTime.parse(json['updateAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'url': url,
        'createAt': createAt.toIso8601String(),
        'updateAt': updateAt.toIso8601String(),
      };
}
