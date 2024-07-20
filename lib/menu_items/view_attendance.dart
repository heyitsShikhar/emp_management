import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewAttendancePage extends StatelessWidget {
  const ViewAttendancePage({super.key});

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAllAttendance() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .orderBy('checkIn', descending: true)
        .get();

    final attendanceMap = <String, List<Map<String, dynamic>>>{};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final checkInTime = DateTime.parse(data['checkIn']);
      final dateString = DateFormat('yyyy-MM-dd').format(checkInTime);
      if (!attendanceMap.containsKey(dateString)) {
        attendanceMap[dateString] = [];
      }
      attendanceMap[dateString]?.add({
        ...data,
        'id': doc.id,
      });
    }

    return attendanceMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _fetchAllAttendance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final attendanceMap = snapshot.data ?? {};

          if (attendanceMap.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          return ListView.builder(
            itemCount: attendanceMap.length,
            itemBuilder: (context, index) {
              final date = attendanceMap.keys.elementAt(index);
              final attendanceList = attendanceMap[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                    child: Text(
                      date == DateFormat('yyyy-MM-dd').format(DateTime.now())
                          ? '$date (Today)'
                          : date,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...attendanceList.map((attendance) {
                    final checkInTime = DateTime.parse(attendance['checkIn']);
                    final checkOutTime = attendance['checkOut'] != null
                        ? DateTime.parse(attendance['checkOut'])
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${attendance['employeeId']}:  ${attendance['name']}'),
                            const SizedBox(height: 12),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              DateFormat('kk:mm').format(checkInTime),
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              checkOutTime != null
                                  ? DateFormat('kk:mm').format(checkOutTime)
                                  : '------',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
