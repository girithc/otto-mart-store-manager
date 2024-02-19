import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:store/utils/constants.dart';

class StoreApiClient {
  StoreApiClient();

  Future<List<Store>> fetchStores() async {
    var url = Uri.parse('$baseUrl/store');

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<Store> stores =
          jsonData.map((store) => Store.fromJson(store)).toList();
      return stores;
    } else {
      throw Exception('Failed to load Stores');
    }
  }
}

class Store {
  final int id;
  final String name;
  final String address;
  final String createdAt;
  final int createdBy;
  Store(
      {required this.id,
      required this.name,
      required this.address,
      required this.createdAt,
      required this.createdBy});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        createdAt: json['created_at'],
        createdBy: json['created_by']);
  }
}
