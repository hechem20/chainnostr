import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:suiviedeschaine/camion/listcamion.dart';

class AjoutCamion extends StatefulWidget {
  final String userRole;
  AjoutCamion({required this.userRole});
  @override
  _AjoutCamionState createState() => _AjoutCamionState();
}

class _AjoutCamionState extends State<AjoutCamion> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _currentPosition = LatLng(0, 0);
  double _currentSpeed = 0;
  String _status = "⏳ Initialisation...";
  late Timer _timer;



  @override
  void initState() {
    super.initState();
    _requestLocationPermissionAndStartTracking();
    //_startTracking();
    //_startSendTimer();
  }

 
  Future<void> _requestLocationPermissionAndStartTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startTracking();
    } else {
      setState(() {
        _status = "❌ Permission de localisation refusée.";
      });
    }
  }

  void _startTracking() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position pos) {
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _currentSpeed = pos.speed * 3.6; // m/s en km/h
      });
    });
  }

  void _showVoyageDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Identité du voyage"),
        content: TextField(
          controller: _controller,
          decoration:
              InputDecoration(hintText: "Entrer l'identifiant du voyage"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final String voyageId = _controller.text;

              _timer = Timer.periodic(Duration(minutes: 1), (_) async {
                await _sendToBlockchain(voyageId);
              });

              setState(() {
                _status = "⏱ Démarrage de l’envoi automatique chaque 20 min.";
              });
            },
            child: Text("Lancer"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendToBlockchain(String voyageId) async {
  int lat = (_currentPosition.latitude * 1e6).toInt();
  int lng = (_currentPosition.longitude * 1e6).toInt();
  int speed = _currentSpeed.toInt();
  int temp = 20 + Random().nextInt(10); // Simulation température

  final nostrEvent = {
    "kind": "logistics_event",
    "tags": [["voyage", voyageId]],
    "content": {
      "latitude": lat,
      "longitude": lng,
      "speed": speed,
      "temperature": temp,
      "timestamp": DateTime.now().toUtc().toIso8601String(),
    },
  };

  try {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/events"), // Ton relay Nostr
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(nostrEvent), 
    );

    if (response.statusCode == 200) {
      setState(() {
        _status = "✅ Données envoyées à ${DateTime.now().toLocal()}";
      });
    } else {
      setState(() {
        _status = "❌ Erreur HTTP ${response.statusCode}";
      });
    }
  } catch (e) {
    setState(() {
      _status = "❌ Exception : $e";
    });
  }
}


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camion connecté")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentPosition, zoom: 15),
            myLocationEnabled: true,
            markers: {
              Marker(markerId: MarkerId("camion"), position: _currentPosition),
            },
            onMapCreated: (controller) => _controller.complete(controller),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "📍 Position : ${_currentPosition.latitude.toStringAsFixed(5)}, ${_currentPosition.longitude.toStringAsFixed(5)}"),
                    Text(
                        "🚚 Vitesse : ${_currentSpeed.toStringAsFixed(1)} km/h"),
                    Text("⛓ Statut : $_status"),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'listBtn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListCamion()),
              );
            },
            child: Icon(Icons.local_shipping),
          ),
          SizedBox(height: 10),
          if (widget.userRole == "ouner")
            FloatingActionButton(
              heroTag: 'sendBtn',
              onPressed: () => _showVoyageDialog(context),
              child: Icon(Icons.send),
            ),
        ],
      ),
    );
  }
}
