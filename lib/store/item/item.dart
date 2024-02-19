import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:store/utils/constants.dart';

class ItemApiClient {
  ItemApiClient();

  Future<List<Item>> fetchItems(int categoryId, int storeId) async {
    var url = Uri.parse('$baseUrl/item');

    if (categoryId == 0 || storeId == 0) {
      throw Exception('(ItemApiClient) Parameters are not valid');
    }

    var queryParams = {
      'category_id': categoryId.toString(),
      'store_id': storeId.toString()
    };
    url = url.replace(queryParameters: queryParams);

    print("Query Params $queryParams");
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<Item> items =
          jsonData.map((item) => Item.fromJson(item)).toList();
      print("Items Length ${items.length} First Item: ${items[0].name}");
      return items;
    } else {
      throw Exception('Failed to load items');
    }
  }
}

class Item {
  final int id;
  final String name;
  final int mrpPrice;
  final int discount;
  final int storePrice;
  final int stockQuantity;
  final String image;
  final int quantity;
  final String unitOfQuantity;
  final String category;

  Item(
      {required this.id,
      required this.name,
      required this.mrpPrice,
      required this.discount,
      required this.storePrice,
      required this.stockQuantity,
      required this.image,
      required this.quantity,
      required this.unitOfQuantity,
      required this.category});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'],
        name: json['name'],
        mrpPrice: json['mrp_price'],
        discount: json['discount'],
        storePrice: json['store_price'],
        stockQuantity: json['stock_quantity'],
        image: json['image'],
        quantity: json['quantity'],
        unitOfQuantity: json['unit_of_quantity'],
        category: json['category']);
  }
}
