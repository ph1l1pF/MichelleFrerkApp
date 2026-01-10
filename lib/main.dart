import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:michelle_frerk/repositories/cart_repository.dart';
import 'package:michelle_frerk/repositories/media_item_repository.dart';
import 'package:michelle_frerk/repositories/notification_repository.dart';
import 'package:michelle_frerk/services/checkout_service.dart';
import 'package:michelle_frerk/services/firestore_service.dart';
import 'package:michelle_frerk/views/carousel.dart';
import 'package:michelle_frerk/repositories/collections_map.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/services/product_shopify_service.dart';
import 'package:michelle_frerk/views/cart_view.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:michelle_frerk/views/product_details.dart';
import 'package:michelle_frerk/views/produktliste.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestoreService = FirestoreService();
  final notificationRepository = NotificationRepository(firestoreService: firestoreService);
  if(await notificationRepository.notificationsEnabled) {
    await notificationRepository.subscribeToTopic();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => MediaItemRepository()),
        Provider(create: (context) => firestoreService),
        Provider(create: (context) => ProductShopifyService()),
        Provider(create: (context) => CheckoutService()),
        Provider(create: (context) => notificationRepository),
        ChangeNotifierProvider(create: (context) => CartRepository(checkoutService: CheckoutService())), // How to use the CartShopifyService
      ],
      child: const MyApp(),
    ),
  );
}

bool _showProductDetailPageIfProductFound(
  RemoteMessage? message,
  List<Product> products,
) {
  var id = message?.data['id'];

  if (id == null || id?.toString().trim() == "") {
    return true;
  }

  var productsFittingId = products.where((p) => p.id == id);
  var product = productsFittingId.isNotEmpty ? productsFittingId.first : null;

  if (product == null) {
    return false;
  }

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => ProduktDetailPage(product: product),
    ),
  );
  return true;
}

