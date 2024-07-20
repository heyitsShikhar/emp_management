import 'dart:convert';

class Employee {
  final String empId;
  final String name;
  final String carNumber;
  final String phoneNumber;
  final DateTime createdAt;

  Employee({
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

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['empId'],
      name: json['name'],
      carNumber: json['carNumber'],
      phoneNumber: json['phoneNumber'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static Future<Employee> fromQrData(String qrData) async {
    final Map<String, dynamic> json = jsonDecode(qrData);
    return Employee.fromJson(json);
  }
}
