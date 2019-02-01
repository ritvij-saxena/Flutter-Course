import 'package:demo1/scoped_models/connected_product.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:demo1/scoped_models/products.dart';
import 'package:demo1/scoped_models/user.dart';
import 'package:demo1/scoped_models/utility.dart';

class MainModel extends Model with ConnectedProductsModel,UserModel,ProductsModel,UtilityModel{

}