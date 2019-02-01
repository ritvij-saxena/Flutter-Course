import 'package:demo1/models/product.dart';
import 'package:demo1/models/user.dart';
import 'package:scoped_model/scoped_model.dart';


mixin ConnectedProductsModel on Model {
  List<Product> products = [];
  User authenticatedUser;
  String selProductID;
  bool isLoading = false;


}
