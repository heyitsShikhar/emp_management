import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gov_qr_emp/menu_items/manage_access/manage_access_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'menu_items/employee_form.dart';
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
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee QR Scanner'),
        actions: _user == null
            ? [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    _pauseQRScanner();
                    navigateToLoginPage();
                  },
                ),
              ]
            : null,
      ),
      body: QRScanner(onQRViewCreated: _setQRViewController),
      drawer: _user != null ? _buildDrawer(context) : null,
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
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
            leading: const Icon(Icons.list),
            title: const Text('Attendance'),
            onTap: () {
              _pauseQRScanner();
              navigateToAttendance();
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Manage Access'),
            onTap: () {
              _pauseQRScanner();
              navigateToManageAccess();
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('All Employees'),
            onTap: () {
              _pauseQRScanner();
              navigateToViewAllEmployees();
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              await _logout();
              showSnackBar('Logged out successfully');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  void navigateToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) {
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
      });
      _resumeQRScanner();
    });
  }

  void navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewAttendancePage()),
    ).then((_) => _resumeQRScanner());
  }

  void navigateToManageAccess() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageAccessPage()),
    ).then((_) => _resumeQRScanner());
  }

  void navigateToViewAllEmployees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewAllEmployeesPage()),
    ).then((_) => _resumeQRScanner());
  }

  void navigateToEmployeeForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeForm()),
    ).then((_) => _resumeQRScanner());
  }
}
