import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  final ObjectId? id;
  final String uid;
  final String password;
  final String teamId;
  final String role;

  UserModel({
    this.id,
    required this.uid,
    required this.password,
    required this.teamId,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'uid': uid,
      'password': password,
      'teamId': teamId,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] as ObjectId,
      uid: map['uid'] as String,
      password: map['password'] as String,
      teamId: map['teamId'] as String,
      role: map['role'] as String,
    );
  }
}
