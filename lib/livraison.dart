import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DeliveryPointsPage(),
    );
  }
}

class DeliveryPointsPage extends StatefulWidget {
  @override
  _DeliveryPointsPageState createState() => _DeliveryPointsPageState();
}

class _DeliveryPointsPageState extends State<DeliveryPointsPage> {
  late GoogleMapController mapController;

  final List<LatLng> deliveryPoints = [
    LatLng(48.8566, 2.3522), // Paris
    LatLng(40.7128, -74.0060), // New York
    LatLng(51.5074, -0.1278), // London
  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addDeliveryPoint() {
    // Logique pour ajouter un nouveau point de livraison
    setState(() {
      deliveryPoints.add(LatLng(34.0522, -118.2437)); // Los Angeles
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Points de Livraison"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: deliveryPoints.isNotEmpty ? deliveryPoints[0] : LatLng(0, 0),
                zoom: 10,
              ),
              markers: deliveryPoints
                  .map((point) => Marker(
                        markerId: MarkerId(point.toString()),
                        position: point,
                        infoWindow: InfoWindow(title: 'Point de livraison'),
                      ))
                  .toSet(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addDeliveryPoint,
              child: Text("Ajouter un Point de Livraison"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: deliveryPoints.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Point ${index + 1}"),
                  subtitle: Text(
                      "Latitude: ${deliveryPoints[index].latitude}, Longitude: ${deliveryPoints[index].longitude}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        deliveryPoints.removeAt(index);
                      });
                    },
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
