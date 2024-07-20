import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/employee.dart';

class UserDetailsPage extends StatefulWidget {
  final Employee employee;
  const UserDetailsPage({super.key, required this.employee});

  @override
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends State<UserDetailsPage> {
  late Future<Map<String, dynamic>?> _attendanceFuture;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _fetchAttendance();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<Map<String, dynamic>?> _fetchAttendance() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay =
        DateTime(today.year, today.month, today.day, 23, 59, 59, 999);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('employeeId', isEqualTo: widget.employee.empId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _attendanceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final attendance = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee ID: ${widget.employee.empId}',
                    style: const TextStyle(fontSize: 18)),
                Text('Name: ${widget.employee.name}',
                    style: const TextStyle(fontSize: 18)),
                Text('Car Number: ${widget.employee.carNumber}',
                    style: const TextStyle(fontSize: 18)),
                Text('Phone Number: ${widget.employee.phoneNumber}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                if (_currentUser != null)
                  attendance == null || attendance['checkOut'] != null
                      ? ElevatedButton(
                          onPressed: () => _checkIn(context),
                          child: const Text('Check In'),
                        )
                      : ElevatedButton(
                          onPressed: () => _checkOut(context, attendance),
                          child: const Text('Check Out'),
                        ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _checkIn(BuildContext context) async {
    final attendance = {
      'employeeId': widget.employee.empId,
      'name': widget.employee.name,
      'date': DateTime.now().toIso8601String(),
      'checkIn': DateTime.now().toIso8601String(),
      'checkOut': null,
    };
    await FirebaseFirestore.instance.collection('attendance').add(attendance);

    _checkInSuccessful(context);
  }

  void _checkOut(BuildContext context, Map<String, dynamic> attendance) async {
    final attendanceId = attendance['id'];
    final updatedAttendance = {
      'checkOut': DateTime.now().toIso8601String(),
    };
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(attendanceId)
        .update(updatedAttendance);

    _checkOutSuccessful(context);
  }

  void _checkInSuccessful(BuildContext context) {
    showSnackBarAndPop('Check-in recorded successfully');
  }

  void _checkOutSuccessful(BuildContext context) {
    showSnackBarAndPop('Check-out recorded successfully');
  }

  void showSnackBarAndPop(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }
}
