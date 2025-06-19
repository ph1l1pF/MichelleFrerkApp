import 'package:flutter_test/flutter_test.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/models/product_variant.dart';
import 'package:michelle_frerk/models/collection.dart';
import 'package:michelle_frerk/repositories/cart_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mocks.mocks.dart';



void main() {
  group('CartRepository', () {
    late CartRepository cartRepository;
    late CartRepository cartRepositoryCopy;
    late ProductVariant variantA;
    late ProductVariant variantB;
    late Product productA;
    late Product productB;
    late Collection collection;
    late MockCheckoutService mockCheckoutService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      mockCheckoutService = MockCheckoutService();
      cartRepository = CartRepository(checkoutService: mockCheckoutService);
      cartRepositoryCopy = CartRepository(checkoutService: mockCheckoutService);

      collection = Collection('c1', 'Test Collection');
      productA = Product('p1', 'Produkt A', 'desc', true, collection, '', []);
      productB = Product('p2', 'Produkt B', 'desc', true, collection, '', []);
      variantA = ProductVariant(
        'v1',
        'Variante A',
        true,
        10.0,
        'EUR',
        null,
        5,
        productA,
      );
      variantB = ProductVariant(
        'v2',
        'Variante B',
        true,
        20.0,
        'EUR',
        null,
        2,
        productB,
      );
      productA.variants.add(variantA);
      productB.variants.add(variantB);
    });

    test('addToCart fügt Variante hinzu', () async {
      final result = await cartRepository.addToCart(variantA);
      expect(result.success, true);
      expect(cartRepository.totalPrice, 10.0);
      expect(cartRepository.count, 1);
    });

    test('addToCart erhöht Menge', () async {
      await cartRepository.addToCart(variantA);
      await cartRepository.addToCart(variantA);
      expect(cartRepository.count, 2);
      expect(cartRepository.totalPrice, 20.0);
    });

    test('clearCart leert den Warenkorb', () async {
      await cartRepository.addToCart(variantA);
      await cartRepository.addToCart(variantB);
      await cartRepository.clearCart();
      expect(cartRepository.totalPrice, 0.0);
      expect(cartRepository.count, 0);
    });

    test('launchCheckout ruft CheckoutService auf', () async {
      await cartRepository.addToCart(variantA);
      await cartRepository.launchCheckout();
      verify(
        mockCheckoutService.launchCheckout(
          cartRepository.cart.variantsWithQuantities,
        ),
      ).called(1);
    });

    test('launchCheckout wirft Exception bei leerem Warenkorb', () async {
      expect(() => cartRepository.launchCheckout(), throwsException);
    });

    test('cannot add more than available', () async {
      for (int i = 0; i < 2; i++) {
        await cartRepository.addToCart(variantB);
      }
      final result = await cartRepository.addToCart(variantB);
      expect(result.success, false);
    });

    test('loadCart lädt Varianten aus gespeicherten Daten', () async {
      // Simuliere gespeicherten Warenkorb
      await cartRepository.addToCart(variantA);
      await cartRepository.addToCart(variantB);

      // Lade den Warenkorb neu

      await cartRepositoryCopy.loadCart([productA, productB]);
      expect(cartRepositoryCopy.count, 2);
      expect(cartRepositoryCopy.cart.variantsWithQuantities[variantA], 1);
      expect(cartRepositoryCopy.cart.variantsWithQuantities[variantB], 1);
    });
  });
}
