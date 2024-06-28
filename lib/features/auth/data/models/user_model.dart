import 'package:flutter_bloc_clean_architecture_blog_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.name,
  });

  // Factory constructor to create a UserModel instance from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
    );
  }

  // Method to create a copy of the current UserModel with optional new values.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}
