import 'package:flutter/material.dart';
import './location_data.dart';

class Product {
  final String title;
  final String description;
  final double price;
  final String imageURL;
  final bool isFavorite;
  final String userEmail;
  final String imagePath;
  final String userID;
  final String id;
  final LocationData locationData;

  Product(
      {@required this.title,
      @required this.description,
      @required this.price,
      @required this.imagePath,
      @required this.imageURL,
      this.isFavorite = false,
      @required this.userEmail,
      @required this.userID,
      @required this.locationData,
      @required this.id});
}
