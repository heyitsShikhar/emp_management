import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gov_qr_emp/utilities/show_message_alert.dart';
import 'package:gov_qr_emp/utilities/show_snackbar.dart';

void showUpdateUsersDialog(BuildContext context, String documentId,
    Map<String, dynamic> data, FirebaseAuth auth, FirebaseFirestore firestore) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final emails = List<String>.from(data['emails'] ?? []);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update Users'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text;
                final password = passwordController.text;
                if (email.isNotEmpty && password.isNotEmpty) {
                  final currentUser = auth.currentUser;
                  final currentEmail = currentUser?.email;
                  try {
                    await auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    emails.add(email);
                    await firestore
                        .collection('AccessUsers')
                        .doc(documentId)
                        .update({'emails': emails});
                    await auth.signInWithEmailAndPassword(
                      email: currentEmail ?? '',
                      password: 'test@123',
                    );
                    Navigator.pop(context);
                    showSnackbar(context, 'User added successfully');
                  } catch (e) {
                    showMessageAlert(context, 'Failed to add user');
                  }
                } else {
                  showMessageAlert(context, 'Please enter email and password');
                }
              },
              child: const Text('Add Email'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: emails.map((email) {
                return Chip(
                  label: Text(email),
                  onDeleted: () async {
                    emails.remove(email);
                    await firestore
                        .collection('AccessUsers')
                        .doc(documentId)
                        .update({'emails': emails});
                    showSnackbar(context, 'User removed successfully');
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    },
  );
}

void showAdminPasswordDialog(
    BuildContext context, Function(String) onPasswordEntered) {
  final TextEditingController adminPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Admin Authentication'),
        content: TextField(
          controller: adminPasswordController,
          decoration: const InputDecoration(labelText: 'Admin Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final adminPassword = adminPasswordController.text;
              if (adminPassword.isNotEmpty) {
                Navigator.pop(context);
                onPasswordEntered(adminPassword);
              } else {
                showMessageAlert(context, 'Please enter the admin password');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}
