import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gov_qr_emp/menu_items/manage_access/manage_access_page.dart';
import 'package:gov_qr_emp/menu_items/view_all_employees.dart';
import 'package:gov_qr_emp/menu_items/view_attendance.dart';
import 'package:gov_qr_emp/menu_items/employee_form.dart';
import 'package:gov_qr_emp/qr_scanner/qr_scanner.dart';
import 'package:gov_qr_emp/login_module/login_page.dart';
import 'package:gov_qr_emp/utilities/show_message_alert.dart';
import 'package:gov_qr_emp/utilities/show_snackbar.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'utilities/access_permissions_enum.dart';

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
  List<AccessPermission> _userPermissions = [];

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
        if (_user != null) {
          _fetchUserPermissions();
        } else {
          _userPermissions = [];
        }
      });
    });
  }

  Future<void> _fetchUserPermissions() async {
    if (_user == null) return;
    if (_user!.email == 'test_admin@gmail.com') {
      setState(() {
        _userPermissions = AccessPermission.values;
      });
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('AccessUsers')
          .where('emails', arrayContains: _user!.email)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        final permissions = List<String>.from(data['permissions'] ?? []);
        setState(() {
          _userPermissions = permissions
              .map((name) => AccessPermissionExtension.fromName(name))
              .whereType<AccessPermission>()
              .toList();
        });
      } else {
        setState(() {
          _userPermissions = [];
        });
      }
    } catch (e) {
      showMessageAlert(context, 'Failed to fetch user permissions');
    }
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
          if (_userPermissions.contains(AccessPermission.viewAttendance))
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Attendance'),
              onTap: () {
                _pauseQRScanner();
                navigateToAttendance();
              },
            ),
            if (_userPermissions.contains(AccessPermission.manageAccess))
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Manage Access'),
              onTap: () {
                _pauseQRScanner();
                navigateToManageAccess();
              },
            ),
          if (_userPermissions.contains(AccessPermission.viewAllEmployees))
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('All Employees'),
              onTap: () {
                _pauseQRScanner();
                navigateToViewAllEmployees();
              },
            ),
          if (_userPermissions.contains(AccessPermission.addNewEmployees))
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
              showSnackbar(context, 'Logged out successfully');
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

  void navigateToLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    ).then((_) {
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
      });
      _fetchUserPermissions();
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
