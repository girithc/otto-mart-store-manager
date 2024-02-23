import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store/utils/constants.dart';

class CategoryApiClient {
  CategoryApiClient();

  Future<List<Category>> fetchCategories() async {
    var url = Uri.parse('$baseUrl/category');

    //var queryParams = {'id': id.toString()};
    //url = url.replace(queryParameters: queryParams);

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
