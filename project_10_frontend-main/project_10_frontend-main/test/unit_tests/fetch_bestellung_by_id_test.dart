import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/Bestellung.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'fetch_bestellung_by_id_test.mocks.dart';

// Generiere Mock-Objekt für http.Client.
@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Bestellung By ID', () {
    test('Test: Wirft Exception, falls Http Aufruf mit Fehler 404 endet.', () {
      final client = MockClient();
      final int id = 1;

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(
        Uri.parse('http://127.0.0.1:8080/bestellung/$id'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => backend.fetchBestellungById(client, id), throwsException);
    });

    test('Test: Erfolgreiches Abrufen einer Bestellung.', () async {
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

      final Map<String, dynamic> responseData = {
        'id': id,
        'pizzas': pizzaList.map((pizza) => pizza.toJson()).toList(),
        'getraenke':
            getraenkeList.map((getraenk) => getraenk.toJson()).toList(),
        'preis': preis,
        'datumUhrzeit': '2024-06-30T12:00:00',
        'adresse': 'Teststraße 123',
        'kundenname': 'Max Mustermann',
      };

      // Codieren Sie die JSON-Antwort als UTF-8 Bytes.
      final responseBody = jsonEncode(responseData);
      final responseBytes = utf8.encode(responseBody);

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(
        Uri.parse('http://127.0.0.1:8080/bestellung/$id'),
        headers: anyNamed('headers'),
      )).thenAnswer(
          (_) async => http.Response.bytes(responseBytes, 200, headers: {
                'Content-Type': 'application/json; charset=utf-8',
              }));

      Bestellung result = await backend.fetchBestellungById(client, id);

      expect(result, isA<Bestellung>());
      expect(result.id, id);
      expect(result.pizza.length, pizzaList.length);
      expect(result.getraenke.length, getraenkeList.length);
      expect(result.preis, preis);
      expect(result.datumUhrzeit, '2024-06-30T12:00:00');
      expect(result.adresse, 'Teststraße 123');
      expect(result.kundenname, 'Max Mustermann');
      expect(result.pizza[0].name, 'Margherita');
      expect(result.pizza[1].name, 'Pepperoni');
      expect(result.getraenke[0].name, 'Coke');
      expect(result.getraenke[1].name, 'Sprite');
    });
  });
}
