// models/user_model.dart
class UserModel {
  final String? id;
  final String name;
  String? password;
  final String? token;
  // final DateTime? createdAt;
  // final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.name,
    this.password,
    this.token,
    // this.createdAt,
    // this.updatedAt,
  });

  // تحويل من JSON إلى Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['username'] ?? json['name'] ?? '',
      password: json['password'],
      token: json['token'],
      // createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      // updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // تحويل من Object إلى JSON لتسجيل الدخول
  Map<String, dynamic> toJson() {
    return {
      'username': name,
      'password': password,
    };
  }

  // تحويل JSON كامل يتضمن جميع البيانات
  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'username': name,
      'password': password,
      'token': token,
      // 'created_at': createdAt?.toIso8601String(),
      // 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // إنشاء نسخة جديدة مع تعديل بعض القيم
  UserModel copyWith({
    String? id,
    String? name,
    String? password,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      token: token ?? this.token,
      // createdAt: createdAt ?? this.createdAt,
      // updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, token: $token}';
  }
}
