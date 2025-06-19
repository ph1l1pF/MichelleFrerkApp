import 'package:flutter_test/flutter_test.dart';
import 'package:michelle_frerk/models/cart.dart';
import 'package:michelle_frerk/models/collection.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/models/product_variant.dart';

void main() {
  group('Cart', () {
    late Cart cart;
    late ProductVariant variantA;
    late ProductVariant variantB;

    setUp(() {
      cart = Cart();
      final product = Product('1234', 'Produkt1', 'bla', true, Collection('id', 'title'), 'bla', []);
      variantA = ProductVariant(
        '1',
        'A',
        true,
        10.0,
        'EUR',
        null,
        5,
        product,
      );
      variantB = ProductVariant(
        '2',
        'B',
        true,
        15.0,
        'EUR',
        null,
        10,
        product,
      );
    });

    test('add new variant', () {
      final result = cart.add(variantA, 2);
      expect(result.success, true);
      expect(result.message, '');
      expect(cart.variantsWithQuantities[variantA], 2);
      expect(cart.count, 2);
      expect(cart.totalPrice, 20.0);
    });

    test('add same variant increases quantity', () {
      final result1 = cart.add(variantA, 1);
      final result2 = cart.add(variantA, 2);
      expect(result1.success, true);
      expect(result1.message, '');
      expect(result2.success, true);
      expect(result2.message, '');
      expect(cart.variantsWithQuantities[variantA], 3);
      expect(cart.count, 3);
      expect(cart.totalPrice, 30.0);
    });

    test('add different variants', () {
      cart.add(variantA, 1);
      cart.add(variantB, 2);
      expect(cart.variantsWithQuantities[variantA], 1);
      expect(cart.variantsWithQuantities[variantB], 2);
      expect(cart.count, 3);
      expect(cart.totalPrice, 10.0 + 2 * 15.0);
    });

    test('cannot add more than available quantity', () {
      final canAdd = cart.canAdd(variantB, 24);
      final result = cart.add(variantB, 24);
      expect(canAdd, false);
      expect(result.success, false);
      expect(result.message, 'Die Menge übersteigt die verfügbare Menge von 10.');
      expect(cart.variantsWithQuantities[variantB], isNull);
      expect(cart.count, 0);
    });

    test('clear cart', () {
      cart.add(variantA, 2);
      cart.add(variantB, 1);
      cart.clear();
      expect(cart.variantsWithQuantities.isEmpty, true);
      expect(cart.count, 0);
      expect(cart.totalPrice, 0.0);
    });
  });
}
