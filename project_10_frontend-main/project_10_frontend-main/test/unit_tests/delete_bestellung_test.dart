import 'package:project_10_frontend/backend/backend.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'delete_bestellung_test.mocks.dart';

const _backend = "http://127.0.0.1:8080/bestellung";

// Generiere Mock-Objekt für http.Client.
@GenerateMocks([http.Client])
void main() {
  Backend backend = Backend();
  group('Delete Bestellung', () {
    test('Test: Wirft Exception, falls Http Aufruf mit Fehler 404 endet.', () {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.delete(Uri.parse('$_backend/1')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => backend.deleteBestellung(client, 1), throwsException);
    });

    test('Test: Erfolgreiches Löschen einer Bestellung.', () async {
      final client = MockClient();

      // Mock-Objekt liefert bei entsprechender Anfrage vordefinierte Antwort.
      when(client.delete(Uri.parse('$_backend/1')))
          .thenAnswer((_) async => http.Response('Deleted', 200));

      await backend.deleteBestellung(client, 1);

      // Hier überprüfen wir, dass keine Exception geworfen wird und der Aufruf erfolgreich ist.
      verify(client.delete(Uri.parse('$_backend/1'))).called(1);
    });
  });
}
