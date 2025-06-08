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


// // مودل للاستجابة من API
// class ApiResponse<T> {
//   final bool success;
//   final String message;
//   final T? data;
//   final List<String>? errors;

//   ApiResponse({
//     required this.success,
//     required this.message,
//     this.data,
//     this.errors,
//   });

//   factory ApiResponse.fromJson(
//       Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
//     return ApiResponse<T>(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
//       errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
//     );
//   }
// }




// // lib/models/user_model.dart

// class UserModel {
//   int? id;
//   String? name;
//   String? email;
//   String? password;
//   String? passwordConfirmation;
//   String? emailVerifiedAt;
//   String? verificationCode;
//   bool? isVerified;
//   String? createdAt;
//   String? updatedAt;

//   UserModel({
//     this.id,
//     this.name,
//     this.email,
//     this.password,
//     this.passwordConfirmation,
//     this.emailVerifiedAt,
//     this.verificationCode,
//     this.isVerified,
//     this.createdAt,
//     this.updatedAt,
//   });

//   UserModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     email = json['email'];
//     password = json['password'];
//     passwordConfirmation = json['password_confirmation'];
//     emailVerifiedAt = json['email_verified_at'];
//     verificationCode = json['verification_code'];
//     isVerified = json['is_verified'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
    
//     if (id != null) data['id'] = id;
//     if (name != null) data['name'] = name;
//     if (email != null) data['email'] = email;
//     if (password != null) data['password'] = password;
//     if (passwordConfirmation != null) data['password_confirmation'] = passwordConfirmation;
//     if (emailVerifiedAt != null) data['email_verified_at'] = emailVerifiedAt;
//     if (verificationCode != null) data['verification_code'] = verificationCode;
//     if (isVerified != null) data['is_verified'] = isVerified;
//     if (createdAt != null) data['created_at'] = createdAt;
//     if (updatedAt != null) data['updated_at'] = updatedAt;
    
//     return data;
//   }

//   // دالة للحصول على اسم المستخدم للعرض
//   String getDisplayName() {
//     return name ?? email?.split('@')[0] ?? 'مستخدم';
//   }

//   // التحقق من صحة البريد الإلكتروني
//   bool get isEmailVerified => isVerified == true || emailVerifiedAt != null;
// }