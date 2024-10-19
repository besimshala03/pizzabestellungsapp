import 'package:project_10_frontend/model/MenuItemBase.dart';

class Getraenke implements MenuItemBase {
  int id;
  String name;
  double preis;
  String imageUrl;

  Getraenke(
      {required this.id,
      required this.name,
      required this.preis,
      required this.imageUrl});

  factory Getraenke.fromJson(Map<String, dynamic> json) {
    return Getraenke(
      id: json['id'],
      name: json['name'] ?? '',
      preis: json['preis'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'preis': preis,
      'imageUrl': imageUrl,
    };
  }
}
