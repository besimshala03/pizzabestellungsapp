import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/zutaten.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/screen/detail_item_ansicht.dart';
import 'package:project_10_frontend/warenkorb/cart.dart';
import 'package:http/http.dart' as http;

class MockBackend extends Backend {
  @override
  Future<List<Zutaten>> fetchZutatenData(http.Client client) async {
    return [
      Zutaten(id: 1, name: 'Tomate', preis: 1.0),
      Zutaten(id: 2, name: 'Käse', preis: 1.5),
      Zutaten(id: 3, name: 'Salami', preis: 2.0),
    ];
  }
}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  testWidgets('PizzaDetailScreen test', (WidgetTester tester) async {
    final pizza = Pizza(
      id: 1,
      name: 'Margherita',
      beschreibung: 'Klassische Pizza Margherita',
      preis: 8.5,
      imageUrl: 'Pizza_Margherita.jpeg',
      zutaten: [],
    );
    final backend = MockBackend();
    final client = MockHttpClient();

    // Build the PizzaDetailScreen widget.
    await tester.pumpWidget(
      MaterialApp(
        home: PizzaDetailScreen(pizza: pizza, backend: backend, client: client),
      ),
    );

    // Verify that the pizza name, price, and description are displayed.
    expect(find.text('Margherita'), findsOneWidget);
    expect(find.text('8.50 €'), findsOneWidget);
    expect(find.text('Klassische Pizza Margherita'), findsOneWidget);

    // Wait for the ingredients to load.
    await tester.pumpAndSettle();

    // Verify that the ingredients are displayed.
    expect(find.text('Tomate'), findsOneWidget);
    expect(find.text('Käse'), findsOneWidget);
    expect(find.text('Salami'), findsOneWidget);

    // Tap on an ingredient and verify that it is selected.
    await tester.tap(find.text('Tomate'));
    await tester.pump();

    // Verify the total price is updated.
    expect(find.text('Dem Warenkorb hinzufügen • 9.50 €'), findsOneWidget);

    // Tap on the button to add to the cart.
    await tester.tap(find.text('Dem Warenkorb hinzufügen • 9.50 €'));
    await tester.pump();

    // Verify that the item is added to the cart.
    expect(Cart().items.length, 1);
    expect(Cart().items.first.name, 'Margherita');
    expect(Cart().items.first.preis, 9.5);
  });
}
