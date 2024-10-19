import 'package:project_10_frontend/backend/backend.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'dart:convert';
import 'create_pizza_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Create Pizza', () {
    test('Test: Erfolgreiches Erstellen einer Pizza', () async {
      final client = MockClient();
      const name = "Margherita";
      const description = "Classic";

      when(client.post(
        Uri.parse('http://127.0.0.1:8080/item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'id': 1,
              'name': name,
              'beschreibung': description,
              'preis': 0.0,
              'imageUrl': ''
            }),
            200,
          ));

      final pizza = await backend.createPizza(client, name, description);

      verify(client.post(
        Uri.parse('http://127.0.0.1:8080/item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      )).called(1);

      expect(pizza.id, 1);
      expect(pizza.name, name);
      expect(pizza.beschreibung, description);
    });

    test('Test: Fehler beim Erstellen einer Pizza', () async {
      final client = MockClient();
      const name = "Margherita";
      const description = "Classic";

      when(client.post(
        Uri.parse('http://127.0.0.1:8080/item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      )).thenAnswer((_) async => http.Response('Failed to create item', 400));

      expect(
        () async => await backend.createPizza(client, name, description),
        throwsException,
      );

      verify(client.post(
        Uri.parse('http://127.0.0.1:8080/item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      )).called(1);
    });
  });
}