// when the app was terminated before the notification was tapped, we need to handle the initial message
Future<void> handleInitialMessage(List<Product> products) async {
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  _showProductDetailPageIfProductFound(initialMessage, products);
  // Here we don't need another fetch if the product was not found,
  // because here the products were fetched a moment ago
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  late Future<List<Product>> _productsFuture;

  List<Product> grosseWerkeList = [];
  List<Product> minisList = [];
  List<Product> journalsList = [];
  List<Product> auftragarbeitenList = [];
  List<Product> artInteriorPiecesList = [];

  @override
  void initState() {
    super.initState();
    final productShopifyService = Provider.of<ProductShopifyService>(
      context,
      listen: false,
    );

    _productsFuture = productShopifyService.fetchProducts();
    _productsFuture.then((products) async {
      setState(() {
        grosseWerkeList =
            products
                .where(
                  (produkt) =>
                      produkt.collection.id == collectionMap[grosseWerke],
                )
                .toList();
        minisList =
            products
                .where(
                  (produkt) => produkt.collection.id == collectionMap[MINI],
                )
                .toList();
        journalsList =
            products
                .where(
                  (produkt) => produkt.collection.id == collectionMap[Journals],
                )
                .toList();
        auftragarbeitenList =
            products
                .where(
                  (produkt) =>
                      produkt.collection.id == collectionMap[Auftragarbeiten],
                )
                .toList();
        artInteriorPiecesList =
            products
                .where(
                  (produkt) =>
                      produkt.collection.id == collectionMap[ArtInteriorPieces],
                )
                .toList();
      });
      await handleInitialMessage(products);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _productsFuture.then((products) async {
        final productFound = _showProductDetailPageIfProductFound(
          message,
          products,
        );

        if (productFound) {
          return;
        }

        // It can be the case that products does not contain the new product
        // as the last fetch was before the new product was published in Shopify store
        // Therefore we fetch again and then search again.
        var productsNew = await productShopifyService.fetchProducts();
        _showProductDetailPageIfProductFound(message, productsNew);
      });
    });
  }

  bool loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartRepository = Provider.of<CartRepository>(context, listen: true);
    _productsFuture.then((products) async {
      if (loaded) {
        return;
      }
      await cartRepository.loadCart(products);
      loaded = true;
    });
  }

  // Screens for each tab
  Widget _buildProductsPage() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Fehler beim Laden der Produkte'));
        }
        // Die Listen werden bereits im initState gesetzt, daher kann hier direkt das UI gebaut werden
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0), // Abstand nach rechts
                    child: Consumer<CartRepository>(
                      builder: (context, cartRepository, child) {
                        return IconButton(
                          onPressed: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => const CartView(),
                              ),
                            );
                          },
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.shopping_cart_sharp, size: 28),
                              if (cartRepository.count > 0)
                                Positioned(
                                  right: -10,
                                  top: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(250, 181, 228, 0.85),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 15,
                                      minHeight: 15,
                                    ),
                                    child: Text(
                                      cartRepository.count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (grosseWerkeList.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Große Werke',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ProduktListe(produkte: grosseWerkeList),
              ],
              if (minisList.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Minis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ProduktListe(produkte: minisList),
              ],
              if (journalsList.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Journals & Geschenkideen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ProduktListe(produkte: journalsList),
              ],
              if (artInteriorPiecesList.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Art Interior Pieces',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ProduktListe(produkte: artInteriorPiecesList),
              ],
              if (auftragarbeitenList.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Auftragsarbeiten',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ProduktListe(produkte: auftragarbeitenList),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutMePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageCarousel(
            mediaItems: [
              MediaItem(
                type: 'image',
                origin: 'assets',
                locator: 'assets/images/about_me1.jpg',
              ),
              MediaItem(
                type: 'image',
                origin: 'assets',
                locator: 'assets/images/about_me2.jpg',
              ),
              MediaItem(
                type: 'image',
                origin: 'assets',
                locator: 'assets/images/about_me3.jpg',
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('''
Ich bin Michelle, Künstlerin für abstrakte Kunst. Meine Werke sind ausdrucksstark und voller positiver Energie & Lebensfreude. Schon seit meiner Kindheit liebe ich es, kreativ zu sein – doch erst nach 12 Jahren in der Wirtschaft und zwei abgeschlossenen Studiengängen habe ich 2022 meine wahre Leidenschaft wiederentdeckt: die Malerei.

2024 wagte ich den Schritt in die Selbstständigkeit und widme mich seither mit ganzem Herzen meiner Kunst. Meine Werke entstehen intuitiv, mit hochwertigen Materialien und viel Liebe zum Detail – oft auch in übergroßen Formaten, die besondere Wirkung entfalten.

Ich möchte mit meiner Kunst nicht nur visuelle Freude schenken, sondern auch inspirieren und positive Impulse in deinen Alltag bringen.

Folge mir auch gerne auf Instagram (@michellefrerk). Dort findest du Einblicke in meine Arbeit und Entstehungsprozesse meiner Kunst. Bei Fragen oder individuellen Wünschen freue ich mich über deine Nachricht!
        ''', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Michelle Frerk – Kunst',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Michelle Frerk')),
        body:
            _selectedIndex == 0
                ? _buildProductsPage()
                : _selectedIndex == 1
                ? _buildAboutMePage()
                : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Color.fromRGBO(250, 181, 228, 0.85),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color.fromRGBO(255, 255, 255, 0.7),
          selectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          onTap:
              (index) => setState(() {
                _selectedIndex = index;
              }),
          items: getNavigationBarItems,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> get getNavigationBarItems {
    var items = [
      BottomNavigationBarItem(
        icon: Icon(
          Icons.shopping_cart,
          color:
              _selectedIndex == 0
                  ? Colors.white
                  : Color.fromRGBO(255, 255, 255, 0.6),
        ),
        label: 'Shop',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.mood,
          color:
              _selectedIndex == 1
                  ? Colors.white
                  : Color.fromRGBO(255, 255, 255, 0.6),
        ),
        label: 'About Me',
      ),
    ];
    return items;
  }
}
