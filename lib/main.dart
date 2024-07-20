import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: navigateToLoginPage,
          ),
        ],
      ),
      body: const QRScanner(),
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
              onTap: navigateToViewAllEmployees,
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Attendance'),
              onTap: navigateToAttendance,
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Employee'),
              onTap: navigateToEmployeeForm,
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
    );
  }

  void navigateToViewAllEmployees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewAllEmployeesPage()),
    );
  }

  void navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewAttendancePage()),
    );
  }

  void navigateToEmployeeForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeForm()),
    );
  }
}
