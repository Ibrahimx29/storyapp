import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickMapScreen extends StatefulWidget {
  final String title;

  const PickMapScreen({
    super.key,
    required this.title,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  final dicodingOffice = const LatLng(-6.8957473, 107.6337669);

  late GoogleMapController mapController;

  late final Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  zoom: 18,
                  target: dicodingOffice,
                ),
                markers: markers,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  final marker = Marker(
                    markerId: const MarkerId("source"),
                    position: dicodingOffice,
                  );
                  setState(() {
                    mapController = controller;
                    markers.add(marker);
                  });
                },
                myLocationEnabled: true,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton(
                  child: const Icon(Icons.my_location),
                  onPressed: () {
                    // onMyLocationButtonPress();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void defineMarker(LatLng latLng) {
    final marker = Marker(
      markerId: const MarkerId("source"),
      position: latLng,
    );
    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }

  /*void onMyLocationButtonPress() async {
    final Location location = Location();
    late bool serviceEnabled;
    late PermissionStatus permissionGranted;
    late LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print("Location services is not available");
        }
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        if (kDebugMode) {
          print("Location permission is denied");
        }
        return;
      }
    }

    locationData = await location.getLocation();
    final latLng = LatLng(locationData.latitude!, locationData.longitude!);

    defineMarker(latLng);

    mapController.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }*/
}
