import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:store/new-item/add-item/add-item.dart';
import 'package:store/new-item/finance/finance.dart';
import 'package:store/utils/network/service.dart';

class FindItem extends StatefulWidget {
  const FindItem({super.key});

  @override
  State<FindItem> createState() => _FindItemState();
}

class _FindItemState extends State<FindItem> {
  List<Item> _items = [];

  Future<void> searchItems(String value) async {
    Map<String, dynamic> data = {
      "name": value,
    };

    final networkService = NetworkService();
    final response = await networkService.postWithAuth('/manager-search-item',
        additionalData: data);

    //print("Response Search: ${response.body}");
    if (response.statusCode == 200 &&
        response.body != "null" &&
        response.body != null) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        _items = jsonResponse.map((item) => Item.fromJson(item)).toList();
      });
    } else {
      setState(() {
        _items = [];
      });
      print("Response body is null or empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search For Item',
            hintStyle: TextStyle(color: Colors.black),
          ),
          onChanged: (value) => searchItems(value),
        ),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _items[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.greenAccent,
            ),
            child: ListTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.size} ${item.unitOfQuantity}',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                        return Text('No Image');
                      },
                    )
                  : Text('No Image'),
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
                          padding: EdgeInsets.all(6),
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
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Scheme ",
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "  Image  ",
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
                      ),
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
                builder: (context) => AddItem(),
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

class Item {
  final int id;
  final String name;
  final String description;
  final int size;
  final String unitOfQuantity;
  final String brandName;
  final int brandId;
  final double mrpPrice;
  final List<String> images;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    required this.unitOfQuantity,
    required this.brandName,
    required this.brandId,
    required this.mrpPrice,
    required this.images,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      size: json['size'],
      unitOfQuantity: json['unit_of_quantity'],
      brandName: json['brand_name'],
      brandId: json['brand_id'],
      mrpPrice: json['mrp_price']?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
