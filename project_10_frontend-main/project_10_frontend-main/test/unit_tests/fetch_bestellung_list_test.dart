import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/Bestellung.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'fetch_bestellung_list_test.mocks.dart';

// Generiere Mock-Objekt für http.Client.
@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Bestellung List', () {
    test('Test: Wirft Exception, falls Http Aufruf mit Fehler 404 endet.', () {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(backend.fetchBestellungList(client), throwsException);
    });

    test('Test: Liefert eine leere Liste von Bestellungen vom Server.',
        () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
          .thenAnswer((_) async => http.Response('[]', 200));

      List<Bestellung> result = await backend.fetchBestellungList(client);
      expect(result, isA<List<Bestellung>>());
      expect(result.length, 0);
    });

    test('Test: Liefert eine Liste von Bestellungen vom Server.', () async {
      final client = MockClient();

      // Beispiel-JSON-Antwort, die eine Liste von Bestellungen enthält.
      const responseBody = '''
      [
        {
          "id": 1,
          "pizzas": [
            {
              "id": 1,
              "name": "Margherita",
              "beschreibung": "Tomato, Mozzarella",
              "preis": 7.5,
              "imageUrl": "url",
              "zutaten": []
            }
          ],
          "getraenke": [
            {
              "id": 1,
              "name": "Coke",
              "preis": 1.5,
              "imageUrl": "url"
            }
          ],
          "preis": 9.0,
          "datumUhrzeit": "2023-06-30T12:34:56",
          "adresse": "Example Street 1",
          "kundenname": "John Doe"
        }
      ]
      ''';

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      List<Bestellung> result = await backend.fetchBestellungList(client);
      expect(result, isA<List<Bestellung>>());
      expect(result.length, 1);
      expect(result[0].id, 1);
      expect(result[0].kundenname, 'John Doe');
      expect(result[0].pizza[0].name, 'Margherita');
      expect(result[0].getraenke[0].name, 'Coke');
    });
  });
}
