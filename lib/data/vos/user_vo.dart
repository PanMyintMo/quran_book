class UserVO {
  final String id;
  final String name;
  final String email;
  final String password;
  final bool isAdmin;
  final bool isDeleteAccount;
  final DateTime createAt;
  final DateTime updateAt;

  UserVO({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.isAdmin,
    required this.isDeleteAccount,
    required this.createAt,
    required this.updateAt,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) => UserVO(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        password: json['password'],
        isAdmin: json['isAdmin'],
        isDeleteAccount: json['isDeleteAccount'],
        createAt: DateTime.parse(json['createAt']),
        updateAt: DateTime.parse(json['updateAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'isAdmin': isAdmin,
        'isDeleteAccount': isDeleteAccount,
        'createAt': createAt.toIso8601String(),
        'updateAt': updateAt.toIso8601String(),
      };

  UserVO copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    bool? isAdmin,
    bool? isDeleteAccount,
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return UserVO(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isAdmin: isAdmin ?? this.isAdmin,
      isDeleteAccount: isDeleteAccount ?? this.isDeleteAccount,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }
}
