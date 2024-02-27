import 'package:flutter/material.dart';
import 'package:store/new-item/add-item/add-item.dart';
import 'package:store/new-item/find-item/find-item.dart';
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddItem()),
                          )
                        },
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 15, right: 7.5, top: 15, bottom: 7.5),
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.85,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded borders
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius: 0,
                                  blurRadius: 20, // Increased shadow blur
                                  offset: const Offset(
                                      0, 10), // Increased vertical offset
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'New Item',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FindItem()),
                          )
                        },
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 7.5, top: 15, bottom: 7.5, right: 15),
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.85,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded borders
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius: 0,
                                  blurRadius: 20, // Increased shadow blur
                                  offset: const Offset(
                                      0, 10), // Increased vertical offset
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'New Barcode',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => {},
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 15, right: 7.5, top: 7.5, bottom: 7.5),
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.85,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded borders
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius: 0,
                                  blurRadius: 20, // Increased shadow blur
                                  offset: const Offset(
                                      0, 10), // Increased vertical offset
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'New Finance',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded borders
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 0,
                                blurRadius: 20, // Increased shadow blur
                                offset: const Offset(
                                    0, 10), // Increased vertical offset
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'New Scheme',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => {},
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 15, right: 7.5, top: 7.5, bottom: 7.5),
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.85,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(15), // Rounded borders
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2), // Shadow color
                                  spreadRadius: 0,
                                  blurRadius: 20, // Increased shadow blur
                                  offset: const Offset(
                                      0, 10), // Increased vertical offset
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'New Invoice',
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 7.5, top: 7.5, bottom: 7.5, right: 15),
                          height: MediaQuery.of(context).size.height * 0.2,
                          width: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15), // Rounded borders
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.2), // Shadow color
                                spreadRadius: 0,
                                blurRadius: 20, // Increased shadow blur
                                offset: const Offset(
                                    0, 10), // Increased vertical offset
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Incoming Item',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
