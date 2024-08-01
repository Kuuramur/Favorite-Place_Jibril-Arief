// import 'package:favor'

import 'package:fav_place/models/favorite_place.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  final List<FavoritePlaceItem> favPlaceItem = [];

  void addPlace(FavoritePlaceItem item) {
    favPlaceItem.add(
      FavoritePlaceItem(
        name: item.name,
        image: item.image,
        location: item.location,
        lat: item.lat,
        lng: item.lng,
      ),
    );
    notifyListeners();
  }
}
