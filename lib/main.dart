import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class Person {
  final String name;
  final int estimatedAge;

  Person({required this.name, required this.estimatedAge});
}

class AgeEstimationViewModel with ChangeNotifier {
  Person? _estimatedPerson;

  Person? get estimatedPerson => _estimatedPerson;

  void showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> estimateAge(String name, BuildContext context) async {
    if (name.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(name)) {
      showErrorSnackbar(context, 'Bitte einen gültigen Namen eingeben.');
      return;
    }

    final response =
        await http.get(Uri.parse('https://api.agify.io?name=$name'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['name'] is String && data['age'] is int) {
        _estimatedPerson = Person(
          name: data['name'] as String,
          estimatedAge: data['age'] as int,
        );
      } else {
        showErrorSnackbar(context, 'Ungültige Daten vom Server erhalten.');
      }
    } else {
      showErrorSnackbar(context, 'HTTP-Anfrage fehlgeschlagen.');
    }

    notifyListeners();
  }

  void clearEstimation() {
    _estimatedPerson = null;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AgeEstimationViewModel(),
      child: MaterialApp(
        home: AgeEstimationScreen(),
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

class AgeEstimationScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AgeEstimationViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('5.7.1.-5.7.3 HTTP-Anwendung'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(labelText: 'Gib deinen Namen ein'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                viewModel.estimateAge(name, context);
              },
              child: const Text('Dein geschätztes Alter'),
            ),
            const SizedBox(height: 20),
            if (viewModel.estimatedPerson != null)
              Column(
                children: [
                  Text(
                      'Geschätztes Alter: ${viewModel.estimatedPerson!.estimatedAge}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.clearEstimation();
                      _nameController.clear();
                    },
                    child: const Text('Neustart'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
