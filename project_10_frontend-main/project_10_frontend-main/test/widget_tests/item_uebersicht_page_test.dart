import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/screen/item_uebersicht_page.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'package:http/http.dart' as http;

import 'item_uebersicht_page_test.mocks.dart';

// Wrapper Klasse für Widget. Definiert Scaffold und Mock-Objekte.
class TestWrapperAppPizzaMenu1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mockBackend = MockBackend();
    final mockClient = MockClient();

    when(mockBackend.fetchPizzaList(mockClient)).thenAnswer((_) async => [
          Pizza(
              id: 1,
              name: 'Margherita',
              beschreibung: 'Classic Margherita',
              preis: 7.5,
              imageUrl: 'Pizza_Margherita.jpeg'),
          Pizza(
              id: 2,
              name: 'Salami',
              beschreibung: 'Salami Pizza',
              preis: 8.5,
              imageUrl: 'Pizza_Salami.jpeg'),
        ]);

    when(mockBackend.fetchGetraenkeData(mockClient)).thenAnswer((_) async => [
          Getraenke(id: 1, name: 'Cola', preis: 2.5, imageUrl: 'Coca_Cola.png'),
          Getraenke(
              id: 2, name: 'Fanta', preis: 2.5, imageUrl: 'Fanta_Orange.png'),
        ]);

    return MaterialApp(
      home: Scaffold(
        body: PizzaMenu(backend: mockBackend, client: mockClient),
      ),
    );
  }
}

// Wrapper Klasse für Widget. Definiert Scaffold und Mock-Objekte.
class TestWrapperAppPizzaMenu2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mockBackend = MockBackend();
    final mockClient = MockClient();

    when(mockBackend.fetchPizzaList(mockClient)).thenAnswer((_) async => []);
    when(mockBackend.fetchGetraenkeData(mockClient))
        .thenAnswer((_) async => []);

    return MaterialApp(
      home: Scaffold(
        body: PizzaMenu(backend: mockBackend, client: mockClient),
      ),
    );
  }
}

@GenerateMocks([http.Client, Backend])
void main() {
  group('PizzaMenu Tests', () {
    testWidgets('Test: Laden von zwei Items', (tester) async {
      await tester.pumpWidget(TestWrapperAppPizzaMenu1());
      expect(find.byType(PizzaMenu), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Margherita'), findsOneWidget);
      expect(find.text('Salami'), findsOneWidget);
      expect(find.text('Cola'), findsOneWidget);
      expect(find.text('Fanta'), findsOneWidget);
    });

    testWidgets('Test: Laden einer leeren Item Liste', (tester) async {
      await tester.pumpWidget(TestWrapperAppPizzaMenu2());
      expect(find.byType(PizzaMenu), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNWidgets(0));
    });

    testWidgets('Test: Items haben ein Bild', (tester) async {
      await tester.pumpWidget(TestWrapperAppPizzaMenu1());
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNWidgets(4));
    });

    testWidgets('Test: Hinzufügen eines Getränks zum Warenkorb',
        (tester) async {
      await tester.pumpWidget(TestWrapperAppPizzaMenu1());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cola'));
      await tester.pumpAndSettle();
      expect(find.text('Getränk hinzufügen'), findsOneWidget);
      await tester.tap(find.text('Ja'));
      await tester.pump();
      expect(
          find.text('Cola wurde zum Warenkorb hinzugefügt.'), findsOneWidget);
    });
  });
}
