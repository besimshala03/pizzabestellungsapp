import 'package:project_10_frontend/backend/backend.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'fetch_pizza_by_id_test.mocks.dart';

// Generiere Mock-Objekt für http.Client.
@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Pizza by ID', () {
    test('Test: Erfolgreiches Abrufen der Pizza nach ID', () async {
      final client = MockClient();
      final pizza = {
        'id': 1,
        'name': 'Margherita',
        'beschreibung': 'Classic',
        'preis': 10.0,
        'imageUrl': 'Pizza_Margherita.jpeg',
        'zutaten': []
      };

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/pizza/1')))
          .thenAnswer((_) async => http.Response(jsonEncode(pizza), 200));

      final fetchedPizza = await backend.fetchPizzaById(client, 1);

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/pizza/1'))).called(1);

      // Überprüfe die zurückgegebene Pizza.
      expect(fetchedPizza.id, 1);
      expect(fetchedPizza.name, 'Margherita');
      expect(fetchedPizza.beschreibung, 'Classic');
    });

    test('Test: Fehler beim Abrufen der Pizza nach ID', () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/pizza/1')))
          .thenAnswer((_) async => http.Response('Failed to load pizza', 400));

      expect(
        () async => await backend.fetchPizzaById(client, 1),
        throwsException,
      );

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/pizza/1'))).called(1);
    });
  });
}
