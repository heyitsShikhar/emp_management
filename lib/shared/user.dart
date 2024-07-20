import 'dart:convert';

class User {
  final String empId;
  final String name;
  final String carNumber;
  final String phoneNumber;
  final DateTime createdAt;

  User({
    required this.empId,
    required this.name,
    required this.carNumber,
    required this.phoneNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'name': name,
      'carNumber': carNumber,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      empId: json['empId'],
      name: json['name'],
      carNumber: json['carNumber'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static Future<User> fromQrData(String qrData) async {
    final Map<String, dynamic> json = jsonDecode(qrData);
    return User.fromJson(json);
  }
}
