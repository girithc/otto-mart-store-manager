import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:store/utils/constants.dart';
import 'package:store/utils/network/service.dart';
import 'package:http/http.dart' as http;

class ItemFinance extends StatefulWidget {
  const ItemFinance({super.key, required this.itemId});

  final int itemId;

  @override
  State<ItemFinance> createState() => _ItemFinanceState();
}

class _ItemFinanceState extends State<ItemFinance> {
  bool _isEditMode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitofquantitycontroller =
      TextEditingController();
  final TextEditingController _mrppriceController = TextEditingController();
  final TextEditingController _marginController = TextEditingController();
  final TextEditingController _gstcontroller = TextEditingController();
  final TextEditingController _buypricecontroller = TextEditingController();
  int? _selectedGst; // Assuming GST is an integer value

  // Add more controllers as needed for other fields

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: !_isEditMode
          ? const Color.fromARGB(255, 189, 235, 255)
          : Colors.greenAccent,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  final bool _hasFinanceDetails = false;
  @override
  void initState() {
    super.initState();
    fetchItemFinance();
    fetchTax();
  }

  ItemFinanceDetails? _itemFinanceDetails;
  List<Tax> _taxes = [];

  Future<void> fetchTax() async {
    http.Response response = await http.get(
      Uri.parse('$baseUrl/manager-tax-get'),
    );
    print("Response Tax: ${response.body}");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Correctly map each JSON object to a Tax instance and convert to a list
      _taxes = List<Tax>.from(jsonResponse.map((tax) => Tax.fromJson(tax)));
      setState(() {
        // This part might need adjustment based on how you want to use _taxes
        // For example, setting _selectedGst to the first tax's GST value if needed
        // _selectedGst = _taxes.isNotEmpty ? _taxes.first.gst : null;
      });
    } else {
      print("Response body is null or empty");
    }
  }

  Future<void> fetchItemFinance() async {
    Map<String, dynamic> data = {
      "id": widget.itemId,
    };

    final networkService = NetworkService();
    final response = await networkService
        .postWithAuth("/manager-item-finance-get", additionalData: data);

    print("Response Item Finance: ${response.body}");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _itemFinanceDetails = ItemFinanceDetails.fromJson(jsonResponse);
        _nameController.text = _itemFinanceDetails!.itemName;
        _quantityController.text = _itemFinanceDetails!.quantity.toString();
        _unitofquantitycontroller.text = _itemFinanceDetails!.unitOfQuantity;
        _mrppriceController.text = _itemFinanceDetails!.mrpPrice.toString();
        _buypricecontroller.text = _itemFinanceDetails!.buyPrice.toString();
        _marginController.text = _itemFinanceDetails!.margin.toString();
        _gstcontroller.text = _itemFinanceDetails!.gst.toString();
// This assumes _selectedGst is meant to store the GST rate in its percentage form.
        _selectedGst = (_itemFinanceDetails!.gst! * 100).toInt();
        print("Selected GST fetch: $_selectedGst");
      });
    } else {
      print("Response body is null or empty");
    }
  }

  void toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> saveDetails() async {
    if (_selectedGst == null) {
      // Handle the case where _selectedGst is null.
      // For example, show an error message or set a default value.
      print("GST value is not selected.");
      return;
    }

    Map<String, dynamic> data = {
      "item_id": widget.itemId,
      "mrp_price": double.parse(_mrppriceController.text),
      "buy_price": double.parse(_buypricecontroller.text),
      "margin": double.parse(_marginController.text),
      // Divide _selectedGst by 100 to convert to decimal format
      "gst": _selectedGst! / 100,
    };

    final networkService = NetworkService();
    final response = await networkService
        .postWithAuth('/manager-item-finance-edit', additionalData: data);

    if (response.statusCode == 200) {
      print("Response Item Finance Edit: ${response.body}");

      setState(() {
        _isEditMode = !_isEditMode;
      });
      await fetchItemFinance(); // Re-fetch item finance details to refresh the widget
    } else {
      print("Error Edit: ${response.body}");
    }
  }

  // Function to calculate and update margin based on MRP and Buy Price
  void _updateMargin() {
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double buyPrice = double.tryParse(_buypricecontroller.text) ?? 0;
    if (mrp > 0 && buyPrice > 0 && buyPrice <= mrp) {
      double margin = ((mrp - buyPrice) / mrp) * 100;
      _marginController.text = margin.toStringAsFixed(2);
    }
  }

  // Function to calculate and update Buy Price based on MRP and Margin
  void _updateBuyPrice() {
    double mrp = double.tryParse(_mrppriceController.text) ?? 0;
    double margin = double.tryParse(_marginController.text) ?? 0;
    if (mrp > 0 && margin >= 0 && margin <= 100) {
      double buyPrice = mrp * (1 - margin / 100);
      _buypricecontroller.text = buyPrice.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Finance'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Name",
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            TextField(
              decoration: inputDecoration(''),
              controller: _nameController,
              readOnly: true,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Quantity",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration(''),
                        controller: _quantityController,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Unit",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration(''),
                        controller: _unitofquantitycontroller,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "MRP Price",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration(''),
                        controller: _mrppriceController,
                        readOnly: !_isEditMode,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Buy Price",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration(''),
                        controller: _buypricecontroller,
                        readOnly: !_isEditMode,
                        onChanged: (_) => _updateMargin(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Margin",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration(''),
                        controller: _marginController,
                        readOnly: !_isEditMode,
                        onChanged: (_) => _updateBuyPrice(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "GST",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      _isEditMode
                          ? DropdownButtonFormField<int>(
                              decoration: inputDecoration(""),
                              value:
                                  _selectedGst, // This should be the sum of GST and CESS where needed
                              items: _taxes.map((Tax tax) {
                                int combinedRate =
                                    tax.gst + tax.cess; // Combine GST and CESS
                                return DropdownMenuItem<int>(
                                  value: combinedRate,
                                  child: Text("${combinedRate / 100}%"),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                print("Selected GSt $_selectedGst");
                                setState(() {
                                  _selectedGst =
                                      newValue; // newValue will be the combined rate
                                });
                                print("Post Selected GSt $_selectedGst");
                              },
                            )
                          : TextField(
                              decoration: inputDecoration(''),
                              controller: _gstcontroller,
                              readOnly: !_isEditMode,
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 25.0, top: 10, left: 20, right: 20),
        child: ElevatedButton(
          onPressed: _isEditMode ? saveDetails : toggleEditMode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(
            _isEditMode ? 'Save' : 'Edit',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class Tax {
  final int gst;
  final int cess;
  final int id;

  Tax({required this.gst, required this.cess, required this.id});

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      gst: json['GST'],
      cess: json['CESS'],
      id: json['ID'],
    );
  }
}

class ItemFinanceDetails {
  final int itemID;
  final String itemName;
  final String unitOfQuantity;
  final int quantity;
  final double? buyPrice;
  final double? mrpPrice;
  final double? gst;

  final double? margin;

  ItemFinanceDetails({
    required this.itemID,
    required this.itemName,
    required this.unitOfQuantity,
    required this.quantity,
    this.buyPrice,
    this.gst,
    this.mrpPrice,
    this.margin,
  });

  factory ItemFinanceDetails.fromJson(Map<String, dynamic> json) {
    return ItemFinanceDetails(
      itemID: json['item_id'],
      itemName: json['item_name'],
      unitOfQuantity: json['unit_of_quantity'],
      quantity: json['quantity'],
      buyPrice: json['buy_price']?['Valid'] == true
          ? (json['buy_price']['Float64'] is int
              ? (json['buy_price']['Float64'] as int).toDouble()
              : json['buy_price']['Float64'])
          : null,
      mrpPrice: json['mrp_price']?['Valid'] == true
          ? (json['mrp_price']['Float64'] is int
              ? (json['mrp_price']['Float64'] as int).toDouble()
              : json['mrp_price']['Float64'])
          : null,
      margin: json['margin']?['Valid'] == true
          ? (json['margin']['Float64'] is int
              ? (json['margin']['Float64'] as int).toDouble()
              : json['margin']['Float64'])
          : null,
      gst: json['gst_rate']?['Valid'] == true
          ? (json['gst_rate']['Float64'] is int
              ? json['gst_rate']['Float64'] / 100
              : (json['gst_rate']['Float64'] as double) / 100)
          : null,
    );
  }
}
