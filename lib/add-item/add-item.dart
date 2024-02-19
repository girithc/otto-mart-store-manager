import 'dart:convert';

import 'package:http/http.dart' as http;

class AddItemApiClient {
  final String baseUrl;

  AddItemApiClient(this.baseUrl);

  Future<Item> fetchItem(int itemId) async {
    var url = Uri.parse('http://localhost:3000/item');

    if (itemId == 0) {
      throw Exception('(AddItemApiClient) Parameters are not valid');
    }

    var queryParams = {
      'item_id': itemId.toString(),
    };
    url = url.replace(queryParameters: queryParams);

    print("Query Params $queryParams");
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      final Item item = Item.fromJson(jsonData);

      print("Item: ${item.name}");
      return item;
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<Item> editItem(UpdateItem item) async {
    var url = Uri.parse(
        'http://localhost:3000/item'); // Assuming the endpoint expects the ID in the URL

    if (item.id == 0) {
      throw Exception('(AddItemApiClient) Parameters are not valid');
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    print("Debug Item Before Send off ${item.name}");

    final itemJson =
        item.toJson(); // Assuming you have a toJson method in your Item class

    http.Response response = await http.post(
      url,
      headers: headers,
      body: json.encode(itemJson),
    );

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      final Item updatedItem = Item.fromJson(jsonData);

      print("Updated Item: ${updatedItem.name}");
      return updatedItem;
    } else {
      throw Exception('Failed to update item');
    }
  }
}

class Item {
  final int id;
  final String name;
  final int price;
  final int stockQuantity;
  final String createdAt;
  final int createdBy;
  final int storeId;
  final int categoryId;

  Item(
      {required this.id,
      required this.name,
      required this.price,
      required this.stockQuantity,
      required this.createdAt,
      required this.createdBy,
      required this.storeId,
      required this.categoryId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock_quantity': stockQuantity,
      'created_at': createdAt,
      'created_by': createdBy,
      'store_id': storeId,
      'category_id': categoryId,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        stockQuantity: json['stock_quantity'],
        createdAt: json['created_at'],
        createdBy: json['created_by'],
        storeId: json['store_id'],
        categoryId: json['category_id']);
  }
}

class UpdateItem {
  final int id;
  final String name;
  final int price;
  final int stockQuantity;
  final int categoryId;

  UpdateItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.stockQuantity,
      required this.categoryId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
    };
  }

  factory UpdateItem.fromJson(Map<String, dynamic> json) {
    return UpdateItem(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        stockQuantity: json['stock_quantity'],
        categoryId: json['category_id']);
  }
}
