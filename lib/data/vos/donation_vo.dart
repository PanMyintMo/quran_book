class DonationVO {
  final String id;
  final String image;
  final String name;
  final String accNumber;
  final DateTime createAt;
  final DateTime updateAt;

  DonationVO({
    required this.id,
    required this.image,
    required this.name,
    required this.accNumber,
    required this.createAt,
    required this.updateAt,
  });

  factory DonationVO.fromJson(Map<String, dynamic> json) => DonationVO(
        id: json['id'],
        image: json['image'],
        name: json['name'],
        accNumber: json['accNumber'],
        createAt: DateTime.parse(json['createAt']),
        updateAt: DateTime.parse(json['updateAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'name': name,
        'accNumber': accNumber,
        'createAt': createAt.toIso8601String(),
        'updateAt': updateAt.toIso8601String(),
      };
}
