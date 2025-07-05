import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class VisualisationClient extends StatefulWidget {
  @override
  _VisualisationClientState createState() => _VisualisationClientState();
}

class _VisualisationClientState extends State<VisualisationClient> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController controller = MobileScannerController();
  String qrId = '';
  String produitInfo = '';
  List<int> p = [];

  final String nostrRelayUrlBase = "http://10.0.2.2:5000/products";

  Future<void> getProduit(String id) async {
    try {
      final response = await http.get(Uri.parse('$nostrRelayUrlBase/$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // On s'attend à un JSON avec ce format côté backend:
        // {
        //   "nom": "...",
        //   "origine": "...",
        //   "agriculture": "...",
        //   "dateFabrication": "...",
        //   "dateExpiration": "...",
        //   "etat": "...",
        //   "dateEnregistrement": "...",
        //   "temperatures": [int, int, ...]
        // }

        setState(() {
          produitInfo =
              "Nom: ${data['nom']}\nOrigine: ${data['origine']}\nAgriculture: ${data['agriculture']}\nDate fab: ${data['dateFabrication']}\nDate exp: ${data['dateExpiration']}\nÉtat: ${data['etat']}\nDate: ${data['dateEnregistrement']}";
          p = List<int>.from(data['temperatures']);
        });
      } else {
        setState(() {
          produitInfo = "Produit non trouvé ou erreur serveur.";
          p = [];
        });
      }
    } catch (e) {
      setState(() {
        produitInfo = "Erreur réseau : $e";
        p = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Infos Produit via Nostr')),
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
                    produitInfo = "Chargement...";
                    p = [];
                  });
                  getProduit(qrId);
                  controller.stop();
                }
              },
            ),
          ),
          if (produitInfo.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(produitInfo, style: TextStyle(fontSize: 16)),
            ),
          if (p.isNotEmpty)
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: List.generate(
                          p.length,
                          (i) => FlSpot(i.toDouble(), p[i].toDouble()),
                        ),
                        barWidth: 3,
                        color: Colors.blue,
                      ),
                    ],
                    extraLinesData: ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                        y: 25,
                        color: Colors.red,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                      ),
                      HorizontalLine(
                        y: 20,
                        color: Colors.green,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                      ),
                    ]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
