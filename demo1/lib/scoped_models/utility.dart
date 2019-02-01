import 'package:demo1/scoped_models/connected_product.dart';

mixin UtilityModel on ConnectedProductsModel{

  bool get isLoading_{
    return isLoading;
  }

}