import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:store/main.dart';
import 'package:store/quick-add/add-item.dart';
import 'package:store/utils/constants.dart';

class ListenBarcodePage extends StatefulWidget {
  const ListenBarcodePage({super.key});

  @override
  State<ListenBarcodePage> createState() => _ListenBarcodePageState();
}

class _ListenBarcodePageState extends State<ListenBarcodePage> {
  String _scanBarcodeResult = '-1';
  Future<ItemAdd?> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      setState(() {
        _scanBarcodeResult = barcodeScanRes;
      });
      //_showBarcodeResultDialog(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version';
      // TODO
    }

    if (_scanBarcodeResult != '-1') {
      return _fetchItemDetails(_scanBarcodeResult);
    }

    if (!mounted) {
      return null;
    }
    return null;
  }

  Future<ItemAdd?> _fetchItemDetails(String barcode) async {
    if (barcode != '-1') {
      var url = Uri.parse('$baseUrl/item-add-stock');

      if (barcode.isEmpty) {
        throw Exception('(ItemDetailApiClient) Parameters are not valid');
      }

      var bodyParams = {'barcode': barcode, 'store_id': 1};
      var headers = {'Content-Type': 'application/json'};

      print("Body Params $bodyParams");

      try {
        http.Response response = await http.post(url,
            headers: headers, body: json.encode(bodyParams));

        if (response.statusCode == 200) {
          final dynamic jsonData = json.decode(response.body);
          print(response.body);

          return ItemAdd.fromJson(jsonData);
        } else {
          print(response.body);
        }
      } catch (e) {
        print("Exception $e");
        throw Exception(e);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to MyHomePage using Navigator.push
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          },
        ),
        title: const Text(''), // Optional: if you want a title
      ),
      body: BarcodeKeyboardListener(
        onBarcodeScanned: (String code) async {
          _fetchItemDetails(code).then(
            (value) => {
              if (value != null)
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddItemScreen(item: value)),
                  ),
                }
            },
          );
          // Close the listening dialog
          // Set the barcode in your state, if needed
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Listening To Scanner',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator()
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: MediaQuery.of(context).size.height * 0.22,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  scanBarcode().then(
                    (value) => {
                      if (value != null)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddItemScreen(item: value)),
                          ),
                        }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 108, 55, 255),

                  padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20), // Increase padding inside the button
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Phone Scan',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.01,
                    ),
                    const Icon(
                      Icons.phone_android_outlined,
                      color: Colors.white,
                      size: 35,
                    )
                  ],
                ),
              ),
            ),
            /*
            SizedBox(
              width: MediaQuery.of(context).size.height * 0.01,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  scanBarcode().then(
                    (value) => {
                      if (value != null)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddItemScreen(item: value)),
                          ),
                        }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 108, 55, 255),

                  padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20), // Increase padding inside the button
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_outlined,
                      color: Colors.white,
                      size: 35,
                    )
                  ],
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}
