import 'package:flutter/material.dart';

part '../controllers/finder_controller.dart';

class FinderView extends StatefulWidget {
  const FinderView({super.key});

  @override
  State<FinderView> createState() => _FinderViewState();
}

class _FinderViewState extends FinderController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finder View'),
      ),
      body: const Center(
        child: Text('This is the Finder View'),
      ),
    );
  }
}