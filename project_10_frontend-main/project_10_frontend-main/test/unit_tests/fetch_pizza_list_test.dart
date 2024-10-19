import 'package:project_10_frontend/backend/backend.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'fetch_pizza_list_test.mocks.dart';

// Generiere Mock-Objekt für http.Client.
@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Pizza List', () {
    test('Test: Erfolgreiches Abrufen der Pizza-Liste', () async {
      final client = MockClient();
      final pizzas = [
        {
          'id': 1,
          'name': 'Margherita',
          'beschreibung': 'Classic',
          'preis': 10.0,
          'imageUrl': 'Pizza_Margherita.jpeg',
          'zutaten': []
        },
        {
          'id': 2,
          'name': 'Pepperoni',
          'beschreibung': 'Spicy',
          'preis': 12.0,
          'imageUrl': 'Pizza_Pepperoni.jpeg',
          'zutaten': []
        }
      ];

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/pizza')))
          .thenAnswer((_) async => http.Response(jsonEncode(pizzas), 200));

      final fetchedPizzas = await backend.fetchPizzaList(client);

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/pizza'))).called(1);

      // Überprüfe die zurückgegebene Pizza-Liste.
      expect(fetchedPizzas.length, 2);
      expect(fetchedPizzas[0].name, 'Margherita');
      expect(fetchedPizzas[1].name, 'Pepperoni');
    });

    test('Test: Fehler beim Abrufen der Pizza-Liste', () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/pizza'))).thenAnswer(
          (_) async => http.Response('Failed to load pizza list', 400));

      expect(
        () async => await backend.fetchPizzaList(client),
        throwsException,
      );

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/pizza'))).called(1);
    });
  });
}
