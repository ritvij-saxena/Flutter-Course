import 'package:demo1/models/product.dart';
import 'package:demo1/widgets/products/ui_elements/title_default.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:map_view/map_view.dart';
import '../widgets/products/product_fab.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage(this.product);

  void showMap() {
    final markers = [Marker('position', 'Position', 40.758896, -73.985130)];
    final mapView = MapView();
    final cameraPosition =
        CameraPosition(Location(40.758896, -73.985130), 15.0);
    mapView.show(
        MapOptions(
            mapViewType: MapViewType.normal,
            title: 'Product Location',
            initialCameraPosition: cameraPosition),
        toolbarActions: [ToolbarAction('Close', 1)]);

    mapView.onToolbarAction.listen((int id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });

    mapView.onMapReady.listen((_) {
      mapView.setMarkers(markers);
    });
  }

  showWarningDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Final Action !'),
            actions: <Widget>[
              FlatButton(
                child: Text('Discard'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Continue'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });
  }

  Widget _buildRowForPrice(double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.deepOrange),
          child: Container(
              padding: EdgeInsets.all(10.0),
              child: Text('\$' + price.toString())
              /*RaisedButton(
                  child: Text('Delete'),
                  color: Theme
                      .of(context)
                      .primaryColorLight,
                  onPressed: () => showWarningDialog(context),
                )*/
              ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          print('back pressed');
          Navigator.pop(context, false);
          return Future.value(false);
        },
        child: Scaffold(
//          appBar: AppBar(
//            centerTitle: true,
//            title: Text(product.title),
//          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 256.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(product.title),
                  background: Hero(
                      tag: product.id,
                      child: FadeInImage(
                        image: NetworkImage(product.imageURL),
                        placeholder: AssetImage('assets/food.jpg'),
                        height: 300.0,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  //cross left to right
                  //main top to bottom
                  /*mainAxisAlignment: MainAxisAlignment.center,*/

                  Container(
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    child: TitleDefault(product.title),
                  ),
                  SizedBox(height: 2.0),
                  _buildRowForPrice(product.price),
                  Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        product.description,
                        textAlign: TextAlign.center,
                      )),
                  RaisedButton(
                      child: Text('Full Map View'),
                      onPressed: () {
                        showMap();
                      })
                ]),
              )
            ],
          ) /*Center(child: Text('This is product page'))*/,
          floatingActionButton: ProductFAB(product),
        ));
  }
}
