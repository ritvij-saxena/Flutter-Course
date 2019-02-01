import 'package:demo1/scoped_models/main.dart';
import 'package:flutter/material.dart';
import '../widgets/products/products.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:demo1/widgets/products/ui_elements/logout_list_tile.dart';

class ProductsPage extends StatefulWidget {
  final MainModel mainModel;
  ProductsPage (this.mainModel);

  @override
  State<StatefulWidget> createState() {
    return _ProductPageState();
  }
}

class _ProductPageState extends State<ProductsPage>{
  @override
  initState(){
    super.initState();
    widget.mainModel.fetchProducts();
  }
  Widget _buildDrawer(BuildContext context){
    return Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text('Choose'),
              automaticallyImplyLeading: false,
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            ),
            Divider(),
            LogOutListTile()
          ],
        )
    );
  }

  Widget _buildProductsList(){
    return ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel model) {
      Widget content = Center(
        child: Text('No Products Found'));
      if(model.displayProducts.length > 0 && !model.isLoading_){
          content = Products();
      }
      else if(model.isLoading_){
        content = Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
          onRefresh: model.fetchProducts,
          child: content);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //end drawer - right
      drawer: _buildDrawer(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text('EasyList'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model){
              return IconButton(
                icon: Icon(model.displayFavoritesOnly?Icons.favorite : Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
                color: Colors.red,
              );
              },
          )
        ],
      ),
      body: _buildProductsList(),
    );
  }
}
