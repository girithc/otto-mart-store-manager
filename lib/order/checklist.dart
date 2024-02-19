import 'package:flutter/material.dart';
import 'package:store/main.dart';
import 'package:store/order/handoff.dart';

class OrderChecklistPage extends StatefulWidget {
  const OrderChecklistPage({super.key});

  @override
  State<OrderChecklistPage> createState() => _OrderChecklistPageState();
}

class _OrderChecklistPageState extends State<OrderChecklistPage> {
  // Sample data for the list
  final List<Map<String, dynamic>> products = List.generate(
    5,
    (index) => {
      'name': 'Product ${index + 1}',
      'aisle': 'Aisle ${index + 1}',
      'checked': false, // Added 'checked' status
    },
  );

  bool areAllItemsChecked() {
    return products.every((product) => product['checked']);
  }

  @override
  Widget build(BuildContext context) {
    bool allItemsChecked = areAllItemsChecked();

    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'heroButton',
          child: Text(
            'Order Checklist',
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return Container(
                  margin:
                      const EdgeInsets.only(left: 1.0, right: 1.0, bottom: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondary),
                    borderRadius: BorderRadius.circular(2.0),
                    color: product['checked']
                        ? Colors.lightGreenAccent
                        : Colors
                            .white, // Change color based on 'checked' status
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 4),
                    title: Text(product['name']),
                    leading: Text(product['aisle']),
                    trailing: IconButton(
                      icon: Icon(
                        product['checked']
                            ? Icons.remove_circle_outline
                            : Icons
                                .check_circle_outline, // Change icon based on 'checked' status
                        size: 30.0,
                        color: product['checked']
                            ? Colors.deepOrangeAccent
                            : null, // Change icon color for 'checked' items
                      ),
                      onPressed: () {
                        setState(() {
                          product['checked'] =
                              !product['checked']; // Toggle 'checked' status
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            // Use Row to split the button into two parts
            children: <Widget>[
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: areAllItemsChecked()
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyHomePage()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple, // Left side color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // Square shape
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                    ),
                    child: const Text('Pack Order', // Left side text
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                  ),
                ),
              ),
              Expanded(
                child: Hero(
                  tag: 'handoffbutton',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    color: Colors.white,
                    child: ElevatedButton(
                      onPressed: allItemsChecked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HandOffPage()),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: allItemsChecked
                                ? Colors.black26
                                : Colors.white, // Conditional border color
                            width: 2.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: Text(
                        'Hand Off',
                        style: TextStyle(
                          color: allItemsChecked
                              ? Colors.black
                              : Colors.white, // Conditional text color
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
