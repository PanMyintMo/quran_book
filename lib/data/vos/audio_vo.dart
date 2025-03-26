class AudioVO {
  final String id;
  final String name;
  final String url;
  final DateTime createAt;
  final DateTime updateAt;

  AudioVO({
    required this.id,
    required this.name,
    required this.url,
    required this.createAt,
    required this.updateAt,
  });

  factory AudioVO.fromJson(Map<String, dynamic> json) => AudioVO(
        id: json['id'],
        name: json['name'],
        url: json['url'],
        createAt: DateTime.parse(json['createAt']),
        updateAt: DateTime.parse(json['updateAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'createAt': createAt.toIso8601String(),
        'updateAt': updateAt.toIso8601String(),
      };
}
