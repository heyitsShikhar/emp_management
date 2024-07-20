class Attendance {
  final String employeeId;
  final String name;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;

  Attendance({
    required this.employeeId,
    required this.name,
    required this.date,
    this.checkIn,
    this.checkOut,
  });

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
    };
  }

  static Attendance fromJson(Map<String, dynamic> json) {
    return Attendance(
      employeeId: json['employeeId'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
    );
  }
}
