import 'package:http_parser/http_parser.dart';
import 'package:demo1/models/location_data.dart';
import 'package:demo1/models/product.dart';
import 'package:demo1/scoped_models/connected_product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(products);
  }

  List<Product> get displayProducts {
    if (_showFavorites) {
      return (products.where((Product product) => product.isFavorite).toList());
    }
    return List.from(products);
  }

  String get selectedProductID {
    return selProductID;
  }

  Product get selectedProduct {
    if (selProductID == null) {
      return null;
    }
    return products.firstWhere((Product product) {
      return product.id == selProductID;
    });
  }

  int get selectedProductIndex {
    return products.indexWhere((Product product) {
      return product.id == selProductID;
    });
  }

  Future<bool> deleteProduct() {
    isLoading = true;
    final deletedProductID = selectedProduct.id;
    notifyListeners();
    return http
        .delete(
            'https://flutter-online-course.firebaseio.com/products/$deletedProductID.json?auth=${authenticatedUser.token}')
        .then((http.Response response) {
      isLoading = false;
      products.removeAt(selectedProductIndex);
      selProductID = null;
      notifyListeners();
      return true;
    }).catchError((error) {
      isLoading = false;
      notifyListeners();
      return false;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<Null> fetchProducts({onlyForUser = false,clearExisting=false}) {
    isLoading = true;
    if(clearExisting){
      products = [];
    }
    notifyListeners();
    return http
        .get(
            'https://flutter-online-course.firebaseio.com/products.json?auth=${authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      print(productListData);
      productListData.forEach((String productID, dynamic productData) {
        final Product product = Product(
            id: productID,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imagePath: productData['imagePath'],
            locationData: LocationData(
                address: productData['address'],
                lat: productData['location_lat'],
                lng: productData['location_lng']),
            imageURL: productData['imageUrl'],
            userEmail: productData['userEmail'],
            userID: productData['userID'],
            isFavorite: productData['wishListUsers'] == null
                ? false
                : (productData['wishListUsers'] as Map<String, bool>)
                    .containsKey(authenticatedUser.id));
        fetchProductList.add(product);
      });
      products = onlyForUser
          ? fetchProductList.where((Product product) {
              return product.userID == authenticatedUser.id;
            }).toList()
          : fetchProductList;
      isLoading = false;
      notifyListeners();
      selProductID = null;
    }).catchError((error) {
      isLoading = false;
      notifyListeners();
      return;
    });
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-flutter-online-course.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[0]));
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${authenticatedUser.token}';
    try {
      final streamResponse = await imageUploadRequest.send();
      final http.Response response =
          await http.Response.fromStream(streamResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong ' + json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addProducts(String title, String description, File image,
      double price, LocationData locData) async {
    isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);
    if (uploadData == null) {
      print('Upload failed');
      return false;
    }
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'price': price,
      'userEmail': authenticatedUser.email,
      'userID': authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'location_lat': locData.lat,
      'location_lng': locData.lng,
      'location_address': locData.address
    };
    return http //can use async await with try catch block
        .post(
            'https://flutter-online-course.firebaseio.com/products.json?auth=${authenticatedUser.token}',
            body: json.encode(productData))
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          imageURL: uploadData['imageUrl'],
          price: price,
          imagePath: uploadData['imagePath'],
          locationData: locData,
          userEmail: authenticatedUser.email,
          userID: authenticatedUser.id);
      products.add(newProduct);
      isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> updateProduct(String title, String description, File image,
      double price, LocationData locData) async {
    isLoading = true;
    notifyListeners();
    String imageUrl = selectedProduct.imageURL;
    String imagePath = selectedProduct.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload failed');
        return false;
      }
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': price,
      'location_lat': locData.lat,
      'location_lng': locData.lng,
      'location_address': locData.address,
      'userEmail': selectedProduct.userEmail,
      'userID': selectedProduct.userID
    };
    try {
       await http.put(
          'https://flutter-online-course.firebaseio.com/products/${selectedProduct.id}.json?auth=${authenticatedUser.token}',
          body: json.encode(updateData));
      isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          imageURL: imageUrl,
          imagePath: imagePath,
          price: price,
          locationData: locData,
          userEmail: selectedProduct.userEmail,
          userID: selectedProduct.userID);
      products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    } catch (error) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectProduct(String productID) {
    selProductID = productID;
    if (productID == null) {
      return;
    }
    notifyListeners();
  }

  void toggleProductFavoriteStatus(Product selectedProduct) async {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final int selectedProductIndex = products.indexWhere((Product product){
      return product.id == selectedProduct.id;
    });
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        imagePath: selectedProduct.imagePath,
        imageURL: selectedProduct.imageURL,
        locationData: selectedProduct.locationData,
        userEmail: selectedProduct.userEmail,
        userID: selectedProduct.userID,
        isFavorite: newFavoriteStatus);
    products[selectedProductIndex] = updatedProduct;
    notifyListeners();
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://flutter-online-course.firebaseio.com/products/'
          '${selectedProduct.id}/wishListUsers/'
          '${authenticatedUser.id}.json?'
          'auth=${authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-online-course.firebaseio.com/products/'
          '${selectedProduct.id}/wishListUsers/${authenticatedUser.id}.json?auth=${authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          imagePath: selectedProduct.imagePath,
          description: selectedProduct.description,
          price: selectedProduct.price,
          imageURL: selectedProduct.imageURL,
          locationData: selectedProduct.locationData,
          userEmail: selectedProduct.userEmail,
          userID: selectedProduct.userID,
          isFavorite: !newFavoriteStatus);
      products[selectedProductIndex] = updatedProduct;
      notifyListeners();
    }
//    selProductID = null;
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}
