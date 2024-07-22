import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gov_qr_emp/utilities/access_permissions_enum.dart';
import 'package:gov_qr_emp/utilities/show_message_alert.dart';
import 'package:gov_qr_emp/utilities/show_snackbar.dart';
import 'multi_select_chip.dart';

void showUpdateAccessDialog(
  BuildContext context,
  String documentId,
  Map<String, dynamic> data,
  List<AccessPermission> permissions,
  FirebaseFirestore firestore,
) {
  final List<String> initialPermissions =
      List<String>.from(data['permissions'] ?? []);
  final List<AccessPermission> selectedPermissions = initialPermissions
      .map((name) => AccessPermissionExtension.fromName(name))
      .whereType<AccessPermission>()
      .toList();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MultiSelectChip<AccessPermission>(
              items: permissions,
              itemLabelBuilder: (permission) => permission.name,
              initialSelectedItems: selectedPermissions,
              onSelectionChanged: (selectedList) {
                selectedPermissions.clear();
                selectedPermissions.addAll(selectedList);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (selectedPermissions.isNotEmpty) {
                    firestore
                        .collection('AccessUsers')
                        .doc(documentId)
                        .update({
                      'permissions': selectedPermissions.map((e) => e.name).toList()
                    });
                    Navigator.pop(context);
                    showSnackbar(context, 'Permissions updated successfully');
                  } else {
                    showMessageAlert(context, 'Please select at least one permission');
                  }
                },
                child: const Text('Update Permissions'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
