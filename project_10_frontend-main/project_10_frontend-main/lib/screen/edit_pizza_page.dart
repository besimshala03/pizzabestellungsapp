import 'package:flutter/material.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/zutaten.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';

class EditPizzaScreen extends StatefulWidget {
  final int pizzaId;
  final Backend backend;
  final http.Client client;

  EditPizzaScreen(
      {required this.pizzaId, required this.backend, required this.client});

  @override
  _EditPizzaScreenState createState() => _EditPizzaScreenState();
}

class _EditPizzaScreenState extends State<EditPizzaScreen> {
  late Future<Pizza> futurePizza;
  List<Zutaten> availableZutaten = [];
  List<Zutaten> selectedZutaten = [];
  late double totalPrice = 0;
  late Pizza pizza;

  @override
  void initState() {
    super.initState();
    futurePizza = widget.backend
        .fetchPizzaById(widget.client, widget.pizzaId)
        .then((loadedPizza) {
      pizza = loadedPizza;
      totalPrice = pizza.preis;
      selectedZutaten = List.from(pizza.zutaten); // Ensure it's a new list
      _loadZutaten();
      return pizza;
    });
  }

  void _loadZutaten() async {
    try {
      List<Zutaten> zutaten =
          await widget.backend.fetchZutatenData(widget.client);
      setState(() {
        availableZutaten = zutaten;
      });
    } catch (e) {
      print('Fehler beim Laden der Zutaten: $e');
    }
  }

  void _toggleZutat(Zutaten zutat) {
    setState(() {
      final existingIndex =
          selectedZutaten.indexWhere((selected) => selected.name == zutat.name);
      if (existingIndex >= 0) {
        selectedZutaten.removeAt(existingIndex);
        totalPrice -= zutat.preis;
      } else {
        selectedZutaten.add(zutat);
        totalPrice += zutat.preis;
      }
    });
  }

  void _saveChanges() async {
    try {
      // Berechne den neuen Gesamtpreis basierend auf den initialen Preis der Pizza und den ausgewählten Zutaten
      double updatedPrice = pizza.preis +
          selectedZutaten.fold(0.0, (sum, zutat) => sum + zutat.preis);

      // Erstelle eine neue Pizza-Instanz mit aktualisierten Zutaten und dem korrekten Preis
      pizza = Pizza(
        id: pizza.id,
        name: pizza.name,
        beschreibung: pizza.beschreibung,
        preis: updatedPrice,
        imageUrl: pizza.imageUrl,
        zutaten: List.from(selectedZutaten),
      );

      print(pizza.toJson()); // Zum Debuggen

      // Lösche die Zutaten der Pizza
      final deleteResponse =
          await widget.backend.deleteZutatenByPizza(widget.client, pizza);
      if (deleteResponse.statusCode != 200) {
        throw Exception(
            'Failed to delete ingredients. Status code: ${deleteResponse.statusCode}, Body: ${deleteResponse.body}');
      }

      // Aktualisiere die Pizza-Daten im Backend
      final updateResponse = await widget.backend
          .updatePizzaById(widget.client, widget.pizzaId, pizza);
      if (updateResponse.statusCode == 200) {
        // Zeige eine Erfolgsmeldung an
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Änderungen gespeichert')),
        );

        // Navigiere zurück
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to update pizza. Status code: ${updateResponse.statusCode}, Body: ${updateResponse.body}');
      }
    } catch (e) {
      // Fehlerbehandlung und Anzeige einer detaillierteren Fehlermeldung
      String errorMessage = 'Fehler beim Speichern der Änderungen: $e';
      if (e is http.ClientException) {
        errorMessage = 'Netzwerkfehler: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

      // Optional: Fehlerprotokollierung für Debugging-Zwecke
      print('Fehler beim Aktualisieren der Pizza: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<Pizza>(
        future: futurePizza,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final pizza = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'assets/Pizza_Bilder/${pizza.imageUrl}',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 16,
                      child: IconButton(
                        icon: Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pizza.name,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${pizza.preis.toStringAsFixed(2)} €',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        pizza.beschreibung,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Zutaten',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      availableZutaten.isEmpty
                          ? CircularProgressIndicator()
                          : Column(
                              children: availableZutaten.map((zutat) {
                                bool isSelected = selectedZutaten.any(
                                    (selected) => selected.name == zutat.name);
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(zutat.name),
                                  subtitle: Text(
                                      '${zutat.preis.toStringAsFixed(2)} €'),
                                  trailing: isSelected
                                      ? Icon(Icons.check_box,
                                          color: Colors.green)
                                      : Icon(Icons.check_box_outline_blank),
                                  onTap: () {
                                    _toggleZutat(zutat);
                                  },
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          width: double.infinity,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextButton(
              onPressed: _saveChanges,
              child: Text(
                'Änderungen speichern • ${totalPrice.toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
