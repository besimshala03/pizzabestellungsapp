import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'update_bestellung_test.mocks.dart';

// Generiere Mock-Objekt für http.Client.
@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Update Bestellung', () {
    test('Test: Wirft Exception, falls Http Aufruf mit Fehler 404 endet.', () {
      final client = MockClient();
      final int id = 1;
      final Map<String, dynamic> bestellungDetails = {
        'pizzas': [],
        'getraenke': [],
        'preis': 20.0,
      };

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.put(
        Uri.parse('http://127.0.0.1:8080/bestellung/$id'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => backend.updateBestellung(client, id, bestellungDetails),
          throwsException);
    });

    test('Test: Erfolgreiches Update einer Bestellung.', () async {
      final client = MockClient();
      final int id = 1;
      final List<Pizza> pizzaList = [
        Pizza(
            id: 1,
            name: 'Margherita',
            beschreibung: 'Tomato, Mozzarella',
            preis: 10.0,
            imageUrl: 'Pizza_Margherita.jpeg'),
        Pizza(
            id: 2,
            name: 'Pepperoni',
            beschreibung: 'Tomato, Mozzarella, Pepperoni',
            preis: 12.0,
            imageUrl: 'Pizza_Salami.jpeg')
      ];
      final List<Getraenke> getraenkeList = [
        Getraenke(id: 1, name: 'Coke', preis: 2.5, imageUrl: 'Coca_Cola.png'),
        Getraenke(id: 2, name: 'Sprite', preis: 2.0, imageUrl: 'Sprite.png')
      ];
      final double preis = 26.5;

      final Map<String, dynamic> bestellungDetails = {
        'pizzas': pizzaList.map((pizza) => pizza.toJson()).toList(),
        'getraenke':
            getraenkeList.map((getraenk) => getraenk.toJson()).toList(),
        'preis': preis,
        'datumUhrzeit': '2024-06-30T12:00:00',
        'adresse': 'Teststraße 123',
        'kundenname': 'Max Mustermann',
      };

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.put(
        Uri.parse('http://127.0.0.1:8080/bestellung/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bestellungDetails),
      )).thenAnswer(
          (_) async => http.Response('{"success": true}', 200, headers: {
                'Content-Type': 'application/json; charset=utf-8',
              }));

      await backend.updateBestellung(client, id, bestellungDetails);

      // Verifizieren, dass die Methode tatsächlich aufgerufen wurde
      verify(client.put(
        Uri.parse('http://127.0.0.1:8080/bestellung/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bestellungDetails),
      )).called(1);
    });
  });
}
