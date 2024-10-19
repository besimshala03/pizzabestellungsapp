import 'package:flutter/material.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/MenuItemBase.dart';
import 'package:project_10_frontend/model/getraenke.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/screen/detail_item_ansicht.dart';
import 'package:project_10_frontend/screen/einkaufswagen.dart';
import 'package:project_10_frontend/warenkorb/cart.dart';
import 'package:http/http.dart' as http;

class PizzaMenu extends StatefulWidget {
  final Backend backend;
  final http.Client client;

  PizzaMenu({required this.backend, required this.client});

  @override
  _PizzaMenuState createState() => _PizzaMenuState();
}

class _PizzaMenuState extends State<PizzaMenu> {
  List<MenuItemBase> menuItems = [];
  List<MenuItemBase> drinkItems = [];

  @override
  void initState() {
    super.initState();
    fetchPizzas();
    fetchDrinks();
  }

  void fetchPizzas() async {
    try {
      List<Pizza> pizzas = await widget.backend.fetchPizzaList(widget.client);
      setState(() {
        menuItems = pizzas;
      });
    } catch (e) {
      print('Fehler beim Laden der Pizzas: $e');
    }
  }

  void fetchDrinks() async {
    try {
      List<Getraenke> drinks =
          await widget.backend.fetchGetraenkeData(widget.client);
      setState(() {
        drinkItems = drinks;
      });
    } catch (e) {
      print('Fehler beim Laden der Getränke: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Mixed',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 17.5,
                  ),
                ),
                TextSpan(
                  text: ' Eats',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.5,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pizza',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Einkaufswagen.defaultConstructor()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.reply),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: menuItems
                  .map((item) => MenuItemWidget(
                      menuItem: item,
                      backend: widget.backend,
                      client: widget.client))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            child: Text('Getränke',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: drinkItems
                  .map((item) => MenuItemWidget(
                      menuItem: item,
                      backend: widget.backend,
                      client: widget.client))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItemBase menuItem;
  final Backend backend;
  final http.Client client;

  MenuItemWidget(
      {required this.menuItem, required this.backend, required this.client});

  @override
  Widget build(BuildContext context) {
    String imageUrl;
    if (menuItem is Pizza) {
      imageUrl = 'assets/Pizza_Bilder/${menuItem.imageUrl}';
    } else if (menuItem is Getraenke) {
      imageUrl = 'assets/Getreanke_Bilder/${menuItem.imageUrl}';
    } else {
      imageUrl = menuItem.imageUrl; // Fallback falls notwendig
    }

    return GestureDetector(
      onTap: () {
        if (menuItem is Pizza) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PizzaDetailScreen(
                    pizza: menuItem as Pizza,
                    backend: backend,
                    client: client)),
          );
        } else if (menuItem is Getraenke) {
          _showAddToCartDialog(context, menuItem);
        }
      },
      child: Card(
        color: Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 1,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${menuItem.preis.toStringAsFixed(2)} €',
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                    SizedBox(height: 10),
                    if (menuItem is Pizza)
                      Text(
                        (menuItem as Pizza).beschreibung,
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                child: Image.asset(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit
                      .contain, // Change to BoxFit.contain to ensure the entire image is visible
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context, MenuItemBase menuItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Getränk hinzufügen"),
          content:
              Text("Möchten Sie ${menuItem.name} zum Warenkorb hinzufügen?"),
          actions: <Widget>[
            TextButton(
              child: Text("Nein"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Ja"),
              onPressed: () {
                Cart().addItem(menuItem);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "${menuItem.name} wurde zum Warenkorb hinzugefügt."),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
