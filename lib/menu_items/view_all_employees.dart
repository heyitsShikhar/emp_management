import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../shared/user.dart';

class ViewAllEmployeesPage extends StatelessWidget {
  const ViewAllEmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Employees'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('employees')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;
          if (data.size == 0) {
            return const Center(
                child: Text("List of all employees will be listed here"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: data.size,
            itemBuilder: (context, index) {
              final doc = data.docs[index];
              final user = User.fromJson(doc.data() as Map<String, dynamic>);
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: Text('ID: ${user.empId}'),
                  subtitle: Text(
                      'Name: ${user.name}\nCar Number: ${user.carNumber}\nPhone Number: ${user.phoneNumber}\nCreated on: ${DateFormat('dd/MM/yyyy  -  kk:mm:ss').format(user.createdAt)}'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
