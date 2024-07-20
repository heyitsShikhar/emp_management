import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';
import 'user_details_page.dart';
import '../shared/user.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;
  StreamSubscription<Barcode>? scanSubscription;

  @override
  void dispose() {
    if (scanSubscription != null) {
      scanSubscription?.cancel();
    }
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pickQrImage();
        },
        child: const Icon(Icons.upload),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    subscribeToScan(controller);
  }

  void subscribeToScan(QRViewController controller) {
    scanSubscription = controller.scannedDataStream.listen((scanData) async {
      if (!scanned) {
        scanned = true;
        await _displayUserDetails(scanData.code);
      }
    });
  }

  Future<void> _displayUserDetails(String? qrData) async {
    if (qrData == null) return;
    User user = await User.fromQrData(qrData);
    await controller?.pauseCamera();
    _navigateToUserDetails(user);
  }

  void _navigateToUserDetails(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPage(user: user),
      ),
    ).then((_) {
      setState(() {
        scanned = false;
      });
      _restartScanning();
    });
  }

  void _restartScanning() {
    if (controller != null) {
      controller!.resumeCamera();
      subscribeToScan(controller!);
    }
  }

  Future<void> _pickQrImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final qrCode = await Scan.parse(pickedFile.path);
      await _displayUserDetails(qrCode);
    }
  }
}
