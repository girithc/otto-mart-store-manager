import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store/utils/constants.dart';

class CategoryApiClient {
  CategoryApiClient();

  Future<List<Category>> fetchCategories() async {
    var url = Uri.parse('$baseUrl/category');

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<Category> categories =
          jsonData.map((item) => Category.fromJson(item)).toList();
      return categories;
    } else {
      print("Error: ${response.statusCode} ${response.body}");
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Brand>> fetchBrands() async {
    var url = Uri.parse('$baseUrl/get-brand');

    http.Response response = await http.get(url);

    //print("Response: ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<Brand> brands =
          jsonData.map((item) => Brand.fromJson(item)).toList();
      return brands;
    } else {
      print("Error: ${response.statusCode} ${response.body}");
      throw Exception('Failed to load brands');
    }
  }
}

class Brand {
  final int id;
  final String name;

  Brand({required this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}
