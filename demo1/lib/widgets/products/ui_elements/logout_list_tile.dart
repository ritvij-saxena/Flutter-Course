import 'package:demo1/scoped_models/main.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class LogOutListTile extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel mainModel){
      return ListTile(
        title: Text('Logout'),
        leading: Icon(Icons.exit_to_app),
        onTap: (){
            mainModel.logout();
            /*Navigator.of(context).pushReplacementNamed('/');*/
      },);
    },);
  }
}