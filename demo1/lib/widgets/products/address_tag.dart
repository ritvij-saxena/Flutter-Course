import 'package:flutter/material.dart';

class AddressTag extends StatelessWidget{
  final String address;

  AddressTag(this.address);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
              color: Colors.white ,
              width: 1.0 )
      ),
      child: Text(address),
    );
  }
}