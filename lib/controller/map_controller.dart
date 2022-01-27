import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvp_camera/app/constant/controllers.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../model/file_data_model.dart';

class MapController extends GetxController {
  static MapController instance = Get.find();

  late Stream<Position> _geoLocationStream;
  late GoogleMapController controller;
  RxSet<Marker> imageMarkers = <Marker>{}.obs;
  late BitmapDescriptor bitmapDescriptor;
  Completer<GoogleMapController> googleMapController = Completer();

  // INITIALIZE DEFAULT VALUES
  Rx<Position> userLocation = Position(
    longitude: 0.0,
    latitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  ).obs;
  Rx<CameraPosition> currentLocationCameraPosition =
      const CameraPosition(target: LatLng(0.0, 0.0)).obs;

  @override
  void onInit() {
    super.onInit();
    _geoLocationStream = Geolocator.getPositionStream(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best));
    listenToUserLocation();
  }

  Future<void> listenToUserLocation() async {
    bool locationPermission = await checkLocationPermission();
    debugPrint("Location permission: $locationPermission");

    if (locationPermission) {
      userLocation.bindStream(_geoLocationStream);
    } else {
      await Geolocator.requestPermission();
    }
    initCurrentLocationCameraPosition();
  }

  Future<void> createMarkers(List<FileDataModel> imageFiles) async {
    // ITERATING THROUGH THE FILE AND GETTING [LAT LNG] FROM THEIR INSTANCE VARIABLES FOR SETTING UP MARKERS

    print("createMarkers() FUNCTION CALLED");

    // Set<Marker> temp = {};
    // int markerId = 0;
    // print(imageFiles.length);
    // imageFiles.forEach((element) {
    //   markerId +=1 ;
    //   print(element.position);
    //   temp.add(
    //     Marker(
    //         markerId: MarkerId('$markerId'),
    //         position: element.position,
    //         infoWindow: const InfoWindow(title: "TEST")),
    //   );
    // });
    // imageMarkers.value = temp;
    // print(temp);
    // print(imageMarkers);
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return LocationPermission.always == permission;
  }

  Future<void> initCurrentLocationCameraPosition() async {
    currentLocationCameraPosition.value = CameraPosition(
        target:
            LatLng(userLocation.value.latitude, userLocation.value.longitude),);
  }

  void onMapCreated(GoogleMapController controller) {
    if (!googleMapController.isCompleted) {
      googleMapController.complete(controller);

      animateCamera(CameraPosition(
          target: LatLng(
            userLocation.value.latitude,
            userLocation.value.longitude,
          ),
          zoom: 50.00));
    }
  }

  Future<void> animateCamera(CameraPosition position) async {
    controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }
}
