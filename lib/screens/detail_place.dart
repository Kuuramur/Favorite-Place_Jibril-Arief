import 'dart:convert';

import 'package:fav_place/models/favorite_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetailPlace extends StatelessWidget {
  final List<FavoritePlaceItem> favPlace;
  final int index;

  const DetailPlace({
    super.key,
    required this.favPlace,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final FavoritePlaceItem place = favPlace[index];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place.name!),
            Text(
              place.location!,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Hero(
            tag: place.image!,
            transitionOnUserGestures: true,
            child: Container(
              height: 300,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadiusDirectional.circular(10),
                image: DecorationImage(
                  image: MemoryImage(base64Decode(place.image!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(place.lat!, place.lng!),
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(place.lat!, place.lng!),
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
