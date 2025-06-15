import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:michelle_frerk/views/carousel.dart';
import 'package:michelle_frerk/repositories/collections-map.dart';
import 'package:michelle_frerk/environment.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/services/product-shopify-service.dart';
import 'package:michelle_frerk/views/gewinnspiel.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:michelle_frerk/views/product-details.dart';
import 'package:michelle_frerk/views/produktliste.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  await FirebaseMessaging.instance.getAPNSToken();
  var topic = await Environment.firebaseMessagingTopic();
  FirebaseMessaging.instance.subscribeToTopic(topic);

  runApp(const MyApp());
}

// when the app was terminated before the notification was tapped, we need to handle the initial message
Future<void> handleInitialMessage(List<Product> produkte) async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage == null) {
    return;
  }

  var id = initialMessage.data['id'];

  if (id == null || id == "") {
    return;
  }

  Product? produkt = produkte.firstWhere(
    (p) => p.id == id,
    orElse: () => null!,
  );

  // Here we don't need another fetch if the product was not found, 
  // because here the products were fetched a moment ago
  
  if (produkt == null) {
    return;
  }

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => ProduktDetailPage(product: produkt),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  late Future<List<Product>> _produkteFuture;

  List<Product> grosseWerkeList = [];
  List<Product> minisList = [];
  List<Product> journalsList = [];
  List<Product> auftragarbeitenList = [];
  List<Product> gutscheineList = [];
  List<Product> artInteriorPiecesList = [];

  @override
  void initState() {
    super.initState();
    _produkteFuture = new ProductShopifyService().fetchProducts();
    _produkteFuture.then((produkte) async {
      setState(() {
        grosseWerkeList =
            produkte
                .where(
                  (produkt) =>
                      produkt.collection.id == collectionMap[grosseWerke],
                )
                .toList();
        minisList =
            produkte
                .where(
                  (produkt) =>
                      produkt.collection.id == collectionMap[MINI],
                )
                .toList();
        journalsList =
            produkte
                .where(
                  (produkt) =>
                      produkt.collection.id == collectionMap[Journals],
                )
                .toList();
        auftragarbeitenList =
            produkte
                .where(
                  (produkt) =>
                      produkt.collection.id ==
                      collectionMap[Auftragarbeiten],
                )
                .toList();
        gutscheineList =
            produkte
                .where(
                  (produkt) =>
                      produkt.collection.id == collectionMap[Gutscheine],
                )
                .toList();
        artInteriorPiecesList =
            produkte
                .where(
                  (produkt) =>
                      produkt.collection.id ==
                      collectionMap[ArtInteriorPieces],
                )
                .toList();
      });

      await handleInitialMessage(produkte);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _produkteFuture.then((produkte) async {
        var id = message.data['id'];

        if(id == null || id == "") {
          return;
        }

        var produkt = produkte.firstWhere(
          (p) => p.id == id,
          orElse: () => null!,
        );

        if (produkt != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => ProduktDetailPage(product: produkt),
            ),
          );
          return;
        }

        // It can be the case that produkte does not contain the new product
        // as the last fetch was before the new product was published in Shopify store
        // Therefore we fetch again and then search again.
        var produkteNew = await ProductShopifyService().fetchProducts();

        produkt = produkteNew.firstWhere(
          (p) => p.id == id,
          orElse: () => null!,
        );

        if (produkt == null) {
          return;
        }
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ProduktDetailPage(product: produkt),
          ),
        );
      });
    });
  }

  // Screens for each tab
  Widget _buildProductsPage() {
    return FutureBuilder<List<Product>>(
      future: _produkteFuture,
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
                    'Journals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ProduktListe(produkte: journalsList),
              ],
              if (gutscheineList.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Gutscheine',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ProduktListe(produkte: gutscheineList),
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
                : const GewinnspielPage(),
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
      BottomNavigationBarItem(
        icon: Icon(
          Icons.card_giftcard,
          color:
              _selectedIndex == 2
                  ? Colors.white
                  : Color.fromRGBO(255, 255, 255, 0.6),
        ),
        label: 'Gewinnspiel',
      ),
    ];
    if (GewinnspielPage.endDate.isBefore(DateTime.now())) {
      items.removeAt(2);
    }
    return items;
  }
}
