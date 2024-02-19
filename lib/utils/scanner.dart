import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  String barcode = 'No barcode scanned yet';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        centerTitle: true,
      ),
      body: BarcodeKeyboardListener(
        onBarcodeScanned: (String code) {
          setState(() {
            barcode = code;
          });
        },
        child: Center(
          child: Text(
            'Scanned Barcode: $barcode',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
