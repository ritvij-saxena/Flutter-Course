import 'package:demo1/pages/product_edit.dart';
import 'package:demo1/scoped_models/main.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductListPage extends StatefulWidget {
  final MainModel mainModel;

  ProductListPage(this.mainModel);

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  initState() {
    widget.mainModel.fetchProducts(onlyForUser: true,clearExisting: true);
    super.initState();

  }

  Widget _buildEditIconButton(
      BuildContext context, int index, MainModel model) {
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          model.selectProduct(model.allProducts[index].id);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return ProductEditPage();
          })).then((_) {
            model.selectProduct(null);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
                onDismissed: (DismissDirection direction) {
                  if (direction == DismissDirection.endToStart ||
                      direction == DismissDirection.startToEnd) {
                    model.selectProduct(model.allProducts[index].id);
                    model.deleteProduct();
                  }
                },
                key: Key(model.allProducts[index].title),
                background: Container(
                  color: Colors.red,
                ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(model.allProducts[index].imageURL),
                      ),
                      title: Text(model.allProducts[index].title),
                      subtitle: Text(
                          '\$${model.allProducts[index].price.toString()}'),
                      trailing: _buildEditIconButton(context, index, model),
                    ),
                    Divider()
                  ],
                ));
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }
}
