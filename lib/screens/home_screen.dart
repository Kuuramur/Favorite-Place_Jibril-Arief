import 'dart:convert'; // For base64Decode

import 'package:fav_place/models/user_login.dart';
import 'package:fav_place/providers/data_provider.dart';
import 'package:fav_place/screens/add_place.dart';
import 'package:fav_place/screens/detail_place.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
  });

  final UserLogin user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          title: const Text("My Favorite Place"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPlace(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: value.favPlaceItem.isEmpty
            ? const Center(
                child: Text("No data"),
              )
            : ListView.builder(
                reverse: true,
                itemCount: value.favPlaceItem.length,
                padding: const EdgeInsets.only(bottom: 70),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPlace(
                            favPlace: value.favPlaceItem,
                            index: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 300,
                      margin: const EdgeInsets.fromLTRB(17, 0, 16, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      child: Stack(
                        children: [
                          // Background Image
                          Hero(
                            tag: value.favPlaceItem[index].image!,
                            transitionOnUserGestures: true,
                            child: Container(
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(
                                        value.favPlaceItem[index].image!),
                                  ),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.5),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Positioned ListTile
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  value.favPlaceItem[index].name.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  value.favPlaceItem[index].location.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                          'https://developers.google.com/static/maps/images/landing/hero_geocoding_api.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
