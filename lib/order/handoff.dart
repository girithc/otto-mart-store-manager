import 'package:flutter/material.dart';

class HandOffPage extends StatefulWidget {
  const HandOffPage({super.key});

  @override
  State<HandOffPage> createState() => _HandOffPageState();
}

class _HandOffPageState extends State<HandOffPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Hero(
          tag: 'handoffbutton',
          child: Text(
            'Hand Off',
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
    );
  }
}
