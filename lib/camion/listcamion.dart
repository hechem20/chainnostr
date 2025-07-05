import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ListCamion extends StatefulWidget {
  @override
  _ListCamionState createState() => _ListCamionState();
}

class _ListCamionState extends State<ListCamion> {
  List<dynamic> _records = [];
  Set<Marker> _markers = {};
  LatLng _center = LatLng(0, 0);
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _loadNostrData();
  }

  Future<void> _loadNostrData() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/events?kind=logistics_event"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> events = jsonDecode(response.body);

        List<dynamic> extracted = events.map((event) {
          final content = event['content'];
          final decodedContent = content is String ? jsonDecode(content) : content;

          return [
            BigInt.from(decodedContent['latitude']),
            BigInt.from(decodedContent['longitude']),
            decodedContent['speed'],
            decodedContent['temperature'],
            decodedContent['voyageId'],
            BigInt.from(DateTime.parse(decodedContent['timestamp'])
                .millisecondsSinceEpoch ~/ 1000),
          ];
        }).toList();

        setState(() {
          _records = extracted;
          _buildMarkers();
        });
      } else {
        print("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur chargement Nostr : $e");
    }
  }

  void _buildMarkers() {
    Set<Marker> markers = {};
    if (_records.isEmpty) return;

    for (int i = 0; i < _records.length; i++) {
      final data = _records[i];
      final lat = data[0].toInt() / 1e6;
      final lng = data[1].toInt() / 1e6;
      final speed = data[2];
      final temp = data[3];
      final id = data[4];
      final time = _formatTimestamp(data[5]);

      markers.add(
        Marker(
          markerId: MarkerId("point$i"),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: "$time | id=$id",
            snippet: "🚚 $speed km/h | 🌡 $temp°C",
          ),
        ),
      );

      if (i == _records.length - 1) {
        _center = LatLng(lat, lng);
      }
    }

    setState(() {
      _markers = markers;
      _mapReady = true;
    });
  }

  String _formatCoord(BigInt value) {
    return (value.toInt() / 1e6).toStringAsFixed(6);
  }

  String _formatTimestamp(BigInt timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    return DateFormat("dd/MM/yyyy HH:mm").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📍 Historique des trajets")),
      body: _records.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _mapReady
                      ? GoogleMap(
                          initialCameraPosition:
                              CameraPosition(target: _center, zoom: 12),
                          markers: _markers,
                          mapType: MapType.normal,
                        )
                      : Center(child: Text("Chargement carte...")),
                ),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final data = _records[index];
                      final lat = _formatCoord(data[0]);
                      final lng = _formatCoord(data[1]);
                      final speed = data[2];
                      final temp = data[3];
                      final id = data[4];
                      final time = _formatTimestamp(data[5]);

                      return Card(
                        child: ListTile(
                          title: Text("🕒 $time"),
                          subtitle: Text(
                            "📍 $lat, $lng\n🚚 $speed km/h | 🌡 $temp °C | id=$id",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

