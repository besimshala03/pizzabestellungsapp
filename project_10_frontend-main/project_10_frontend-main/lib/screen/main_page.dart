// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/Bestellung.dart';
import 'package:http/http.dart' as http;
import 'package:project_10_frontend/screen/item_uebersicht_page.dart';
import 'package:project_10_frontend/screen/edit_item_page.dart';

class MainPage extends StatefulWidget {
  final Backend _backend;
  final http.Client _client;

  MainPage(this._backend, this._client);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Bestellung>> _bestellungenFuture;

  @override
  void initState() {
    super.initState();
    _bestellungenFuture = _loadBestellungen();
  }

  Future<List<Bestellung>> _loadBestellungen() async {
    try {
      final bestellungen =
          await widget._backend.fetchBestellungList(widget._client);
      return bestellungen;
    } catch (e) {
      print('Fehler beim Laden der Bestellungen: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Bestellübersicht'),
      ),
      body: FutureBuilder<List<Bestellung>>(
        future: _bestellungenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Keine Bestellungen vorhanden'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final bestellung = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text('Bestellung ${bestellung.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Anzahl Pizzen: ${bestellung.pizza.length}'),
                        Text('Anzahl Getränke: ${bestellung.getraenke.length}'),
                        Text(
                            'Gesamtpreis: ${bestellung.preis.toStringAsFixed(2)} €'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: Key("Edit"),
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BestellungDetailsWidget(
                                      bestellungId: bestellung.id,
                                      backend: Backend(),
                                      client: widget._client)),
                            );
                          },
                        ),
                        IconButton(
                          key: Key("Delete"),
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            try {
                              await widget._backend.deleteBestellung(
                                  widget._client, bestellung.id);
                              setState(() {
                                _bestellungenFuture = _loadBestellungen();
                              });
                            } catch (e) {
                              print('Fehler beim Löschen der Bestellung: $e');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New',
        onPressed: () => showDialog<bool>(
          context: context,
          builder: (BuildContext context) => Dialog.fullscreen(
            child: PizzaMenu(backend: widget._backend, client: widget._client),
          ),
        ).then((_) => setState(() {
              _bestellungenFuture = _loadBestellungen();
            })),
        child: Icon(Icons.add),
      ),
    );
  }
}
