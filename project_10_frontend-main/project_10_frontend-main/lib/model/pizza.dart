import 'package:project_10_frontend/model/MenuItemBase.dart';
import 'package:project_10_frontend/model/zutaten.dart';

class Pizza implements MenuItemBase {
  final int id;
  late final String name;
  late final String beschreibung;
  late final double preis;
  final String imageUrl;
  final List<Zutaten> zutaten;

  Pizza(
      {required this.id,
      required this.name,
      required this.beschreibung,
      required this.preis,
      required this.imageUrl,
      this.zutaten = const []});

  factory Pizza.fromJson(Map<String, dynamic> json) {
    return Pizza(
      id: json['id'],
      name: json['name'],
      beschreibung: json['beschreibung'],
      preis: json['preis'],
      imageUrl: json['imageUrl'],
      zutaten: (json['zutaten'] as List<dynamic>? ?? [])
          .map((item) => Zutaten.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'beschreibung': beschreibung,
      'preis': preis,
      'imageUrl': imageUrl,
      'zutaten': zutaten.map((zutat) => zutat.toJson()).toList(),
    };
  }
}
