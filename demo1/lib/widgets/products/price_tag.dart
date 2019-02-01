import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget{
  final String price;

  PriceTag(this.price);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Text('\$$price'),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(10.0)
      ),
    );
  }

}