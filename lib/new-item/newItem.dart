import 'package:flutter/material.dart';
import 'package:store/store/category/category.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({super.key});

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final CategoryApiClient apiClient = CategoryApiClient();
  List<Brand> brands = [];

  Future<void> fetchBrands() async {
    try {
      final fetchedBrands = await apiClient.fetchBrands();
      setState(() {
        brands = fetchedBrands;
        //print(brands);
      });
    } catch (err) {
      print('(catalog)fetchCategories error $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: const Column(children: []),
      ),
    );
  }
}
