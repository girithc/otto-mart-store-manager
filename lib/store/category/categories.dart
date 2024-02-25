import 'package:flutter/material.dart';
import 'package:store/store/category/category.dart';
import 'package:store/store/item/items.dart';

class Categories extends StatefulWidget {
  const Categories({super.key, required this.storeId, required this.storeName});

  final int storeId;
  final String storeName;

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final CategoryApiClient apiClient = CategoryApiClient();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await apiClient.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        print(categories[1].name);
      });
    } catch (err) {
      print('(catalog)fetchCategories error $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 4.0,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            "Store: ${widget.storeName}",
            style: const TextStyle(
                color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
          ),
        ),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 0.0,
            childAspectRatio: 0.98,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Items(),
                  ),
                )
              },
              child: Material(
                elevation: 2.0,
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 248, 219, 253),
                      border: Border.all(color: Colors.white, width: 2.0)),
                  alignment: Alignment.topCenter,
                  child: Text(
                    '${index + 1}. ${categories[index].name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          },
        )
        /*ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index].name),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Items(
                    categoryId: categories[index].id,
                    categoryName: categories[index].name,
                    storeId: widget.storeId,
                  ),
                ),
              )
            },
          );
        },
      ),
    */
        );
  }
}
