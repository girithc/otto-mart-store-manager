import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:store/utils/network/service.dart';

class ItemFinance extends StatefulWidget {
  const ItemFinance({super.key, required this.itemId});

  final int itemId;

  @override
  State<ItemFinance> createState() => _ItemFinanceState();
}

class _ItemFinanceState extends State<ItemFinance> {
  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: "",
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      fillColor: const Color.fromARGB(255, 189, 235, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
    );
  }

  bool _hasFinanceDetails = false;
  @override
  void initState() {
    super.initState();
    fetchItemFinance();
  }

  ItemFinanceDetails? _itemFinanceDetails;

  Future<void> fetchItemFinance() async {
    Map<String, dynamic> data = {
      "id": widget.itemId,
    };

    final networkService = NetworkService();
    final response = await networkService
        .postWithAuth("/manager-item-finance-get", additionalData: data);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _itemFinanceDetails = ItemFinanceDetails.fromJson(jsonResponse);
      });
    } else {
      print("Response body is null or empty");
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
              decoration: inputDecoration('Name'),
              controller: TextEditingController(
                  text: _itemFinanceDetails?.itemName ?? ""),
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
                        decoration: inputDecoration('Price'),
                        controller: TextEditingController(
                            text:
                                _itemFinanceDetails?.quantity.toString() ?? ""),
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
                        decoration: inputDecoration('Quantity'),
                        controller: TextEditingController(
                            text: _itemFinanceDetails?.unitOfQuantity ?? ""),
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
                        decoration: inputDecoration('Price'),
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
                          "Buy Price",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration('Quantity'),
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
                          "Margin",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration('Price'),
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
                          "GST",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      TextField(
                        decoration: inputDecoration('Quantity'),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.only(bottom: 25.0, top: 10, left: 20, right: 20),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
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

  ItemFinanceDetails({
    required this.itemID,
    required this.itemName,
    required this.unitOfQuantity,
    required this.quantity,
    this.buyPrice,
    this.mrpPrice,
  });

  factory ItemFinanceDetails.fromJson(Map<String, dynamic> json) {
    return ItemFinanceDetails(
      itemID: json['item_id'],
      itemName: json['item_name'],
      unitOfQuantity: json['unit_of_quantity'],
      quantity: json['quantity'],
      buyPrice: json['buy_price']?['Valid'] == true
          ? json['buy_price']['Float64']
          : null,
      mrpPrice: json['mrp_price']?['Valid'] == true
          ? json['mrp_price']['Float64']
          : null,
    );
  }
}
