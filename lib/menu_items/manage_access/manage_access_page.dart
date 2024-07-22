import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gov_qr_emp/utilities/constants.dart';
import 'package:gov_qr_emp/utilities/show_snackbar.dart';
import 'update_users_dialog.dart';
import 'update_access_dialog.dart';
import 'new_access_type_dialog.dart';

class ManageAccessPage extends StatefulWidget {
  const ManageAccessPage({super.key});

  @override
  ManageAccessPageState createState() => ManageAccessPageState();
}

class ManageAccessPageState extends State<ManageAccessPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _accessTypeController = TextEditingController();
  List<String> _selectedPermissions = [];

  @override
  void initState() {
    super.initState();
  }

  void _showEditDialog(String documentId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Access'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showUpdateUsersDialog(
                      context, documentId, data, _auth, _firestore);
                },
                child: const Text('Update Users'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showUpdateAccessDialog(
                      context, documentId, data, accessPermissions, _firestore);
                },
                child: const Text('Update Access'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Access'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showAddAccessDialog(
                context,
                _firestore,
                _accessTypeController,
                _selectedPermissions,
                () {
                  showSnackbar(context, 'Access added successfully');
                  setState(() {
                    _accessTypeController.clear();
                    _selectedPermissions = [];
                  });
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('AccessUsers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final accessUsers = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: accessUsers.length,
            itemBuilder: (context, index) {
              final data = accessUsers[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(data['accessType']),
                  subtitle: Text(
                    'Emails: ${data['emails']?.join(', ') ?? '-----'}\n'
                    'Permissions: ${data['permissions']?.join(', ') ?? '-----'}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(accessUsers[index].id, data),
                  ),
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
