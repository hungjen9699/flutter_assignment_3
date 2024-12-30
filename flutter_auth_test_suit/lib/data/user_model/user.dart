import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? image;

  const User(
      {required this.id,
      required this.username,
      this.email,
      this.firstName,
      this.lastName,
      this.gender,
      this.image});

  @override
  List<Object?> get props => [
        id,
        email,
        email,
        firstName,
        lastName,
        gender,
        image,
      ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
    };
  }
}
