import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store/add-item/add-items.dart';
import 'package:store/store/item-detail/item-details.dart';
import 'package:store/store/item/item.dart';
import 'package:store/utils/constants.dart';

class Items extends StatefulWidget {
  const Items(
      {required this.categoryId,
      required this.categoryName,
      required this.storeId,
      super.key});
  final int categoryId;
  final String categoryName;
  final int storeId;

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  final ItemApiClient apiClient = ItemApiClient();
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final fetchedItems =
          await apiClient.fetchItems(widget.categoryId, widget.storeId);
      setState(() {
        items = fetchedItems;
      });
    } catch (err) {
      //Handle Error
      setState(() {
        items = [];
      });
      print('(catalog)fetchItems error $err');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 249, 214, 255),
        padding: EdgeInsets.zero,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0.0,
              crossAxisSpacing: 0.0,
              childAspectRatio: 0.638),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(4),
              child: ListItem2(
                  name: items[index].name,
                  id: items[index].id,
                  mrpPrice: items[index].mrpPrice,
                  discount: items[index].discount,
                  storePrice: items[index].storePrice,
                  stockQuantity: items[index].stockQuantity,
                  image: items[index].image,
                  quantity: items[index].quantity,
                  unitOfQuantity: items[index].unitOfQuantity,
                  category: items[index].category,
                  index: index % 2),
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshItems() async {
    setState(() {
      fetchItems();
    });
  }
}

class ListItem2 extends StatelessWidget {
  final String name;
  final int id;
  final int mrpPrice;
  final int discount;
  final int storePrice;
  final int stockQuantity;
  final int index;
  final String image;
  final String unitOfQuantity;
  final int quantity;
  final String category;

  const ListItem2(
      {required this.name,
      required this.id,
      required this.mrpPrice,
      required this.discount,
      required this.storePrice,
      required this.stockQuantity,
      required this.image,
      required this.index,
      required this.unitOfQuantity,
      required this.quantity,
      required this.category,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: GestureDetector(
        onTap: () {},
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 1.0),
                borderRadius: BorderRadius.circular(3.0),
              ),
              margin: index == 0
                  ? const EdgeInsets.only(
                      top: 1,
                      left: 2,
                    )
                  : const EdgeInsets.only(top: 1, left: 2.0, right: 2.0),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                    child: Center(
                      child: Image.network(
                        image,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Center(
                              child: Text(
                                'no image',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      margin: const EdgeInsets.only(top: 2.0),
                      alignment: Alignment.centerLeft,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1.0),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        name,
                        maxLines: 2,
                        style: GoogleFonts.hind(
                          textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      margin: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      height: 17,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1.0),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        '$quantity $unitOfQuantity',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                        height: 17,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1.0),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_offer_outlined,
                              color: Colors.deepPurple,
                              size: 15,
                            ),
                            const SizedBox(
                                width:
                                    5), // Adding some spacing between icon and text
                            Text(
                              'Add 1, Unlock offer',
                              maxLines: 2,
                              style: GoogleFonts.firaSans(
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                  color: Colors.deepPurple,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      height: 37,
                      margin: const EdgeInsets.only(top: 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1.0),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\u{20B9}$storePrice',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            '$mrpPrice',
                            style: const TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.black54,
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Container(
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.only(
                                right: 2, top: 2, bottom: 4),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetails(
                                        itemId: id,
                                        itemName: name,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    surfaceTintColor: Colors.white,
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(2),
                                    side: const BorderSide(
                                      width: 1.0,
                                      color: Colors.pinkAccent,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                      color: Colors.pinkAccent, fontSize: 13.5),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5, // Adjust the position as needed
              left: 5, // Adjust the position as needed
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '\u{20B9}$discount OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
