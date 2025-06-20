import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/views/product_details.dart';

class ProduktListe extends StatefulWidget {
  final List<Product> produkte;
  const ProduktListe({super.key, required this.produkte});

  @override
  State<ProduktListe> createState() => _ProduktListeState();
}

class _ProduktListeState extends State<ProduktListe> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: Future.value(widget.produkte),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Produkte gefunden.'));
        }

        final produkte = snapshot.data!;
        return ListView.builder(
          itemCount: produkte.length,
          shrinkWrap: true, // Wichtig!
          physics: const NeverScrollableScrollPhysics(), // Verhindert Scroll-Konflikt
          itemBuilder: (context, index) {
            final produkt = produkte[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading:
                    CachedNetworkImage(
                            imageUrl: produkt.mediaItems[0].locator,
                            key: ValueKey(produkt.mediaItems[0].locator),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                        ),
                title: Text(produkt.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProduktDetailPage(product: produkt),
                    ),
                  );
                },
                subtitle: Text(
                  produkt.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
