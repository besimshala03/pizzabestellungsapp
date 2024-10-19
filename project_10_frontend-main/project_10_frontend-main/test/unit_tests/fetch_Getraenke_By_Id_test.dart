import 'package:project_10_frontend/model/getraenke.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'fetch_Getraenke_By_Id_test.mocks.dart';

const _backend = "http://127.0.0.1:8080/";

@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();

  group('Fetch Getraenke by ID', () {
    test('Test: Wirft Exception, falls Http Aufruf mit Fehler 404 endet.', () {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('${_backend}getraenke/1')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(backend.fetchGetraenkeById(client, 1), throwsException);
    });

    test('Test: Liefert ein Getraenke-Objekt vom Server.', () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('${_backend}getraenke/1'))).thenAnswer(
          (_) async => http.Response(
              '{"id": 1, "name": "Cola", "preis": 2.5, "imageUrl": "Coca_Cola.png"}',
              200));

      Getraenke result = await backend.fetchGetraenkeById(client, 1);
      expect(result, isA<Getraenke>());
      expect(result.id, 1);
      expect(result.name, "Cola");
      expect(result.preis, 2.5);
      expect(result.imageUrl, "Coca_Cola.png");
    });

    test('Test: Wirft Exception, falls Http Aufruf mit Fehler 500 endet.', () {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.get(Uri.parse('${_backend}getraenke/1')))
          .thenAnswer((_) async => http.Response('Internal Server Error', 500));

      expect(backend.fetchGetraenkeById(client, 1), throwsException);
    });
  });
}
