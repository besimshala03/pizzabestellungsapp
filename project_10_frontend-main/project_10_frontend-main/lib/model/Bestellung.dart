import 'package:project_10_frontend/model/getraenke.dart';
import 'package:project_10_frontend/model/pizza.dart';

class Bestellung {
  final int id;
  final List<Pizza> pizza;
  final List<Getraenke> getraenke;
  final double preis;
  final String datumUhrzeit;
  final String adresse;
  final String kundenname;

  Bestellung({
    required this.id,
    this.pizza = const [],
    this.getraenke = const [],
    required this.preis,
    required this.datumUhrzeit,
    required this.adresse,
    required this.kundenname,
  });

  factory Bestellung.fromJson(Map<String, dynamic> json) {
    var pizzaList = (json['pizzas'] as List?) ?? [];
    var getraenkeList = (json['getraenke'] as List?) ?? [];

    List<Pizza> pizzas = pizzaList.map((i) => Pizza.fromJson(i)).toList();
    List<Getraenke> getraenkes =
        getraenkeList.map((i) => Getraenke.fromJson(i)).toList();

    return Bestellung(
      id: json['id'],
      pizza: pizzas,
      getraenke: getraenkes,
      preis: json['preis'].toDouble(),
      datumUhrzeit: json['datumUhrzeit'] ?? '',
      adresse: json['adresse'] ?? '',
      kundenname: json['kundenname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pizza': pizza
          .map((p) => p.toJson())
          .toList(), // serialisieren der Pizza Liste
      'getraenke': getraenke
          .map((g) => g.toJson())
          .toList(), // serialisieren der Getraenke Liste
      'preis': preis,
      'datumUhrzeit': datumUhrzeit,
      'adresse': adresse,
      'kundenname': kundenname,
    };
  }

  double calculateTotal() {
    double total = 0;

    for (var pizza in pizza) {
      total += pizza.preis;
    }

    for (var getraenke in getraenke) {
      total += getraenke.preis;
    }

    return total;
  }
}
