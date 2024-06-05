import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:store/shelf/shelf.dart';
import 'package:store/utils/network/service.dart';

class ShelfHome extends StatefulWidget {
  const ShelfHome({super.key});

  @override
  State<ShelfHome> createState() => _ShelfHomeState();
}

class _ShelfHomeState extends State<ShelfHome> {
  final networkService = NetworkService();
  int? selectedRow;
  String? selectedColumn;

  Future<void> scanMobileBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (barcodeScanRes != '-1') {
        findItem(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version';
      // TODO
    }

    if (!mounted) return;
  }

  Future<void> scanMobileBarcodeRearrange() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (barcodeScanRes != '-1') {
        findItemRearrange(barcodeScanRes);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version';
      // TODO
    }

    if (!mounted) return;
  }

  Future<void> findItemRearrange(String barcode) async {
    //final barcode = "9300607376074";
    final storeId = 1;
    try {
      Map<String, dynamic> data = {
        "store_id": storeId,
        "barcode": barcode,
      };
      final response = await networkService.postWithAuth('/manager-find-item',
          additionalData: data);

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final item = FindItemResponse.fromJson(data);
        selectedColumn = item.shelfVertical;
        selectedRow = item.shelfHorizontal;
        // Show dialog with item details and input fields
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.0)),
                child: Text(
                  item.itemName,
                  textAlign: TextAlign.center,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                            labelText: 'Row',
                            border: OutlineInputBorder(),
                            filled: true),
                        readOnly: true,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            labelText: 'Column',
                            border: OutlineInputBorder(),
                            filled: true),
                        readOnly: true,
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedColumn,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              labelText: 'Column',
                              border: OutlineInputBorder(),
                              filled: true),
                          items: List<String>.from([
                            'A',
                            'B',
                            'C',
                            'D',
                            'E',
                            'F',
                            'G',
                            'H',
                            'R',
                            'Z'
                          ]).map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedColumn = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedRow,
                          decoration: InputDecoration(
                              labelText: 'Row',
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true),
                          items: List.generate(150, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedRow = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                      primary: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      if (selectedRow != null && selectedColumn != null) {
                        // Call assignToShelf with selected values
                        assignToShelf(
                            storeId, barcode, selectedRow!, selectedColumn!);
                      } else {
                        // Handle case where row or column is not selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.white,

                            content: Text(
                              'Please select both row and column',
                              style: TextStyle(color: Colors.black),
                            ),
                            duration: Duration(
                                seconds: 2), // Customize duration as needed
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Handle non-200 responses
        print('Failed to find item: ${response.body}');
      }
    } catch (e) {
      // Handle any errors
      print('Error finding item: $e');
    }
  }

  Future<void> findItem(String barcode) async {
    //final barcode = "9300607376074";
    final storeId = 1;
    try {
      Map<String, dynamic> data = {
        "store_id": storeId,
        "barcode": barcode,
      };
      final response = await networkService.postWithAuth('/manager-find-item',
          additionalData: data);

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final item = FindItemResponse.fromJson(data);
        selectedColumn = item.shelfVertical;
        selectedRow = item.shelfHorizontal;
        // Show dialog with item details and input fields
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.0)),
                child: Text(
                  item.itemName,
                  textAlign: TextAlign.center,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedColumn,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              labelText: 'Column',
                              border: OutlineInputBorder(),
                              filled: true),
                          items: List<String>.from([
                            'A',
                            'B',
                            'C',
                            'D',
                            'E',
                            'F',
                            'G',
                            'H',
                            'R',
                            'Z'
                          ]).map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedColumn = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedRow,
                          decoration: InputDecoration(
                              labelText: 'Row',
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true),
                          items: List.generate(150, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedRow = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                      primary: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      if (selectedRow != null && selectedColumn != null) {
                        // Call assignToShelf with selected values
                        assignToShelf(
                            storeId, barcode, selectedRow!, selectedColumn!);
                      } else {
                        // Handle case where row or column is not selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.white,

                            content: Text(
                              'Please select both row and column',
                              style: TextStyle(color: Colors.black),
                            ),
                            duration: Duration(
                                seconds: 2), // Customize duration as needed
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Handle non-200 responses
        print('Failed to find item: ${response.body}');
      }
    } catch (e) {
      // Handle any errors
      print('Error finding item: $e');
    }
  }

  Future<void> assignToShelf(
      int storeId, String itemBarcode, int horizontal, String vertical) async {
    try {
      Map<String, dynamic> data = {
        "store_id": storeId,
        "item_barcode": itemBarcode,
        "horizontal": horizontal,
        "vertical": vertical,
      };
      final response = await networkService
          .postWithAuth('/manager-assign-item-shelf', additionalData: data);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String message = data['message'];

        // Show success dialog with message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Assignment Successful'),
              content: Text(message),
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
        print('Failed to assign shelf: ${response.body}');
      }
    } catch (e) {
      // Handle any errors
      print('Error assigning shelf: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shelf Home"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            Map<String, dynamic> data = {
                              "store_id": 1,
                            };
                            final networkService = NetworkService();
                            final response = await networkService.postWithAuth(
                                '/manager-init-shelf',
                                additionalData: data);

                            print("Response: ${response.body}");
                            if (response.statusCode == 200) {
                              // Decode the response body

                              final result = json.decode(response.body);

                              // Check if the result is true or false
                              if (result == true) {
                                // Show success dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Success'),
                                      content: const Text(
                                          'Operation was successful.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Dismiss dialog
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // Show failure dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Failure'),
                                      content: const Text('Operation failed.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Dismiss dialog
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {
                              // If the server did not return a 200 OK response,
                              // then throw an exception.
                              throw Exception('Failed to load data');
                            }
                          } catch (e) {}
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded borders
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 0,
                                blurRadius: 20, // Increased shadow blur
                                offset: const Offset(
                                    0, 10), // Increased vertical offset
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Shelf INIT',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              // Navigate to the AllShelf screen
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShelfPage()));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded borders
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 0,
                                blurRadius: 20, // Increased shadow blur
                                offset: const Offset(
                                    0, 10), // Increased vertical offset
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'All Shelf',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => {scanMobileBarcode()},
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded borders
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 0,
                                blurRadius: 20, // Increased shadow blur
                                offset: const Offset(
                                    0, 10), // Increased vertical offset
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Assign Item',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          scanMobileBarcodeRearrange();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded borders
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 0,
                                blurRadius: 20, // Increased shadow blur
                                offset: const Offset(
                                    0, 10), // Increased vertical offset
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Rearrange',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FindItemResponse {
  final String itemName;
  final int itemId;
  final int? shelfHorizontal; // Make this nullable
  final String? shelfVertical; // Make this nullable

  FindItemResponse({
    required this.itemName,
    required this.itemId,
    this.shelfHorizontal, // Now nullable
    this.shelfVertical, // Now nullable
  });

  factory FindItemResponse.fromJson(Map<String, dynamic> json) {
    return FindItemResponse(
      itemName: json['item_name'],
      itemId: json['item_id'],
      shelfHorizontal: json[
          'shelf_horizontal'], // This can now be null without causing an error
      shelfVertical: json[
          'shelf_vertical'], // This can now be null without causing an error
    );
  }
}
