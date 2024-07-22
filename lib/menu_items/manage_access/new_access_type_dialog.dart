import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gov_qr_emp/utilities/constants.dart';
import 'package:gov_qr_emp/utilities/show_message_alert.dart';
import 'multi_select_chip.dart';

void showAddAccessDialog(
  BuildContext context,
  FirebaseFirestore firestore,
  TextEditingController accessTypeController,
  List<String> selectedPermissions,
  Function() onAccessAdded,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 450),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: accessTypeController,
                      decoration:
                          const InputDecoration(labelText: 'Access Type'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: MultiSelectChip(
                        items: accessPermissions,
                        onSelectionChanged: (selectedList) {
                          selectedPermissions.clear();
                          selectedPermissions.addAll(selectedList);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final accessType = accessTypeController.text;
                  if (accessType.isNotEmpty && selectedPermissions.isNotEmpty) {
                    final newAccess = {
                      'accessType': accessType,
                      'permissions': selectedPermissions,
                    };
                    await firestore.collection('AccessUsers').add(newAccess);
                    onAccessAdded();
                    Navigator.pop(context);
                  } else {
                    showMessageAlert(context, 'Please fill all fields');
                  }
                },
                child: const Text('Add Access'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
