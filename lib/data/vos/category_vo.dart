class CategoryVO {
  final String id;
  final String image;
  final String name;
  final String subtitle;
  final int totalBookCount;
  final DateTime createAt;
  final DateTime updateAt;

  CategoryVO({
    required this.id,
    required this.image,
    required this.name,
    required this.subtitle,
    required this.totalBookCount,
    required this.createAt,
    required this.updateAt,
  });

  factory CategoryVO.fromJson(Map<String, dynamic> json) => CategoryVO(
        id: json['id'],
        image: json['image'],
        name: json['name'],
        subtitle: json['subtitle'],
        totalBookCount: json['totalBookCount'],
        createAt: DateTime.parse(json['createAt']),
        updateAt: DateTime.parse(json['updateAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'name': name,
        'subtitle': subtitle,
        'totalBookCount': totalBookCount,
        'createAt': createAt.toIso8601String(),
        'updateAt': updateAt.toIso8601String(),
      };
}
