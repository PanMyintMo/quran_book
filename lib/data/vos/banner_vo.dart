class BannerVO {
  final String id;
  final String image;
  final DateTime createAt;
  final DateTime updateAt;

  BannerVO({
    required this.id,
    required this.image,
    required this.createAt,
    required this.updateAt,
  });

  factory BannerVO.fromJson(Map<String, dynamic> json) => BannerVO(
        id: json['id'],
        image: json['image'],
        createAt: DateTime.parse(json['createAt']),
        updateAt: DateTime.parse(json['updateAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'createAt': createAt.toIso8601String(),
        'updateAt': updateAt.toIso8601String(),
      };
}
