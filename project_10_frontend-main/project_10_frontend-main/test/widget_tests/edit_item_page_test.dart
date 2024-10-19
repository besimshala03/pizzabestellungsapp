import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/Bestellung.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/screen/edit_item_page.dart';
import 'package:project_10_frontend/screen/edit_pizza_page.dart';
// import 'package:project_10_frontend/screen/bestellung_details_widget.dart';

import 'edit_item_page_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late Backend backend;
  late MockClient mockClient;

  setUp(() {
    backend = Backend();
    mockClient = MockClient();
  });

  tearDown(() {
    reset(mockClient);
  });

  Future<Bestellung> createTestBestellung() async {
    return Bestellung(
      id: 1,
      kundenname: 'John Doe',
      adresse: '123 Main St',
      datumUhrzeit: '2024-06-25 15:00:00',
      pizza: [
        Pizza(
          id: 1,
          name: 'Margherita',
          beschreibung: 'Tomato, Mozzarella, Basil',
          preis: 8.99,
          imageUrl: 'margherita.png',
          zutaten: [],
        ),
      ],
      getraenke: [
        Getraenke(
          id: 1,
          name: 'Coca Cola',
          preis: 1.99,
          imageUrl: 'coca_cola.png',
        ),
      ],
      preis: 29.99,
    );
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BestellungDetailsWidget(
        bestellungId: 1,
        backend: backend,
        client: mockClient,
      ),
    );
  }

  testWidgets('displays order details correctly', (WidgetTester tester) async {
    Bestellung testBestellung = await createTestBestellung();

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async =>
            http.Response(jsonEncode(testBestellung.toJson()), 200));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Bestellung Details'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('123 Main St'), findsOneWidget);
    expect(find.text('2024-06-25 15:00:00'), findsOneWidget);
  });

  testWidgets('saves changes correctly', (WidgetTester tester) async {
    Bestellung testBestellung = await createTestBestellung();

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async =>
            http.Response(jsonEncode(testBestellung.toJson()), 200));

    when(mockClient.put(
      Uri.parse('http://127.0.0.1:8080/bestellung/1'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('{"status": "success"}', 200));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
    await tester.enterText(find.byType(TextFormField).at(1), '456 Elm St');

    await tester.tap(find.byKey(Key('änderung speichern')));
    await tester.pumpAndSettle();

    verify(mockClient.put(
      Uri.parse('http://127.0.0.1:8080/bestellung/1'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).called(1);

    expect(find.text('Änderungen gespeichert'), findsOneWidget);
  });

  testWidgets('shows error message when saving changes fails', (WidgetTester tester) async {
    Bestellung testBestellung = await createTestBestellung();

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async =>
            http.Response(jsonEncode(testBestellung.toJson()), 200));

    when(mockClient.put(
      Uri.parse('http://127.0.0.1:8080/bestellung/1'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('{"status": "error"}', 400));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('änderung speichern')));
    await tester.pumpAndSettle();

    expect(find.text('Fehler beim Speichern der Änderungen'), findsOneWidget);
  });

  testWidgets('allows editing pizza', (WidgetTester tester) async {
    Bestellung testBestellung = await createTestBestellung();

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async =>
            http.Response(jsonEncode(testBestellung.toJson()), 200));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Ensure the button to expand the details is present and tap it
    expect(find.text('Mehr anzeigen'), findsOneWidget);
    await tester.tap(find.text('Mehr anzeigen'));
    await tester.pumpAndSettle();

   
  });

 testWidgets('allows deleting pizza', (WidgetTester tester) async {
    Bestellung testBestellung = await createTestBestellung();

    // Mock the response for fetching the order details
    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async =>
            http.Response(jsonEncode(testBestellung.toJson()), 200));

    // Mock the response for deleting the pizza
    when(mockClient.delete(Uri.parse('http://127.0.0.1:8080/pizza/1')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 200));

    // Pump the widget into the widget tree
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Ensure the button to expand the details is present and tap it
    expect(find.text('Mehr anzeigen'), findsOneWidget);
    await tester.tap(find.text('Mehr anzeigen'));
    await tester.pumpAndSettle();

});

  testWidgets('allows deleting getraenke', (WidgetTester tester) async {
    Bestellung testBestellung = await createTestBestellung();

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async =>
            http.Response(jsonEncode(testBestellung.toJson()), 200));

    when(mockClient.delete(Uri.parse('http://127.0.0.1:8080/getraenke/1')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 200));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Ensure the button to expand the details is present and tap it
    expect(find.text('Mehr anzeigen'), findsOneWidget);
    await tester.tap(find.text('Mehr anzeigen'));
    await tester.pumpAndSettle();

    // Tap the delete button for the first getraenk and verify the delete call
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    verify(mockClient.delete(Uri.parse('http://127.0.0.1:8080/getraenke/1'))).called(1);
  });
}
