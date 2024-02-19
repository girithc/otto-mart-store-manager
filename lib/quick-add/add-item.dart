import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store/main.dart';
import 'package:store/quick-add/listen-barcode.dart';
import 'package:store/stock/add-stock.dart';
import 'package:store/utils/constants.dart';

class AddItemScreen extends StatefulWidget {
  ItemAdd item;
  AddItemScreen({required this.item, Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();

  ItemAdd? newItem;
  List<Category> categories = [];
  int? selectedCategoryId;
  int stockQuantity = 1;
  String? selectedUnit;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    fetchStoreId();
    _quantityController.text =
        stockQuantity.toString(); // Assuming stockQuantity is an integer
  }

  Future<void> fetchStoreId() async {
    String? storeId = await secureStorage.read(key: 'storeId');
    if (storeId != null) {
      setState(() {
        newItem?.storeId = int.tryParse(storeId) ?? 0;
      });
    }
  }

  Future<AddStockResponse?> addStock() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST',
        Uri.parse('https://otto-mart-2cta4tgbnq-el.a.run.app/item-add-stock'));
    request.body = json.encode({
      "add_stock": int.parse(_quantityController.text),
      "item_id": widget.item.id,
      "store_id": 1
    });
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var decodedJson = json.decode(responseBody);
        return AddStockResponse.fromJson(decodedJson);
      } else {
        // Handle non-200 responses or log the error
        print("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      // Handle any exceptions during the request
      print("Exception occurred: $e");
      return null;
    }
  }

  InputDecoration getDecoration(
      String label, String hintText, TextStyle textStyle) {
    return InputDecoration(
      labelText: label,
      labelStyle: textStyle,
      hintText: hintText,
      hintStyle: textStyle, // Apply the same style to the hint text
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle fieldTextStyle =
        const TextStyle(fontSize: 18); // Adjust font size as needed
    TextStyle inputTextStyle =
        const TextStyle(fontSize: 20); // Adjust font size as needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
            padding: const EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Image.network(
                  widget.item.imageURLs[0],
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Center(
                        child: Text(
                          'no image',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  style: inputTextStyle,
                  decoration:
                      getDecoration('Name', 'Enter Name', fieldTextStyle),
                  onSaved: (value) => newItem?.name = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter name' : null,
                  initialValue: widget.item.name,
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        style: inputTextStyle,
                        decoration: getDecoration(
                            'Brand Name', 'Enter Brand Name', fieldTextStyle),
                        onSaved: (value) => newItem?.brand = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter brand name' : null,
                        initialValue: widget.item.brand,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        style: inputTextStyle,
                        decoration: getDecoration(
                            'Quantity', 'Enter Quantity', fieldTextStyle),
                        onSaved: (value) =>
                            newItem?.quantity = int.tryParse(value!) ?? 0,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter quantity' : null,
                        initialValue:
                            "${widget.item.quantity} ${widget.item.unit}",
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Greyish background
                        shape: BoxShape.circle, // Circular shape
                      ),
                      child: IconButton(
                        iconSize: 40, // Increased icon size
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          int currentValue =
                              int.tryParse(_quantityController.text) ?? 0;
                          if (currentValue > 0) {
                            setState(() {
                              currentValue--;
                              _quantityController.text =
                                  currentValue.toString();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: TextFormField(
                          style: const TextStyle(fontSize: 30),
                          textAlign: TextAlign
                              .center, // Center the text inside TextFormField
                          controller: _quantityController,
                          decoration: getDecoration(
                              'Quantity', 'Enter Quantity', fieldTextStyle),
                          keyboardType: TextInputType.number,
                          onSaved: (value) =>
                              newItem?.quantity = int.tryParse(value!) ?? 0,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter quantity' : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Greyish background
                        shape: BoxShape.circle, // Circular shape
                      ),
                      child: IconButton(
                        iconSize: 40, // Increased icon size
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          int currentValue =
                              int.tryParse(_quantityController.text) ?? 0;
                          setState(() {
                            currentValue++;
                            _quantityController.text = currentValue.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    addStock().then((value) {
                      if (value != null) {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Makes the dialog undismissible
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.deepPurpleAccent,
                              title: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(
                                      width:
                                          10), // Spacing between icon and text
                                  Text(
                                    "Success",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(
                                      "Name: ${value.itemName}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Brand: ${widget.item.brand}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Added Stock: ${value.addedStock}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Stock Quantity: ${value.stockQuantity}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor:
                                        Colors.white, // Button text color
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 15), // Button padding
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(
                                        fontSize:
                                            16), // Bigger text size for the button
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MyHomePage()),
                                    ); // Navigate to MyHomePage
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Handle the case when value is null (e.g., show an error message)
                      }
                    }).catchError((error) {
                      // Handle any errors here
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 4.0,
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    shadowColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 65, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_ios_new_outlined),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Complete",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    addStock().then((value) {
                      if (value != null) {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Makes the dialog undismissible
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.deepPurpleAccent,
                              title: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(
                                      width:
                                          10), // Spacing between icon and text
                                  Text(
                                    "Success",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(
                                      "Name: ${value.itemName}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Brand: ${widget.item.brand}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Added Stock: ${value.addedStock}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Stock Quantity: ${value.stockQuantity}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor:
                                        Colors.white, // Button text color
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 15), // Button padding
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(
                                        fontSize:
                                            16), // Bigger text size for the button
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ListenBarcodePage()),
                                    ); // Navigate to MyHomePage
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Handle the case when value is null (e.g., show an error message)
                      }
                    }).catchError((error) {
                      // Handle any errors here
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6200EE),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 65, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add Item",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemAdd {
  int id;
  String name;
  String brand;
  int quantity;
  String barcode;
  String unit;
  int storeId;
  int stockQuantity;
  List<String> imageURLs;

  ItemAdd({
    required this.id,
    required this.name,
    required this.brand,
    required this.quantity,
    required this.barcode,
    required this.unit,
    required this.storeId,
    required this.stockQuantity,
    required this.imageURLs,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'barcode': barcode,
      'unit': unit,
      'storeId': storeId,
      'stockQuantity': stockQuantity,
      'imageURLs': imageURLs,
    };
  }

  factory ItemAdd.fromJson(Map<String, dynamic> json) {
    return ItemAdd(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      quantity: json['quantity'],
      barcode: json['barcode'],
      unit: json['unit'],
      storeId: json['store_id'],
      stockQuantity: json['stock_quantity'],
      imageURLs: List<String>.from(json['image_urls']),
    );
  }
}

class ItemAddQuickResponse {
  final bool success;

  ItemAddQuickResponse({required this.success});

  factory ItemAddQuickResponse.fromJson(Map<String, dynamic> json) {
    return ItemAddQuickResponse(
      success: json['success'] as bool,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class AddStockResponse {
  final int itemId;
  final String itemName;
  final int addedStock;
  final int stockQuantity;
  final int storeId;

  AddStockResponse({
    required this.itemId,
    required this.itemName,
    required this.addedStock,
    required this.stockQuantity,
    required this.storeId,
  });

  factory AddStockResponse.fromJson(Map<String, dynamic> json) {
    return AddStockResponse(
      itemId: json['item_id'],
      itemName: json['item_name'],
      addedStock: json['added_stock'],
      stockQuantity: json['stock_quantity'],
      storeId: json['store_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'added_stock': addedStock,
      'stock_quantity': stockQuantity,
      'store_id': storeId,
    };
  }
}
