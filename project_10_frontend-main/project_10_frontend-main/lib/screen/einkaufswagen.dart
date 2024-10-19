import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project_10_frontend/model/MenuItemBase.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'package:project_10_frontend/warenkorb/cart.dart';
import 'package:project_10_frontend/backend/backend.dart';

class Einkaufswagen extends StatefulWidget {
  final Cart cart;
  final Backend backend;
  final http.Client client;

  Einkaufswagen({
    required this.cart,
    required this.backend,
    required this.client,
  });

  Einkaufswagen.defaultConstructor()
      : cart = Cart(),
        backend = Backend(),
        client = http.Client();

  @override
  _EinkaufswagenState createState() => _EinkaufswagenState();
}

class _EinkaufswagenState extends State<Einkaufswagen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.cart.items;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Mixed Eats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 90,
                      height: 90,
                      child: Image.asset(item is Pizza
                          ? 'assets/Pizza_Bilder/${item.imageUrl}'
                          : 'assets/Getreanke_Bilder/${item.imageUrl}'),
                    ),
                    title: Text(item.name),
                    subtitle: Text('${item.preis.toStringAsFixed(2)} €'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(item),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Adresse',
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Zwischensumme'),
                  Text('${widget.cart.calculateTotal().toStringAsFixed(2)} €'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              key: Key("Bestellung aufgeben"),
              onPressed: () async {
                var dateTimeNow = DateTime.now();
                String formattedDate =
                    DateFormat('yyyy-MM-dd – kk:mm').format(dateTimeNow);

                try {
                  await widget.backend.addBestellung(
                    widget.client,
                    cartItems.whereType<Pizza>().toList(),
                    cartItems.whereType<Getraenke>().toList(),
                    widget.cart.calculateTotal(),
                    formattedDate,
                    _nameController.text,
                    _addressController.text,
                  );

                  widget.cart.clear();

                  print('Bestellung erfolgreich hinzugefügt!');
                  Navigator.pushNamed(context, '/main_page');
                } catch (e) {
                  print('Fehler beim Hinzufügen der Bestellung: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fehler beim Hinzufügen der Bestellung'),
                    ),
                  );
                }
              },
              child: Text('Bestellung abschicken'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeItem(MenuItemBase item) {
    setState(() {
      widget.cart.removeItem(item);
    });
  }
}
