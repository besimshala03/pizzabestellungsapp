import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/Bestellung.dart';
import 'package:project_10_frontend/screen/edit_pizza_page.dart';
import 'package:project_10_frontend/screen/main_page.dart'; // Import the main page

class BestellungDetailsWidget extends StatefulWidget {
  final int bestellungId;
  final Backend backend;
  final http.Client client;

  const BestellungDetailsWidget(
      {super.key,
      required this.bestellungId,
      required this.backend,
      required this.client});

  @override
  _BestellungDetailsWidgetState createState() =>
      _BestellungDetailsWidgetState();
}

class _BestellungDetailsWidgetState extends State<BestellungDetailsWidget> {
  late Future<Bestellung> futureBestellung;
  bool isExpanded = false;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _timeController = TextEditingController(); // Controller for order time

  @override
  void initState() {
    super.initState();
    futureBestellung = widget.backend
        .fetchBestellungById(widget.client, widget.bestellungId)
        .then((bestellung) {
      _nameController.text = bestellung.adresse;
      _addressController.text = bestellung.kundenname;
      _timeController.text = bestellung
          .datumUhrzeit; // Assuming 'bestellzeit' is the correct field
      return bestellung;
    });
  }

  void _saveChanges(Bestellung bestellung) async {
    final updatedBestellungDetails = {
      'kundenname': _addressController.text,
      'adresse': _nameController.text,
      'datumUhrzeit': _timeController.text,
      'pizza': bestellung.pizza
          .map((pizza) => {
                'id': pizza.id,
                'name': pizza.name,
                'beschreibung': pizza.beschreibung,
                'preis': pizza.preis,
                'imageUrl': pizza.imageUrl,
                'zutaten': pizza.zutaten
                    .map((zutat) => {
                          'id': zutat.id,
                          'name': zutat.name,
                          'preis': zutat.preis,
                        })
                    .toList(),
              })
          .toList(),
      'getraenke': bestellung.getraenke
          .map((getraenk) => {
                'id': getraenk.id,
                'name': getraenk.name,
                'preis': getraenk.preis,
                'imageUrl': getraenk.imageUrl,
              })
          .toList(),
      'preis': bestellung.preis,
    };

    try {
      await widget.backend.updateBestellung(
          widget.client, widget.bestellungId, updatedBestellungDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Änderungen gespeichert')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(
                widget.backend, widget.client)), // Navigate back to the main page
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern der Änderungen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bestellung Details'),
      ),
      body: FutureBuilder<Bestellung>(
        future: futureBestellung,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final bestellung = snapshot.data!;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    key: Key("name"),
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Kundenname',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    key: Key("address"),
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Bestellzeit',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // Make the time field read-only
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child:
                        Text(isExpanded ? 'Weniger anzeigen' : 'Mehr anzeigen'),
                  ),
                  if (isExpanded) ...[
                    ...bestellung.pizza
                        .map((pizza) => ListTile(
                              leading: Image.asset(
                                  'assets/Pizza_Bilder/${pizza.imageUrl}',
                                  width: 50,
                                  height: 50),
                              title: Text(pizza.name),
                              subtitle: Text('${pizza.preis}€ - Pizza'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Edit action here
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditPizzaScreen(
                                            pizzaId: pizza.id,
                                            backend: widget.backend,
                                            client: widget.client,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      // Delete action here
                                      widget.backend.deletePizzaById(
                                          widget.client, pizza.id);
                                      setState(() {
                                        bestellung.pizza.removeWhere(
                                            (item) => item.id == pizza.id);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    ...bestellung.getraenke
                        .map((getraenk) => ListTile(
                              leading: Image.asset(
                                  'assets/Getreanke_Bilder/${getraenk.imageUrl}',
                                  width: 50,
                                  height: 50),
                              title: Text(getraenk.name),
                              subtitle: Text('${getraenk.preis}€ - Getränk'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  // Delete action here
                                  widget.backend.deleteGetraenkeById(
                                      widget.client, getraenk.id);
                                  setState(() {
                                    bestellung.getraenke.removeWhere(
                                        (item) => item.id == getraenk.id);
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      key: Key("änderung speichern"),
                      onPressed: () => _saveChanges(bestellung),
                      child: Text('Änderungen speichern'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
