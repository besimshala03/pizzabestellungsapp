import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:project_10_frontend/backend/backend.dart';
import 'fetch_zutat_by_id_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Zutat by ID', () {
    test('Test: Erfolgreiches Abrufen der Zutat nach ID', () async {
      final client = MockClient();
      final zutatJson = {
        'id': 1,
        'name': 'Zutat 1',
        'preis': 5.0,
      };

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/zutaten/1'))).thenAnswer(
          (_) async => http.Response(jsonEncode(zutatJson), 200,
              headers: {'content-type': 'application/json'}));

      final fetchedZutat = await backend.fetchZutatById(client, 1);

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/zutaten/1')))
          .called(1);

      // Überprüfe die zurückgegebene Zutat.
      expect(fetchedZutat.id, 1);
      expect(fetchedZutat.name, 'Zutat 1');
      expect(fetchedZutat.preis, 5.0);
    });

    test('Test: Fehler beim Abrufen der Zutat nach ID', () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/zutaten/1')))
          .thenAnswer((_) async => http.Response('Failed to load Zutat', 404));

      expect(
        () async => await backend.fetchZutatById(client, 1),
        throwsException,
      );

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/zutaten/1')))
          .called(1);
    });
  });
}
