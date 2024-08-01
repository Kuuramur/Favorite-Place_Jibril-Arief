import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fav_place/models/favorite_place.dart';
import 'package:fav_place/providers/data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class AddPlace extends StatefulWidget {
  const AddPlace({super.key});

  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  final TextEditingController textEditingController = TextEditingController();
  String city = '', img64 = '';
  bool photos = false;
  bool location = false;
  bool map = false;

  CameraController? cameraController;
  List? cameras;
  late int selectedCameraIndexk = 0;

  File? imageFile;
  final imagepicker = ImagePicker();

  double lat = 0.0;
  double lng = 0.0;

  late final _mapController = MapController();

  Marker buildMarker(LatLng coordinates) {
    return Marker(
      point: LatLng(coordinates.latitude, coordinates.longitude),
      child: const Icon(
        CupertinoIcons.location_solid,
        color: Colors.purple,
        size: 38,
      ),
    );
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always) {
      return true;
    } else {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  void initState() {
    checkLocationPermission();
    super.initState();
  }

  getCityLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      setState(() {
        city =
            '${placemarks[0].locality}. ${placemarks[0].administrativeArea}. ${placemarks[0].country}';
        lat = lat;
        lng = lng;
      });
      _mapController.move(LatLng(lat, lng), 16.0);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  getCityFormMyPosition() async {
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      debugPrint(position.latitude.toString());
      debugPrint(position.longitude.toString());
      setState(() {
        city =
            '${placemarks[0].locality}. ${placemarks[0].administrativeArea}. ${placemarks[0].country}';
        lat = lat;
        lng = lng;
      });
      _mapController.move(LatLng(lat, lng), 16.0);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(title: 'Cropper', aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
          ])
        ],
      );
      if (croppedFile != null) {
        imageCache.clear();
        setState(() {
          this.imageFile = File(croppedFile.path);
          final bytes = File(imageFile.path).readAsBytesSync();
          img64 = base64Encode(bytes);
          debugPrint(img64);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      await imagepicker
          .pickImage(source: ImageSource.gallery, imageQuality: 50)
          .then((value) {
        if (value != null) {
          _cropImage(File(value.path));

          // setState(() {
          //   imageFile = File(value.path);
          // });
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getImageFromCamera() async {
    try {
      await imagepicker
          .pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      )
          .then((value) {
        if (value != null) {
          _cropImage(File(value.path));
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Place"),
        actions: [
          IconButton(
            onPressed: () {
              final favPlace = context.read<DataProvider>();
              favPlace.addPlace(
                FavoritePlaceItem(
                  name: textEditingController.text,
                  image: img64,
                  location: city,
                  lat: lat,
                  lng: lng,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          imageFile != null
              ? SizedBox(
                  height: 300,
                  width: MediaQuery.sizeOf(context).width,
                  child: Center(
                    // child: Text("Preview"),
                    child: ClipRRect(
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          image: DecorationImage(
                            image: FileImage(
                              imageFile!,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          TextField(
            controller: textEditingController,
            decoration: const InputDecoration(
              hintText: "Place Name",
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Colors.grey.shade200),
                  ),
                  onPressed: () async {
                    setState(() {
                      location = !location;
                      map = false;
                    });

                    if (await checkLocationPermission()) {
                      getCityFormMyPosition();
                    }
                  },
                  icon: const Icon(
                    CupertinoIcons.location,
                    size: 14,
                  ),
                  label: const Text("Use my location"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton.icon(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.purple),
                  ),
                  onPressed: () {
                    setState(() {
                      map = !map;
                    });
                  },
                  icon: const Icon(
                    CupertinoIcons.map,
                    color: Colors.white,
                    size: 14,
                  ),
                  label: const Text(
                    "Choose on map",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          city != ''
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.map_pin_ellipse,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        city.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                )
              : const SizedBox.shrink(),
          Visibility(
            visible: map,
            child: Column(
              children: [
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(-6.2115983, 106.8213),
                        initialZoom: 16.0,
                        onTap: (tapPosition, point) {
                          LatLng(point.latitude, point.longitude);
                          buildMarker(point);
                          setState(() {
                            lat = point.latitude;
                            lng = point.longitude;
                            getCityLatLng(lat, lng);
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://www.google.com/maps/vt?lyrs=m@189&gl=cn&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com-example-app',
                        ),
                        MarkerLayer(
                          markers: [
                            buildMarker(LatLng(lat, lng)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _getImageFromCamera();
                },
                child: const Text("Camera"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _getImageFromGallery();
                },
                child: const Text("Gallery"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
