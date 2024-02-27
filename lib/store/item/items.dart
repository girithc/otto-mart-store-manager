import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:store/main.dart';
import 'package:store/store/item/view.dart';
import 'package:store/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  List<Item> items = [];
  final CarouselController _controller = CarouselController();
  final int _current = 0; // Current index of the carousel

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/manager-items'));

    //print("Response: ${response.body}");
    if (response.statusCode == 200) {
      //print("Success: ${response.body}");
      List<dynamic> itemsJson = json.decode(response.body);
      setState(() {
        items = itemsJson.map((jsonItem) => Item.fromJson(jsonItem)).toList();
      });
    } else {
      print("response.statusCode: ${response.statusCode} ${response.body}");
      // Handle error or show a message
      throw Exception('Failed to load items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              ),
            );
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.zero,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0.0,
              crossAxisSpacing: 0.0,
              childAspectRatio: 0.65),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewItemPage(
                      itemId: items[index].id,
                    ),
                  ),
                )
              },
              child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset:
                            const Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        child: items[index].imageUrls.isNotEmpty
                            ? Image.network(
                                items[index].imageUrls[
                                    0], // Assuming each item has at least one imageUrl
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              )
                            : const SizedBox(
                                child: Icon(Icons
                                    .error)), // Empty SizedBox if there's no image URL
                      ),
                      Text(items[index].name),
                      //Text(items[index].description),

                      Chip(
                        label: Text(
                          items[index].brandName,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color.fromARGB(255, 11, 105,
                            236), // Chip background color for brands
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: Colors.transparent), // Transparent border
                        ),
                      ),
                      Chip(
                        label: Text(
                          "${items[index].quantity} ${items[index].unitOfQuantity}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),

                        backgroundColor: Colors
                            .greenAccent, // Chip background color for brands
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                              color: Colors.transparent), // Transparent border
                        ),
                      ),
                      /*
                      Wrap(
                        spacing: 6, // Space between chips
                        children: items[index]
                            .categoryNames
                            .map((brand) => Chip(
                                  label: Text(
                                    brand.toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                      255,
                                      11,
                                      105,
                                      236), // Chip background color for brands
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: Colors
                                            .transparent), // Transparent border
                                  ),
                                ))
                            .toList(),
                      ),
                      */
                    ],
                  )),
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshItems() async {
    setState(() {
      fetchItems();
    });
  }
}

class Item {
  final int id;
  final String name;
  final int brandId;
  final int quantity;
  final String? barcode; // Nullable
  final String unitOfQuantity;
  final String description;
  final DateTime createdAt;
  final int createdBy;
  final List<int> categoryIds; // List can be empty if null
  final List<String> imageUrls; // List can be empty if null
  final List<String> categoryNames;
  final String brandName;

  Item({
    required this.id,
    required this.name,
    required this.brandId,
    required this.quantity,
    this.barcode,
    required this.unitOfQuantity,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    required this.categoryIds,
    required this.imageUrls,
    required this.categoryNames,
    required this.brandName,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      brandId: json['brand_id'],
      quantity: json['quantity'],
      barcode: json['barcode'],
      unitOfQuantity: json['unit_of_quantity'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      categoryIds: List<int>.from(json['category_ids'] ?? []),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      categoryNames: List<String>.from(json['category_names'] ?? []),
      brandName: json['brand_name'],
    );
  }
}
