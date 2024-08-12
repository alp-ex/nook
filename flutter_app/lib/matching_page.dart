import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MatchingViewPage extends StatefulWidget {
  const MatchingViewPage({super.key});

  @override
  State<MatchingViewPage> createState() => _MatchingViewPageState();
}

class _MatchingViewPageState extends State<MatchingViewPage> {
  MapboxMapController? mapController;
  LatLng? userLocation;

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  void _onMapClick(LatLng coordinates) async {
    print('Map clicked at: $coordinates');
    await _fetchPOIDetails(coordinates.latitude, coordinates.longitude);
  }

  void _showPOIDetails(Map<String, dynamic> place) {
    final name = place['text'] ?? 'POI Details';
    final placeName = place['place_name'] ?? 'No details available';
    final category =
        (place['properties'] != null && place['properties']['category'] != null)
            ? place['properties']['category']
            : 'Unknown Category';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: $category'),
              Text('Place Name: $placeName'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchPOIDetails(double latitude, double longitude) async {
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
    print(accessToken);
    final url =
        'https://api.mapbox.com/search/v1/category?proximity=$longitude,$latitude&access_token=$accessToken&categories=poi';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        final place = data['features'][0];
        _showPOIDetails(place);
      } else {
        print('No POI found near the location');
      }
    } else {
      print('Failed to load POI details: ${response.statusCode}');
    }
  }

  void _enableLocationTracking() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: userLocation ?? const LatLng(0, 0), zoom: 14),
      ),
    );
  }

  void _onUserLocationUpdated(UserLocation location) {
    final newLocation =
        LatLng(location.position.latitude, location.position.longitude);
    if (newLocation != userLocation) {
      setState(() {
        userLocation = newLocation;
      });

      mapController?.clearSymbols();
      mapController?.addSymbol(SymbolOptions(
        geometry: userLocation!,
        iconImage: 'dest-pin',
        iconColor: '#FF0000',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];

    print(accessToken);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_searching),
            onPressed: _enableLocationTracking,
          ),
        ],
      ),
      body: MapboxMap(
        styleString: "mapbox://styles/mapbox/streets-v11",
        accessToken: accessToken,
        onMapCreated: _onMapCreated,
        onMapClick: (point, coordinates) => _onMapClick(coordinates),
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 2.0,
        ),
        myLocationEnabled: true,
        myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
        onUserLocationUpdated: _onUserLocationUpdated,
      ),
    );
  }
}
