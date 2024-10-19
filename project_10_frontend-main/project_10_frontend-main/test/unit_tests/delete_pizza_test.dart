import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project_10_frontend/backend/backend.dart'; 

import 'delete_pizza_test.mocks.dart'; 

@GenerateMocks([http.Client])
void main() {
  group('deletePizzaById', () {
    late MockClient mockClient;
    late Backend backend;

    setUp(() {
      mockClient = MockClient();
      backend = Backend();
    });

    test('returns success message if the http call completes successfully', () async {
      final int pizzaId = 1;
      final url = Uri.parse('http://127.0.0.1:8080/pizza/$pizzaId');

      // Mocking the http delete response to return a successful status code.
      when(mockClient.delete(url)).thenAnswer((_) async => http.Response('{"status": "success"}', 200));

      // Call the method
      final result = await backend.deletePizzaById(mockClient, pizzaId);

      // Verify the method returns the expected result
      expect(result, "Pizza erfolgreich gelöscht");
    });

    test('throws an exception if the http call completes with an error', () async {
      final int pizzaId = 1;
      final url = Uri.parse('http://127.0.0.1:8080/pizza/$pizzaId');

      // Mocking the http delete response to return an error status code.
      when(mockClient.delete(url)).thenAnswer((_) async => http.Response('{"error": "Not found"}', 404));

      // Expect the method to throw an exception
      expect(
        () async => await backend.deletePizzaById(mockClient, pizzaId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
