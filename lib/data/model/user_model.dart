import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.createdAt,
    this.updatedAt,
    required this.isDeleted,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Handle isDeleted - can be bool or int (1/0)
    bool isDeletedValue = false;
    if (map['isDeleted'] is bool) {
      isDeletedValue = map['isDeleted'] as bool;
    } else if (map['isDeleted'] == 1) {
      isDeletedValue = true;
    }

    // Handle createdAt - can be Timestamp (from Firestore) or int (milliseconds from GetStorage)
    DateTime? createdAtValue;
    if (map['createdAt'] is Timestamp) {
      createdAtValue = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is int) {
      createdAtValue = DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int,
      );
    }

    // Handle updatedAt - can be Timestamp (from Firestore) or int (milliseconds from GetStorage)
    DateTime? updatedAtValue;
    if (map['updatedAt'] is Timestamp) {
      updatedAtValue = (map['updatedAt'] as Timestamp).toDate();
    } else if (map['updatedAt'] is int) {
      updatedAtValue = DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] as int,
      );
    }

    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'] ?? '',
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
      isDeleted: isDeletedValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      // Convert DateTime to milliseconds for JSON serialization
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }
}
