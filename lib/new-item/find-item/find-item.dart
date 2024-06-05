// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:store/main.dart';
import 'package:store/new-item/add-item/add-item.dart';
import 'package:store/new-item/finance/finance.dart';
import 'package:store/store/item/view.dart';
import 'package:store/utils/network/service.dart';

class FindItem extends StatefulWidget {
  const FindItem({super.key});

  @override
  State<FindItem> createState() => _FindItemState();
}

class _FindItemState extends State<FindItem> {
  List<ItemFind> _items = [];

  Future<void> searchItems(String value) async {
    Map<String, dynamic> data = {
      "name": value,
    };

    final networkService = NetworkService();
    final response = await networkService.postWithAuth('/manager-search-item',
        additionalData: data);

    print("Response Search: ${response.body}");
    if (response.statusCode == 200 && response.body != "null") {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        _items = jsonResponse.map((item) => ItemFind.fromJson(item)).toList();
      });
    } else {
      setState(() {
        _items = [];
      });
      print("Response body is null or empty");
    }
  }

  Future<void> scanMobileBarcode(int itemId) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (barcodeScanRes != '-1') {
        updateBarcode(barcodeScanRes, itemId);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version';
      // TODO
    }

    if (!mounted) return;
  }

  Future<void> updateBarcode(String barcode, int itemId) async {
    Map<String, dynamic> data = {
      "barcode": barcode,
      "item_id": itemId,
    };

    final networkService = NetworkService();
    try {
      final response = await networkService
          .postWithAuth('/manager-update-item-barcode', additionalData: data);
      if (response.statusCode == 200) {
        // Assuming 'successImage' is a widget or a function returning a widget showing the success state
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Update Successful!'),
                  Text(response.body),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle non-200 responses
        _showErrorDialog();
      }
    } catch (e) {
      // Handle exceptions from the request or JSON parsing
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update the barcode. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextField(
            decoration: const InputDecoration(
              hintText: 'Search For Item',
              hintStyle: TextStyle(color: Colors.black),
            ),
            onChanged: (value) => searchItems(value),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              );
            },
          )),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _items[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.greenAccent,
            ),
            child: ListTile(
              title: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewItemPage(
                      itemId: item.id,
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.size} ${item.unitOfQuantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(item.description),
                ],
              ),
              leading: item.images.isNotEmpty
                  ? Image.network(
                      item.images.first,
                      width: 50,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('No Image');
                      },
                    )
                  : const Text('No Image'),
              tileColor: Colors.white,
              trailing: Wrap(
                spacing: 5, // Space between containers horizontally
                runSpacing: 5, // Space between containers vertically
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemFinance(
                              itemId: item.id,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Finance",
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () => scanMobileBarcode(item.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: item.barcode.isEmpty
                                ? Colors.white
                                : Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Barcode",
                            style: TextStyle(
                                color: item.barcode.isEmpty
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      /*
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "  Image  ",
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
                      ),
                      */
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 25.0, top: 10, left: 20, right: 20),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddItem(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Add New Item',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class ItemFind {
  final int id;
  final String name;
  final String description;
  final int size;
  final String unitOfQuantity;
  final String brandName;
  final String barcode;
  final int brandId;
  final double mrpPrice;
  final List<String> images;

  ItemFind({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    required this.unitOfQuantity,
    required this.brandName,
    required this.brandId,
    required this.mrpPrice,
    required this.images,
    required this.barcode,
  });

  factory ItemFind.fromJson(Map<String, dynamic> json) {
    // Handle description field which could be a map or string
    String description = '';
    if (json['description'] is Map) {
      description = json['description']['String'] ?? '';
    } else if (json['description'] is String) {
      description = json['description'];
    }

    return ItemFind(
      id: json['id'],
      name: json['name'],
      description: description,
      size: json['size'],
      unitOfQuantity: json['unit_of_quantity'],
      brandName: json['brand_name'],
      brandId: json['brand_id'],
      mrpPrice: json['mrp_price']?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      barcode: json['barcode'] ?? '',
    );
  }
}
