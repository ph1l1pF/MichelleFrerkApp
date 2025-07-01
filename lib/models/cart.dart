
import 'package:michelle_frerk/models/product_variant.dart';

class Cart {
  final Map<ProductVariant, int> _variantsWithQuantities = {};

  get variantsWithQuantities => _variantsWithQuantities;

  bool canAdd(ProductVariant variant, int quantity) {
    final currentQuantity = _variantsWithQuantities[variant] ?? 0;
    if (quantity + currentQuantity > variant.quantityAvailable) {
      return false;
    }
    return true;
  }

  double get totalPrice {
    double total = 0.0;
    _variantsWithQuantities.forEach((variant, quantity) {
      total += variant.price * quantity;
    });
    return total;
  }

  int get count => _variantsWithQuantities.isNotEmpty
      ? _variantsWithQuantities.values.reduce((a, b) => a + b)
      : 0;

  void clear() {
    _variantsWithQuantities.clear();
  }

  CartAddResult add(ProductVariant variant, int quantity) {

    if(!canAdd(variant, quantity)) {
      return CartAddResult(
        false,
        'Die Menge übersteigt die verfügbare Menge von ${variant.quantityAvailable}.',
      );
    }

    if (_variantsWithQuantities.containsKey(variant)) {
      _variantsWithQuantities[variant] = _variantsWithQuantities[variant]! + quantity;
    } else {
      _variantsWithQuantities[variant] = quantity;
    }
    return CartAddResult(
      true,
      '',
    );
  }

  bool remove(ProductVariant variant) {
    if (!_variantsWithQuantities.containsKey(variant)) {
      return false;
    }
    _variantsWithQuantities.remove(variant);
    return true;
  }
}

class CartAddResult {
  final bool success;
  final String message;

  CartAddResult(this.success, this.message);
}