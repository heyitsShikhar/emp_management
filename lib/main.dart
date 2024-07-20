import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'qr_generator/employee_form.dart';
import 'qr_scanner/qr_scanner.dart';
import 'menu_items/view_all_employees.dart';
import 'menu_items/view_attendance.dart';
import 'login_module/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EmployeeQrApp());
}

class EmployeeQrApp extends StatelessWidget {
  const EmployeeQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee QR Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  QRViewController? _qrViewController;

  void _setQRViewController(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
  }

  void _pauseQRScanner() {
    _qrViewController?.pauseCamera();
  }

  void _resumeQRScanner() {
    _qrViewController?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _pauseQRScanner();
              navigateToLoginPage();
            },
          ),
        ],
      ),
      body: QRScanner(onQRViewCreated: _setQRViewController),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
              ),
              child: const Text(
                'Power Grid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('All employees'),
              onTap: () {
                _pauseQRScanner();
                navigateToViewAllEmployees();
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Attendance'),
              onTap: () {
                _pauseQRScanner();
                navigateToAttendance();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Employee'),
              onTap: () {
                _pauseQRScanner();
                navigateToEmployeeForm();
              },
            ),
          ],
        ),
      ),
    );
  }

  void navigateToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) => _resumeQRScanner());
  }

  void navigateToViewAllEmployees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewAllEmployeesPage()),
    ).then((_) => _resumeQRScanner());
  }

  void navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewAttendancePage()),
    ).then((_) => _resumeQRScanner());
  }

  void navigateToEmployeeForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeForm()),
    ).then((_) => _resumeQRScanner());
  }
}
