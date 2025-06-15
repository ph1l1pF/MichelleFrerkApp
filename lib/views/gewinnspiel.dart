import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:michelle_frerk/services/firestore-service.dart';
import 'package:michelle_frerk/views/media_viewer.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GewinnspielPage extends StatefulWidget {
  const GewinnspielPage({super.key});

  static DateTime endDate = DateTime(2025, 7, 15);

  @override
  State<GewinnspielPage> createState() => _GewinnspielPageState();
}

class _GewinnspielPageState extends State<GewinnspielPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _hasParticipated = false;
  bool _notificationsEnabled = false;

  final prefKey = 'hasParticipated17655478753';

  @override
  void initState() {
    super.initState();
    _checkParticipation();
    _checkNotificationPermissions();
  }

  Future<void> _checkParticipation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasParticipated = prefs.getBool(prefKey) ?? false;
    });
  }

  Future<void> _checkNotificationPermissions() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _notificationsEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  Future<void> _submitEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);

    try {
      await FirestoreService().store(
        _nameController.value.text.trim(),
        _emailController.value.text.trim(),
      );

      setState(() {
        _hasParticipated = true;
      });

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Vielen Dank!'),
              content: const Text(
                'Du hast erfolgreich am Gewinnspiel teilgenommen. Viel Glück!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      await prefs.setBool(prefKey, false);

      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fehler bei der Teilnahme. Bitte versuche es später erneut.',
          ),
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    var endDate = GewinnspielPage.endDate.toLocal();
    var endDateString = "${endDate.day.toString().padLeft(2, '0')}.${endDate.month.toString().padLeft(2, '0')}.${endDate.year}";
    var bedingungen = '''1. Veranstalter:

Das Gewinnspiel wird veranstaltet von Michelle Frerk, Aretousas 7c, 6036 Larnaca, Zypern. 

2. Teilnahmeberechtigung:

An dem Gewinnspiel können alle natürlichen Personen teilnehmen, die ihren Wohnsitz in Deutschland, Österreich, Niederlande, Belgien oder Luxembourg haben und das Alter von 18 Jahren vollendet haben. Ausgenommen sind Mitarbeiter des Veranstalters und deren Angehörige. 

3. Gewinnspielzeitraum:

Das Gewinnspiel beginnt am 07.06.2025 und endet am 15.07.2025. 

4. Teilnahmebedingungen:
Die Teilnahme am Gewinnspiel ist kostenlos und erfolgt ausschließlich online über die App. Um an dem Gewinnspiel teilzunehmen, müssen die Teilnehmenden ihren Namen und ihre E-Mail-Adresse in die dafür vorgesehenen Felder eintragen und auf "Teilnehmen" klicken. 

5. Gewinnerermittlung:

Die Gewinner werden unter allen teilnahmeberechtigten Teilnehmern per Zufallsziehung ermittelt. 

6. Gewinnanspruch:

Der Gewinnanspruch kann nicht in bar ausgezahlt, übertragen oder verpfändet werden. 

7. Datenschutz:

Die personenbezogenen Daten der Teilnehmer werden ausschließlich zur Durchführung des Gewinnspiels genutzt und nicht an Dritte weitergegeben. Eine längerfristige Speicherung erfolgt nur mit ausdrücklicher Zustimmung. Die Teilnehmer können ihre Daten jederzeit widerrufen oder löschen lassen. 

8. Rechtsweg:

Der Rechtsweg ist ausgeschlossen. 

9. Sonstiges:

Der Veranstalter behält sich das Recht vor, das Gewinnspiel jederzeit ohne Angabe von Gründen zu beenden. Dies gilt insbesondere bei technischen Schwierigkeiten oder unvorhergesehenen Ereignissen.
Die Firma Apple Inc. steht in keiner Verbindung zu diesem Gewinnspiel und ist nicht verantwortlich für die Durchführung oder Abwicklung des Gewinnspiels.''';
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _hasParticipated
              ? Column(
                  children: [Text(
                    'Du hast bereits am Gewinnspiel teilgenommen. Viel Glück! Der Gewinner wird am $endDateString bekannt gegeben und von mir per E-Mail benachrichtigt.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 26),
                  Text(bedingungen,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                  ]
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gewinne mein Kunstwerk "Sandy" gerahmt in Acrylglas!',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        height: 300, // Set the desired fixed height
                        child: MediaViewer(
                          mediaItem: MediaItem(
                            type: 'image',
                            origin: 'assets',
                            locator: 'assets/images/sandy.jpg',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Trage deinen Namen und deine E-Mail-Adresse ein, um am Gewinnspiel teilzunehmen!',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Der Gewinner wird am $endDateString bekannt gegeben und von mir per E-Mail benachrichtigt.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-Mail-Adresse',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bitte gib einen Namen ein.'),
                            ),
                          );
                        } else if (_emailController.text.trim().isEmpty || !_isValidEmail(_emailController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bitte gib eine gültige E-Mail-Adresse ein.'),
                            ),
                          );
                        } else if (!_notificationsEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bitte aktiviere die Push-Benachrichtigungen in den Einstellungen, um am Gewinnspiel teilzunehmen.',
                              ),
                            ),
                          );
                        } else {
                          _submitEmail();
                        }
                      },
                      child: const Text('Teilnehmen'),
                    ),
                    const SizedBox(height: 16),
                    Text('Durch Klick auf "Teilnehmen" akzeptierst du die Teilnahmebedingungen und Datenschutzbestimmungen.'),
                    const SizedBox(height: 25),
                    Text(bedingungen,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
