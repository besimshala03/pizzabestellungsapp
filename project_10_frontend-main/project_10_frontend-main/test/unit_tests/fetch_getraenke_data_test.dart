import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';

import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'fetch_getraenke_data_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Getränke Data', () {
    test('Test: Erfolgreiches Abrufen der Getränke', () async {
      final client = MockClient();
      final getraenkeJson = [
        {'id': 1, 'name': 'Getränk 1', 'preis': 3.5},
        {'id': 2, 'name': 'Getränk 2', 'preis': 2.5},
        {'id': 3, 'name': 'Getränk 3', 'preis': 4.0},
      ];

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/getraenke'))).thenAnswer(
          (_) async => http.Response(jsonEncode(getraenkeJson), 200,
              headers: {'content-type': 'application/json'}));

      // Aufruf der Methode, die getestet werden soll
      final fetchedGetraenke = await backend.fetchGetraenkeData(client);

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/getraenke')))
          .called(1);

      // Überprüfe die zurückgegebenen Getränke.
      expect(fetchedGetraenke, isA<List<Getraenke>>());
      expect(fetchedGetraenke.length, getraenkeJson.length);
      expect(fetchedGetraenke[0].id, getraenkeJson[0]['id']);
      expect(fetchedGetraenke[0].name, getraenkeJson[0]['name']);
      expect(fetchedGetraenke[0].preis, getraenkeJson[0]['preis']);
    });

    test('Test: Fehler beim Abrufen der Getränke', () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('http://127.0.0.1:8080/getraenke'))).thenAnswer(
          (_) async => http.Response('Failed to load Getränke', 404));

      // Erwartung, dass eine Exception geworfen wird
      expect(
        () async => await backend.fetchGetraenkeData(client),
        throwsException,
      );

      // Verifiziere, dass die GET Anfrage gesendet wurde.
      verify(client.get(Uri.parse('http://127.0.0.1:8080/getraenke')))
          .called(1);
    });
  });
}
