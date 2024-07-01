import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:csv/csv.dart';
import 'package:store/utils/constants.dart';
import 'package:store/utils/network/service.dart';

class MyInventory extends StatefulWidget {
  const MyInventory({super.key});

  @override
  State<MyInventory> createState() => _MyInventoryState();
}

class _MyInventoryState extends State<MyInventory> {
  Map<String, int> brands = {};
  String? selectedBrandName;
  int? selectedBrandId;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/get-brand'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        brands = {for (var brand in data) brand['name']: brand['id']};
      });
    } else {
      // Handle error
    }
  }

  Future<void> fetchItems() async {
    if (selectedBrandId != null && selectedBrandName != null) {
      final network = NetworkService();
      Map<String, dynamic> body = {
        "brand_id": selectedBrandId,
        "brand_name": selectedBrandName
      };
      final response =
          await network.postWithAuth("/item-inventory", additionalData: body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          items = data.map((item) => item as Map<String, dynamic>).toList();
        });
        //await _downloadFile();
      } else {
        // Handle error
      }
    }
  }

  Future<void> _downloadFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/inventory_items_$selectedBrandName.csv';
    final file = File(path);

    List<List<dynamic>> rows = [
      ['Stock', "Expiry", 'Shelf', 'Quantity', 'Name'], // Headers
    ];

    for (var item in items) {
      rows.add([
        item['stock_quantity'],
        "",
        "${item['shelf_vertical']}${item['shelf_horizontal']}",
        "${item['quantity']} ${item['unit_of_quantity']}",
        item['item_name'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csvData);

    Share.shareFiles([file.path], text: 'Inventory Items');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text('Select Brand'),
              value: selectedBrandName,
              onChanged: (value) {
                setState(() {
                  selectedBrandName = value;
                  selectedBrandId = brands[value];
                });
              },
              items: brands.keys.map((brand) {
                return DropdownMenuItem(
                  value: brand,
                  child: Text(brand),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: fetchItems,
                  child: const Text('Get Items'),
                ),
                ElevatedButton(
                  onPressed: items.isNotEmpty ? _downloadFile : null,
                  child: const Text('Download CSV'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            items.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Shelf')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Name')),
                          ],
                          rows: items.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item['stock_quantity'].toString())),
                              DataCell(Text(
                                  "${item['shelf_vertical'].toString()}${item['shelf_horizontal'].toString()} ")),
                              DataCell(Text(
                                  "${item['quantity'].toString()}  ${item['unit_of_quantity'].toString()} ")),
                              DataCell(Text(item['item_name'] ?? '')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                : const Text('No items to display'),
          ],
        ),
      ),
    );
  }
}
