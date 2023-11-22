import 'package:flutter/material.dart';
import 'package:store/order/handoff.dart';

class OrderChecklistPage extends StatefulWidget {
  const OrderChecklistPage({super.key});

  @override
  State<OrderChecklistPage> createState() => _OrderChecklistPageState();
}

class _OrderChecklistPageState extends State<OrderChecklistPage> {
  // Sample data for the list
  final List<Map<String, dynamic>> products = List.generate(
      10,
      (index) => {
            'name': 'Product ${index + 1}',
            'aisle': 'Aisle ${index + 1}',
            'quantity': 0,
          });

  @override
  Widget build(BuildContext context) {
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
            // Wrap ListView.builder in Expanded
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.only(left: 1.0, right: 1.0, bottom: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondary),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 4),
                    title: Text(products[index]['name']),
                    leading: Text(products[index]['aisle']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (products[index]['quantity'] > 0) {
                                products[index]['quantity']--;
                              }
                            });
                          },
                        ),
                        Text('${products[index]['quantity']}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              products[index]['quantity']++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Hero(
            tag: 'handoffbutton',
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HandOffPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: 15),
              ),
              child: const Text('Complete Checklist',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}
