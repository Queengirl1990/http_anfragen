import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
