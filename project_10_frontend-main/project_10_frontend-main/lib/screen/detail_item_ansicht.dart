import 'package:flutter/material.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/zutaten.dart';
import 'package:http/http.dart' as http;
import 'package:project_10_frontend/warenkorb/cart.dart';

class PizzaDetailScreen extends StatefulWidget {
  final Pizza pizza;
  final Backend backend;
  final http.Client client;

  PizzaDetailScreen(
      {required this.pizza, required this.backend, required this.client});

  @override
  _PizzaDetailScreenState createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends State<PizzaDetailScreen> {
  List<Zutaten> selectedZutaten = [];
  List<Zutaten> availableZutaten = [];
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    totalPrice = widget.pizza.preis;
    _loadZutaten();
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
      if (selectedZutaten.contains(zutat)) {
        selectedZutaten.remove(zutat);
        totalPrice -= zutat.preis;
      } else {
        selectedZutaten.add(zutat);
        totalPrice += zutat.preis;
      }
    });
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/Pizza_Bilder/${widget.pizza.imageUrl}',
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
                    widget.pizza.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.pizza.preis.toStringAsFixed(2)} €',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.pizza.beschreibung,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  availableZutaten.isEmpty
                      ? CircularProgressIndicator()
                      : Column(
                          children: availableZutaten.map((zutat) {
                            bool isSelected = selectedZutaten.contains(zutat);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(zutat.name),
                              subtitle:
                                  Text('${zutat.preis.toStringAsFixed(2)} €'),
                              trailing: isSelected
                                  ? Icon(Icons.check_box, color: Colors.green)
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
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          width: double.infinity,
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextButton(
              key: Key("Add"),
              onPressed: () {
                // Erstellen einer neuen Pizza-Instanz mit den ausgewählten Zutaten
                final pizzaMitZutaten = Pizza(
                  id: widget.pizza.id,
                  name: widget.pizza.name,
                  beschreibung: widget.pizza.beschreibung,
                  preis: totalPrice,
                  imageUrl: widget.pizza.imageUrl,
                  zutaten: selectedZutaten,
                );

                // Artikel zum Warenkorb hinzufügen
                Cart().addItem(pizzaMitZutaten);
                print(pizzaMitZutaten);
                print(Cart().items);

                // Zurück zur Übersicht navigieren
                Navigator.pop(context);
              },
              child: Text(
                'Dem Warenkorb hinzufügen • ${totalPrice.toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
