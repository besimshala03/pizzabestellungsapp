import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/zutaten.dart';
import 'package:http/http.dart' as http;
import 'package:project_10_frontend/screen/edit_pizza_page.dart';
import 'edit_pizza_page_test.mocks.dart';

@GenerateMocks([http.Client, Backend])
void main() {
  group('EditPizzaScreen Widget Tests', () {
    late MockClient mockClient;
    late MockBackend mockBackend;

    setUp(() {
      mockClient = MockClient();
      mockBackend = MockBackend();
    });

    Future<void> pumpEditPizzaScreen(WidgetTester tester,
        {required int pizzaId}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ScaffoldMessenger(
            child: EditPizzaScreen(
                pizzaId: pizzaId, backend: mockBackend, client: mockClient),
          ),
        ),
      );
      await tester
          .pumpAndSettle(Duration(seconds: 5)); // Erhöhung der Wartezeit
    }

    testWidgets('Pizza-Details werden korrekt angezeigt',
        (WidgetTester tester) async {
      final pizza = Pizza(
        id: 1,
        name: 'Test Pizza',
        beschreibung: 'Test Beschreibung',
        preis: 10.0,
        imageUrl: 'Pizza_Funghi.jpeg',
        zutaten: [Zutaten(id: 1, name: 'Tomato', preis: 1.0)],
      );

      when(mockBackend.fetchPizzaById(mockClient, 1))
          .thenAnswer((_) async => pizza);
      when(mockBackend.fetchZutatenData(mockClient)).thenAnswer(
          (_) async => [Zutaten(id: 1, name: 'Tomato', preis: 1.0)]);

      await pumpEditPizzaScreen(tester, pizzaId: 1);
      await tester.pumpAndSettle();

      expect(find.text('Test Pizza'), findsOneWidget);
      expect(find.text('Test Beschreibung'), findsOneWidget);
      expect(find.text('10.00 €'), findsOneWidget);
    });

    testWidgets('Zutatenauswahl umschalten', (WidgetTester tester) async {
      final pizza = Pizza(
        id: 1,
        name: 'Test Pizza',
        beschreibung: 'Test Beschreibung',
        preis: 10.0,
        imageUrl: 'Pizza_Funghi.jpeg',
        zutaten: [Zutaten(id: 1, name: 'Tomato', preis: 1.0)],
      );

      when(mockBackend.fetchPizzaById(mockClient, 1))
          .thenAnswer((_) async => pizza);
      when(mockBackend.fetchZutatenData(mockClient)).thenAnswer((_) async => [
            Zutaten(id: 1, name: 'Tomato', preis: 1.0),
            Zutaten(id: 2, name: 'Cheese', preis: 2.0),
          ]);

      await pumpEditPizzaScreen(tester, pizzaId: 1);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(1));

      await tester.tap(find.text('Cheese'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsNWidgets(2));
    });

    testWidgets('Änderungen speichern und Erfolgsmeldung anzeigen',
        (WidgetTester tester) async {
      final pizza = Pizza(
        id: 1,
        name: 'Test Pizza',
        beschreibung: 'Test Beschreibung',
        preis: 10.0,
        imageUrl: 'Pizza_Funghi.jpeg',
        zutaten: [Zutaten(id: 1, name: 'Tomato', preis: 1.0)],
      );

      when(mockBackend.fetchPizzaById(mockClient, 1))
          .thenAnswer((_) async => pizza);
      when(mockBackend.fetchZutatenData(mockClient)).thenAnswer((_) async => [
            Zutaten(id: 1, name: 'Tomato', preis: 1.0),
            Zutaten(id: 2, name: 'Cheese', preis: 2.0),
          ]);
      when(mockBackend.deleteZutatenByPizza(mockClient, any))
          .thenAnswer((_) async => http.Response('', 200));
      when(mockBackend.updatePizzaById(mockClient, 1, any))
          .thenAnswer((_) async => http.Response('', 200));

      await pumpEditPizzaScreen(tester, pizzaId: 1);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cheese'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Änderungen speichern • 12.00 €'));
      await tester.pump(); // Kurzes Pumpen, um die Snackbar auszulösen

      await tester.runAsync(() async {
        await Future.delayed(const Duration(seconds: 2));
      });
      await tester.pump();

      expect(find.text('Änderungen gespeichert'), findsOneWidget);
    });
  });
}
