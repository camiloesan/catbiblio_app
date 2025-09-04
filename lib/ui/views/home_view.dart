import 'dart:collection';

import 'package:flutter/material.dart';

part '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100, child: Image.asset('assets/images/head.png')),
            DropdownMenu(
              label: const Text('Buscar por'),
              dropdownMenuEntries: ColorLabel.entries,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            DropdownMenu(
              label: const Text('Biblioteca'),
              dropdownMenuEntries: ColorLabel.entries,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.clear),
                labelText: 'Buscar',
                // hintText: 'Buscando por título en la USBI Xalapa',
                helperText: 'Buscando por título en la USBI Xalapa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Nuevas adquisiciones", style: Theme.of(context).textTheme.headlineSmall),
            ),
          ],
        ),
      ),
    );
  }
}
