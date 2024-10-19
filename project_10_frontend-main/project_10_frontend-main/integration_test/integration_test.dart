import 'package:flutter/material.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/main.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/screen/detail_item_ansicht.dart';
import 'package:project_10_frontend/screen/einkaufswagen.dart';
import 'package:project_10_frontend/screen/item_uebersicht_page.dart';
import 'package:project_10_frontend/screen/main_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:project_10_frontend/warenkorb/cart.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test: create, edit, and delete a pizza order', (tester) async {
    // Start the app and set up routes
    await tester.pumpWidget(MaterialApp(
      home: MainPage(Backend(), http.Client()),
      routes: {        
        '/main_page': (context) => MainPage(Backend(), http.Client()),
        '/pizza_menu': (context) =>
            PizzaMenu(backend: Backend(), client: http.Client()),
        '/cart': (context) => Einkaufswagen(
            cart: Cart(), backend: Backend(), client: http.Client()),
      },
    ));
    await tester.pumpAndSettle();

    // Check if MainPage is displayed
    expect(find.byType(MainPage), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    await tester.pumpAndSettle();

    // Navigate to PizzaMenu
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(PizzaMenu), findsOneWidget);

    // Select a pizza to add to the cart
    await tester.tap(find.text('Pizza Funghi'));
    await tester.pumpAndSettle();
    expect(find.byType(PizzaDetailScreen), findsOneWidget);

    // Add the pizza to the cart
    await tester.tap(find.byKey(Key("Add")));
    await tester.pumpAndSettle();
    expect(find.byType(PizzaMenu), findsOneWidget);

    // Go to the cart
    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pumpAndSettle();
    expect(find.byType(Einkaufswagen), findsOneWidget);

    // Place the order
    await tester.tap(find.byKey(Key("Bestellung aufgeben")));
    await tester.pumpAndSettle();
    expect(find.byType(MainPage), findsOneWidget);
    expect(find.byType(ListView).evaluate().length, 1);

    // Edit the order
    await tester.tap(find.byKey(Key("Edit")).first);
    await tester.pumpAndSettle();

    // Change customer details
    await tester.tap(find.byKey(Key('name')));
    await tester.enterText(find.byKey(Key('name')), 'Max Mustermann 2');
    await tester.tap(find.byKey(Key('address')));
    await tester.enterText(find.byKey(Key('address')), 'Musterstraße 2');
    await tester.tap(find.text('Änderungen speichern'));
    await tester.pumpAndSettle();

    // Verify edited order
    expect(find.byType(MainPage), findsOneWidget);

    // Delete the order
    await tester.tap(find.byKey(Key("Delete")).first);
    await tester.pumpAndSettle();
    expect(find.byType(MainPage), findsOneWidget);
    expect(find.text('Max Mustermann 2'), findsNothing);
    expect(find.text('Musterstraße 2'), findsNothing);
});
} 