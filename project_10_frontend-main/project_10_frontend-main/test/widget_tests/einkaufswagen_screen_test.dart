import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/warenkorb/cart.dart';
import 'package:project_10_frontend/screen/einkaufswagen.dart';
import 'package:http/http.dart' as http;

import 'einkaufswagen_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Backend backend;
  late MockClient mockClient;
  late Cart cart;
  late Pizza pizza;

  setUp(() {
    backend = Backend();
    mockClient = MockClient();
    cart = Cart();
    pizza = Pizza(
        id: 1,
        name: 'Pizza Margherita',
        beschreibung: 'test',
        preis: 8.5,
        imageUrl: 'Pizza_Margherita.jpeg',
        zutaten: []);
    cart.addItem(pizza);

    // Mock the client to return a successful response
    when(mockClient.post(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 200));
  });

  tearDown(() {
    reset(mockClient); // Reset mock client between tests
    cart.clear(); // Clear cart between tests
  });

  testWidgets('zeigt Artikel im Warenkorb an', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Einkaufswagen(
        cart: cart,
        backend: backend,
        client: mockClient,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Pizza Margherita'), findsOneWidget);
    expect(find.text('8.50 €'), findsNWidgets(2));
  });

  testWidgets('entfernt einen Artikel aus dem Warenkorb',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Einkaufswagen(
        cart: cart,
        backend: backend,
        client: mockClient,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    expect(cart.items.contains(pizza), false);
  });

  testWidgets('fügt eine Bestellung erfolgreich hinzu',
      (WidgetTester tester) async {
    when(mockClient.post(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 200));

    await tester.pumpWidget(MaterialApp(
      home: Einkaufswagen(
        cart: cart,
        backend: backend,
        client: mockClient,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField).at(0), 'Maximilian Mustermännchen');
    await tester.enterText(find.byType(TextField).at(1), 'Lauingerstraße 11');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(cart.items.isEmpty, true);
  });

  testWidgets(
      'zeigt eine Fehlermeldung an, wenn das Hinzufügen der Bestellung fehlschlägt',
      (WidgetTester tester) async {
    when(mockClient.post(any,
            body: anyNamed('body'), headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('{"status": "error"}', 400));

    await tester.pumpWidget(MaterialApp(
      home: Einkaufswagen(
        cart: cart,
        backend: backend,
        client: mockClient,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextField).at(0), 'Maximilian Maximilian Mustermännchen');
    await tester.enterText(find.byType(TextField).at(1), 'Lauingerstraße 11');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Fehler beim Hinzufügen der Bestellung'), findsOneWidget);
  });
}
