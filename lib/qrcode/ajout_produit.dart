import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class AjoutProduit extends StatefulWidget {
  @override
  _AjoutProduitState createState() => _AjoutProduitState();
}

class _AjoutProduitState extends State<AjoutProduit> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController controller = MobileScannerController();
  String qrId = '';

  final nameController = TextEditingController();
  final originController = TextEditingController();
  final id2 = TextEditingController();
  final date1 = TextEditingController();
  final date2 = TextEditingController();
  final agri = TextEditingController();

  final String nostrRelayUrl = "http://10.0.2.2:5000/events";

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> envoyerProduitNostr() async {
    if (qrId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Scanner un QR code d'abord")));
      return;
    }

    final event = {
      "kind": "product_addition", // type d'événement Nostr personnalisé
      "content": jsonEncode({
        "idProduit": qrId,
        "description": nameController.text,
        "origine": originController.text,
        "agriculture": agri.text,
        "dateFabrication": date1.text,
        "dateExpiration": date2.text,
        "idVoyage": id2.text,
      }),
      "pubkey": "fake_pubkey_for_testing", // à remplacer par la vraie clé publique si besoin
      "created_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "tags": []
    };

    try {
      final response = await http.post(
        Uri.parse(nostrRelayUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(event),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Produit ajouté via Nostr relay")));
        controller.start(); // relancer la caméra pour un nouveau scan
        setState(() {
          qrId = '';
          nameController.clear();
          originController.clear();
          agri.clear();
          date1.clear();
          date2.clear();
          id2.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Erreur serveur: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajout produit via Nostr')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              key: qrKey,
              controller: controller,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final code = barcode.rawValue;
                if (code != null) {
                  setState(() {
                    qrId = code;
                  });
                  controller.stop(); // stop après scan
                }
              },
            ),
          ),
          if (qrId.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("ID produit scanné : $qrId"),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nom du produit"),
            ),
            TextField(
              controller: originController,
              decoration: InputDecoration(labelText: "Origine"),
            ),
            TextField(
              controller: agri,
              decoration: InputDecoration(labelText: "Agriculture"),
            ),
            TextField(
              controller: date1,
              decoration: InputDecoration(labelText: "Date fabrication"),
            ),
            TextField(
              controller: date2,
              decoration: InputDecoration(labelText: "Date expiration"),
            ),
            TextField(
              controller: id2,
              decoration: InputDecoration(labelText: "ID du voyage"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: envoyerProduitNostr,
              child: Text("Envoyer vers Nostr relay"),
            ),
          ]
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    nameController.dispose();
    originController.dispose();
    agri.dispose();
    date1.dispose();
    date2.dispose();
    id2.dispose();
    super.dispose();
  }
}
