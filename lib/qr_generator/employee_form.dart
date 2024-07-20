import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../shared/employee.dart';

class EmployeeForm extends StatefulWidget {
  const EmployeeForm({super.key});

  @override
  EmployeeFormState createState() => EmployeeFormState();
}

class EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _empIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _carNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _qrData;
  String? empId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextFormField(
                controller: _empIdController,
                labelText: 'Emp ID',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Emp ID';
                  } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                    return 'Employee ID must be of 8 digits';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Name';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _carNumberController,
                labelText: 'Car Number',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter Car Number'
                    : null,
              ),
              _buildTextFormField(
                controller: _phoneNumberController,
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Phone Number';
                  } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Phone Number must contain only digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: _generateQrCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Generate QR Code')),
              const SizedBox(height: 20),
              _qrData == null
                  ? Container()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _qrData != null ? _downloadQrCode : null,
                          child: const Icon(Icons.download),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _generateQrCode() async {
    if (_formKey.currentState!.validate()) {
      Employee employee = Employee(
        empId: _empIdController.text,
        name: _nameController.text,
        carNumber: _carNumberController.text,
        phoneNumber: _phoneNumberController.text,
        createdAt: DateTime.now(),
      );

      await checkDuplicateEmpId(employee);
    }
  }

  Future<void> checkDuplicateEmpId(Employee employee) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('empId', isEqualTo: employee.empId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      showDuplicateAlert();
    } else {
      saveToFirestore(employee);
      displayQrCode(employee);
      clearAllFields();
      dismissKeyboard();
    }
  }

  void showDuplicateAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Duplicate Employee ID'),
          content: const Text('An employee with this ID already exists.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadQrCode() async {
    if (_qrData == null) return;
    final qrPainter = QrPainter(
      data: _qrData!,
      version: QrVersions.auto,
      gapless: false,
      emptyColor: Colors.white,
    );
    final directory = Directory('/storage/emulated/0/Download/PowerGrid');
    if (!await directory.exists()) {
      directory.create(recursive: true);
    }
    final path = directory.path;
    final file = File('$path/$empId.png');
    final qrImage = await qrPainter.toImage(200);
    final byteData = await qrImage.toByteData(format: ImageByteFormat.png);
    await file.writeAsBytes(byteData!.buffer.asUint8List());
    showSnackBar('QR Code saved to ${file.path}');
  }

  void saveToFirestore(Employee employee) async {
    await FirebaseFirestore.instance
        .collection('employees')
        .add(employee.toJson());
  }

  void displayQrCode(Employee employee) {
    setState(() {
      _qrData = jsonEncode(employee.toJson());
    });
  }

  void clearAllFields() {
    empId = _empIdController.text;
    _empIdController.clear();
    _nameController.clear();
    _carNumberController.clear();
    _phoneNumberController.clear();
  }

  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _empIdController.dispose();
    _nameController.dispose();
    _carNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
