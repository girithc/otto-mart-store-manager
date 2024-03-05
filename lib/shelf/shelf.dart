import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:store/utils/constants.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key});

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  //final List<String> categories = ['A', 'B', 'C', 'D', 'E'];
  List<Shelf> shelfList = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchShelf();
  }

  Future<void> fetchShelf() async {
    try {
      // Retrieve storeId from FlutterSecureStorage
      String? storeId = await secureStorage.read(key: 'storeId');
      if (storeId == null) {
        print('storeId is null');
        storeId = "1";
      }
      int parsedStoreId = int.parse(storeId);

      // Prepare the URL with query parameters
      var url = Uri.parse('$baseUrl/shelf-crud').replace(queryParameters: {
        'store_id': parsedStoreId.toString(),
      });

      // Send the GET request
      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print("Response: ${response.body}");
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Decode the response and update the shelfList
        var jsonResponse = json.decode(response.body);
        setState(() {
          shelfList = List<Shelf>.from(
              jsonResponse.map((model) => Shelf.fromJson(model)));
        });
      } else {
        // Handle the error
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      // Handle any exceptions
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelf'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildCategoryContainer(
                    context,
                    shelfList[index].id,
                    "${shelfList[index].vertical} - ${shelfList[index].horizontal}",
                  );
                },
                childCount: shelfList.length,
              ),
            ),
          ),
          // Add other slivers if needed
        ],
      ),
    );
  }

  Widget _buildCategoryContainer(
      BuildContext context, int shelfId, String position) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.shade100,
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                position,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    height: 1.1,
                    fontSize: 25), // Adjusting the line spacing here
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Shelf {
  final int id;
  final int storeId;
  final String vertical;
  final int horizontal;

  Shelf({
    required this.id,
    required this.storeId,
    required this.vertical,
    required this.horizontal,
  });

  // A method to create a Shelf instance from a JSON object
  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(
      id: json['id'],
      storeId: json['store_id'] as int,
      vertical: json['vertical'] as String,
      horizontal: json['horizontal'] as int,
    );
  }
}
