import 'package:project_10_frontend/model/MenuItemBase.dart';

class Cart {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;

  Cart._internal();

  final Map<MenuItemBase, int> _items = {};

  List<MenuItemBase> get items => _items.keys.toList();

  int getQuantity(MenuItemBase item) => _items[item] ?? 0;

  void addItem(MenuItemBase item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }
  }

  void removeItem(MenuItemBase item) {
    if (_items.containsKey(item) && _items[item]! > 1) {
      _items[item] = _items[item]! - 1;
    } else {
      _items.remove(item);
    }
  }

  void clear() {
    _items.clear();
  }

  void updateItem(MenuItemBase item, int quantity) {
    if (quantity > 0) {
      _items[item] = quantity;
    } else {
      _items.remove(item);
    }
  }

  double calculateTotal() {
    return _items.entries.fold(
      0.0,
      (total, entry) => total + entry.key.preis * entry.value,
    );
  }
}
