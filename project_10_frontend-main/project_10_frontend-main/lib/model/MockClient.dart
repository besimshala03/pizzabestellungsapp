import 'dart:convert';
import 'package:http/http.dart' as http;

class MockClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Mock-Antworten basierend auf der Request-URL
    if (request.url.path == '/pizzas') {
      // Beispielantwort für die '/pizzas' Endpunkt
      return http.StreamedResponse(
        Stream.fromIterable([
          utf8.encode(jsonEncode([
            {'name': 'Margherita', 'price': 8.99},
            {'name': 'Pepperoni', 'price': 10.99},
            {'name': 'Vegetarian', 'price': 9.99},
          ]))
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    } else {
      // Andere Endpunkte können ebenfalls behandelt werden
      return http.StreamedResponse(
        Stream.fromIterable([utf8.encode('Not Found')]),
        404,
      );
    }
  }
}
