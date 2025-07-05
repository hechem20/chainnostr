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
  Future<void> _payerCommande() async {
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
        Uri.parse("http://10.0.2.2:5000/events"), // Relay Nostr local
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(nostrEvent),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Paiement effectué avec succès")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exemple")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${widget.q[0]['description']} - Total: ${widget.somme} sat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _payerCommande,
              child: Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}

