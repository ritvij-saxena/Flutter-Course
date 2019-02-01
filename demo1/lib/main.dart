import 'package:demo1/models/product.dart';
import 'package:demo1/scoped_models/main.dart';
import 'package:demo1/shared/adaptive_theme.dart';
import 'package:flutter/material.dart';
/*import 'package:flutter/rendering.dart';*/
import 'package:scoped_model/scoped_model.dart';
import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';
import 'package:map_view/map_view.dart';
//import 'package:flutter/services.dart';
import 'package:demo1/widgets/products/helper/custom_route.dart';


void main() {
  /*debugPaintSizeEnabled=true;*/
  MapView.setApiKey('AIzaSyBjD-J1bPXyniHW-hWKGO_o4a1zcePeBpI');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel mainModel = new MainModel();
//  final platformChannel = MethodChannel('Battery Status');
  bool isAuthenticatedCheck = false;

//  Future<Null> getBatteryLevel() async{
////    String batteryLevel;
////    try {
////      final int result = await platformChannel.invokeMethod('Check Battery Level');
////      batteryLevel = 'Battery level is $result %';
////    } catch (error) {
////      batteryLevel = 'Failed to get Battery Level';
////    }
////    print(batteryLevel);
////  }
  @override
  void initState() {
    mainModel.autoAuthenticate();
    mainModel.userSubject_.listen((bool isAuthenticated){
      setState(() {
        isAuthenticatedCheck = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel> (
      model: mainModel,
      child: MaterialApp(
        theme: getAdaptiveThemeData(context),
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) => !isAuthenticatedCheck ? AuthPage() : ProductsPage(mainModel),
          '/admin': (BuildContext context) =>!isAuthenticatedCheck ? AuthPage() : ProductsAdminPage(mainModel),
        },
        onGenerateRoute: (RouteSettings settings) {
          if(!isAuthenticatedCheck){
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => AuthPage());
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productID = pathElements[2];
            final Product product = mainModel.allProducts.firstWhere( (Product product){
                  return product.id == productID;
            });
            mainModel.selectProduct(productID);
            return CustomRoute<bool>(
                builder: (BuildContext context) => !isAuthenticatedCheck ? AuthPage() : ProductPage(product));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings){
          return MaterialPageRoute(
              builder: (BuildContext context) => !isAuthenticatedCheck ? AuthPage() : ProductsPage(mainModel));
        },
      ),
    );
  }
}
