import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'add_Bestellung_test.mocks.dart';

// Generiere Mock-Objekt für http.Client.
@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Add Bestellung', () {
    test('Test: Erfolgreiche Bestellungserstellung', () async {
      final client = MockClient();
      final pizzas = [
        Pizza(
            id: 1,
            name: "Margherita",
            beschreibung: "Classic",
            preis: 10.0,
            imageUrl: "Pizza_Margherita.jpeg")
      ];
      final getraenke = [
        Getraenke(id: 1, name: "Coke", preis: 2.0, imageUrl: "Coca_Cola.png")
      ];
      const preis = 12.0;
      const datumUhrzeit = "2023-06-30 18:00:00";
      const adresse = "Teststraße 123";
      const kundenname = "Max Mustermann";

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.post(
        Uri.parse('http://127.0.0.1:8080/bestellung'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pizzas': pizzas.map((pizza) => pizza.toJson()).toList(),
          'getraenke': getraenke.map((getraenk) => getraenk.toJson()).toList(),
          'totalPrice': preis,
          'datumUhrzeit': datumUhrzeit,
          'adresse': adresse,
          'kundenname': kundenname,
        }),
      )).thenAnswer((_) async => http.Response('{"status": "success"}', 200));

      await backend.addBestellung(
          client, pizzas, getraenke, preis, datumUhrzeit, adresse, kundenname);

      // Verifiziere, dass die POST Anfrage gesendet wurde.
      verify(client.post(
        Uri.parse('http://127.0.0.1:8080/bestellung'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pizzas': pizzas.map((pizza) => pizza.toJson()).toList(),
          'getraenke': getraenke.map((getraenk) => getraenk.toJson()).toList(),
          'totalPrice': preis,
          'datumUhrzeit': datumUhrzeit,
          'adresse': adresse,
          'kundenname': kundenname,
        }),
      )).called(1);
    });

    test('Test: Fehler beim Erstellen einer Bestellung', () async {
      final client = MockClient();
      final pizzas = [
        Pizza(
            id: 1,
            name: "Margherita",
            beschreibung: "Classic",
            preis: 10.0,
            imageUrl: "url")
      ];
      final getraenke = [
        Getraenke(id: 1, name: "Coke", preis: 2.0, imageUrl: "url")
      ];
      const preis = 12.0;
      const datumUhrzeit = "2023-06-30 18:00:00";
      const adresse = "Teststraße 123";
      const kundenname = "Max Mustermann";

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.post(
        Uri.parse('http://127.0.0.1:8080/bestellung'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pizzas': pizzas.map((pizza) => pizza.toJson()).toList(),
          'getraenke': getraenke.map((getraenk) => getraenk.toJson()).toList(),
          'totalPrice': preis,
          'datumUhrzeit': datumUhrzeit,
          'adresse': adresse,
          'kundenname': kundenname,
        }),
      )).thenAnswer(
          (_) async => http.Response('Failed to add Bestellung', 400));

      expect(
        () async => await backend.addBestellung(client, pizzas, getraenke,
            preis, datumUhrzeit, adresse, kundenname),
        throwsException,
      );

      // Verifiziere, dass die POST Anfrage gesendet wurde.
      verify(client.post(
        Uri.parse('http://127.0.0.1:8080/bestellung'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pizzas': pizzas.map((pizza) => pizza.toJson()).toList(),
          'getraenke': getraenke.map((getraenk) => getraenk.toJson()).toList(),
          'totalPrice': preis,
          'datumUhrzeit': datumUhrzeit,
          'adresse': adresse,
          'kundenname': kundenname,
        }),
      )).called(1);
    });
  });
}
