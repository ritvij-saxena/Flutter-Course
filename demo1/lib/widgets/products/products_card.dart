import 'package:demo1/models/product.dart';
import 'package:demo1/scoped_models/main.dart';
import 'package:demo1/widgets/products/address_tag.dart';
import 'package:demo1/widgets/products/price_tag.dart';
import 'package:demo1/widgets/products/ui_elements/title_default.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCard extends StatelessWidget {
  final Product products;


  ProductCard(this.products);

  Widget _buildRowForPriceTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: TitleDefault(products.title)),
        SizedBox(
          width: 8.0,
        ),
        PriceTag(products.price.toString())
      ],
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              model.selectProduct(products.id);
              Navigator.pushNamed<bool>(
                      context, '/product/' + products.id)
                  .then((_) => model.selectProduct(null));
            },
          ),
          IconButton(
              icon: Icon(products.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                model.selectProduct(products.id);
                model.toggleProductFavoriteStatus(products);
              })
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
              tag: products.id,
              child: FadeInImage(
                  image: products.imageURL == null
                      ? AssetImage('assets/food.jpg')
                      : NetworkImage(products.imageURL),
                  placeholder: AssetImage('assets/food.jpg'),
                  height: 300.0,
                  fit: BoxFit.cover)),
          Container(
            padding: EdgeInsets.only(top: 10.0),
            child: _buildRowForPriceTitle(),
          ),
          SizedBox(
            height: 6.0,
          ),
          AddressTag('West Loop, Chicago'),
          _buildButtonBar(context)
        ],
      ),
    );
  }
}
