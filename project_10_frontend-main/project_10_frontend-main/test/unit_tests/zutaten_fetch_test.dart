import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/zutaten.dart';
import 'zutaten_fetch_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Zutaten Data', () {
    test('Test: Erfolgreiches Abrufen der Zutaten', () async {
      final client = MockClient();
      final zutatenJson = [
        {'id': 1, 'name': 'Zutat 1'},
        {'id': 2, 'name': 'Zutat 2'},
        {'id': 3, 'name': 'Zutat 3'}
      ];

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/zutaten'))).thenAnswer(
          (_) async => http.Response(jsonEncode(zutatenJson), 200,
              headers: {'content-type': 'application/json'}));

      final fetchedZutaten = await backend.fetchZutatenData(client);

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/zutaten'))).called(1);

      // Überprüfe die zurückgegebenen Zutaten.
      expect(fetchedZutaten, isA<List<Zutaten>>());
      expect(fetchedZutaten.length, zutatenJson.length);
      expect(fetchedZutaten[0].id, zutatenJson[0]['id']);
      expect(fetchedZutaten[0].name, zutatenJson[0]['name']);
    });

    test('Test: Fehler beim Abrufen der Zutaten', () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/zutaten'))).thenAnswer(
          (_) async => http.Response('Failed to load Zutaten', 400));

      expect(
        () async => await backend.fetchZutatenData(client),
        throwsException,
      );

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/zutaten'))).called(1);
    });
  });
}
