import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MapApp());
}

class MapApp extends StatelessWidget {
  const MapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MapAppScreen());
  }
}

class MapAppScreen extends StatefulWidget {
  const MapAppScreen({super.key});

  @override
  State<MapAppScreen> createState() => _MapAppScreenState();
}

class _MapAppScreenState extends State<MapAppScreen> {
  late GoogleMapController mapController;

  Set<Polyline> polyline = {};
  Set<Marker> markers = {};
  List<LatLng> latlng = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // gotoCurrentLocation();
  }

  void gotoLocation(LatLng position1, LatLng position2) {
    // markers.clear();
    if (markers.isEmpty || markers.length <= 1) {
      markers.addAll({
        Marker(
          markerId: MarkerId('$position1'),
          position: position1,
          infoWindow: InfoWindow(title: '$position1'),
        ),
        Marker(
          markerId: MarkerId('$position2'),
          position: position2,
          infoWindow: InfoWindow(title: '$position2'),
        ),
      });
      latlng.addAll({position1, position2});
      polyline.addAll({
        Polyline(
          polylineId: PolylineId(position1.toString()),
          visible: true,
          //latlng is List<LatLng>
          points: latlng,
          color: Colors.blue,
        ),
        // Polyline(
        //   polylineId: PolylineId(position2.toString()),
        //   visible: true,
        //   //latlng is List<LatLng>
        //   points: latlng,
        //   color: Colors.blue,
        // ),
      });
    } else {
      polyline.clear();
      markers.clear();
      latlng.clear();
    }

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position2, zoom: 12),
      ),
    );
    setState(() {});
  }

  // void gotoCurrentLocation() async {
  //   if (!await checkLocationServicesPermission()) {
  //     return;
  //   }
  //   Geolocator.getPositionStream().listen((geoPosition) {
  //     gotoLocation(LatLng(geoPosition.latitude, geoPosition.longitude));
  //   });
  // }

  Future<bool> checkLocationServicesPermission() async {
    //check location services
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location service is disabled. Please allow it in the Settings for the app to work.',
          ),
        ),
      );
      return false;
    }

    //check permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      //request
      permission = await Geolocator.requestPermission();
      //2nd check
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission for accessing location is denied. Please enable it in the Settings',
            ),
          ),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permission for accessing location is denied. Please enable it in the Settings',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          polylines: polyline,
          onMapCreated: (controller) {
            mapController = controller;
          },
          markers: markers,
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: false,
          initialCameraPosition: CameraPosition(
            target: LatLng(15.98825509379408, 120.57358531970671),
            zoom: 10,
          ),
          onTap: (position) {
            gotoLocation(position, position);
            print(position.latitude);
            print(position.longitude);
          },
        ),
      ),
    );
  }
}
