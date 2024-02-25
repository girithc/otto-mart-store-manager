import 'package:flutter/material.dart';
import 'package:store/store/item/items.dart';

class ItemImage extends StatefulWidget {
  final Item item;

  const ItemImage({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemImage> createState() => _ItemImageState();
}

class _ItemImageState extends State<ItemImage> {
  late List<String> imageUrls;

  @override
  void initState() {
    super.initState();
    imageUrls = List.from(
        widget.item.imageUrls); // Make a copy of the initial image URLs
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String image = imageUrls.removeAt(oldIndex);
    setState(() {
      imageUrls.insert(newIndex, image);
    });
  }

  void _addImage() {
    setState(() {
      imageUrls.add('https://via.placeholder.com/150');
    });
  }

  void _removeImage(int index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item Images'),
      ),
      body: ReorderableListView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          String imageUrl = imageUrls[index];
          return Dismissible(
            key: ValueKey(imageUrl),
            onDismissed: (_) => _removeImage(index),
            background: Container(color: Colors.red),
            child: Card(
              key: ValueKey(imageUrl), // Important for ReorderableListView
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Stack(
                              alignment: Alignment
                                  .topRight, // Position the close button at the top right corner
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: Image.network(imageUrl,
                                      fit: BoxFit.contain),
                                ),
                                IconButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                  ),
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog when the button is pressed
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 22 / 9, // Adjust the aspect ratio as needed
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                  ListTile(
                    title: Text('Image ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeImage(index),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        onReorder: _onReorder,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        tooltip: 'Add Image',
        child: const Icon(Icons.add),
      ),
    );
  }
}
