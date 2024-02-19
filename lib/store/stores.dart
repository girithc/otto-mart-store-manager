import 'package:flutter/material.dart';
import 'package:store/store/category/categories.dart';
import 'package:store/store/store.dart';
import 'package:store/utils/constants.dart';

class Stores extends StatefulWidget {
  const Stores({super.key});

  @override
  State<Stores> createState() => _StoresState();
}

class _StoresState extends State<Stores> {
  final StoreApiClient apiClient = StoreApiClient();
  List<Store> stores = [];

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      final fetchedStores = await apiClient.fetchStores();
      setState(() {
        stores = fetchedStores;
      });
    } catch (err) {
      //Handle Error
      setState(() {
        stores = [];
      });
      print('(catalog)fetchItems error $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stores')),
      body: RefreshIndicator(
        onRefresh: _refreshItems,
        child: ListView.builder(
          itemCount: stores.length + 1,
          itemBuilder: (context, index) {
            if (index == stores.length) {
              return Center(
                child: ElevatedButton(
                    onPressed: () {}, child: const Text('Add Store')),
              );
            }
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white, //Colors.white,
                child: Icon(Icons.beach_access_outlined),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
              title: Text(stores[index].name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Categories(
                      storeId: stores[index].id,
                      storeName: stores[index].name,
                    ),
                  ),
                );
              },
              shape: ContinuousRectangleBorder(
                side: const BorderSide(width: 4, color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: const Color.fromARGB(255, 248, 219, 253),
              contentPadding: const EdgeInsets.all(10),
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshItems() async {
    setState(() {
      fetchStores();
    });
  }
}
