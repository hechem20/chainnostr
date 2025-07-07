import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Payement extends StatefulWidget {
  final String somme;
  final List<Map<String, dynamic>> q;
  final String ide;
  final String nom;

  Payement({
    required this.somme,
    required this.q,
    required this.ide,
    required this.nom,
  });

  @override
  _PayementState createState() => _PayementState();
}

class _PayementState extends State<Payement> {
  final String nostrRelayUrl = "http://10.0.2.2:5000/events"; // ton relai local
  final String nwcUrl =
      "nwc://npubXXXXXXXXXXXXXXXXX?relay=wss://relay.damus.io&secret=YYYYYYYYYYYY"; // À personnaliser !

  Future<void> _payerCommandeLocalement() async {
    final now = DateTime.now().toUtc().toIso8601String();

    final nostrEvent = {
      "kind": "logistics_payment",
      "tags": [["commande", widget.ide]],
      "content": jsonEncode({
        "idProduit": widget.q[0]["id"],
        "description": widget.q[0]["description"],
        "montant": widget.somme,
        "prixUnitaire": widget.q[0]["price"],
        "acheteurId": widget.ide,
        "acheteurNom": widget.nom,
        "timestamp": now,
      }),
    };

    try {
      final response = await http.post(
        Uri.parse(nostrRelayUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(nostrEvent),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Commande enregistrée localement.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur HTTP : ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur réseau : $e")),
      );
    }
  }

  Future<void> _payerViaNWC() async {
    final Uri uri = Uri.parse(nwcUrl);
    final relay = uri.queryParameters["relay"];
    final secret = uri.queryParameters["secret"];
    final pubkey = uri.userInfo.replaceFirst("nwc://", "");

    if (relay == null || secret == null || pubkey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ URL NWC invalide")),
      );
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final event = {
      "kind": 23194,
      "created_at": now,
      "tags": [
        ["relays", relay],
        ["amount", widget.somme], // en sats
        ["memo", widget.q[0]["description"]],
      ],
      "content": "",
      "pubkey": pubkey,
    };

    try {
      final response = await http.post(
        Uri.parse(nostrRelayUrl), // Envoie à ton relay
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(event),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚡ Requête NWC envoyée")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur NWC : ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur NWC : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paiement Produit")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🛒 ${widget.q[0]['description']}",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "💰 Total: ${widget.somme} sats",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Enregistrer la commande"),
                onPressed: _payerCommandeLocalement,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.flash_on),
                label: Text("Payer via Lightning (NWC)"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _payerViaNWC,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


