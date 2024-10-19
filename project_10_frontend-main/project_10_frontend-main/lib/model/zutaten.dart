class Zutaten {
  int id;
  String name;
  double preis;

  Zutaten({required this.id, required this.name, required this.preis});

  factory Zutaten.fromJson(Map<String, dynamic> json) {
    return Zutaten(
      id: json['id'] as int,
      name: json['name'] as String,
      preis: json['preis'] != null ? json['preis'].toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'preis': preis,
    };
  }
}
