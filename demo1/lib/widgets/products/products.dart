import 'package:demo1/models/product.dart';
import 'package:demo1/scoped_models/main.dart';
import 'package:demo1/widgets/products/products_card.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Products extends StatelessWidget {

  Widget _buildProductList(List<Product> products) {
    if (products.length > 0) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) => ProductCard(products[index]),
        itemCount: products.length,
      );
    } else {
      return Center(
        child: Text('No products found , please add some'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){
        return _buildProductList(model.displayProducts);
      },
    );
  }
}
