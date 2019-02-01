import 'package:demo1/scoped_models/connected_product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:demo1/models/auth.dart';
import 'package:demo1/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:rxdart/subjects.dart';

mixin UserModel on ConnectedProductsModel {
  Timer authTimer;
  PublishSubject<bool> userSubject = PublishSubject();
  User get user{
    return authenticatedUser;
  }

  PublishSubject<bool> get userSubject_{
    return userSubject;
  }

  Future<Map<String,dynamic>> authenticate(String email, String password , [AuthMode mode = AuthMode.Login] ) async {
    //authenticatedUser = User(id: '12345', email: email, password: password);
    isLoading = true;
    notifyListeners();
    final Map<String,dynamic> loginData = {
      'email' : email,
      'password' : password,
      'returnSecureToken' : true
    };
    http.Response response;
    if(mode == AuthMode.Login){
      response = await http.post('https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAwrv13MViDNTB-PFWacScg_ApHedXT5M4',
          body: json.encode(loginData),
          headers: {'Content-Type' :'application/json'}
      );
    } else {
      response = await http.post('https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAwrv13MViDNTB-PFWacScg_ApHedXT5M4',
          body: json.encode(loginData),
          headers: {'Content-Type' :'application/json'}
      );
    }

    final Map<String,dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong!';
    if(responseData.containsKey('idToken')){
      hasError = false;
      message = 'Aunthentication Succeeded';
      authenticatedUser = User(
          id:responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime = now.add(Duration(seconds:int.parse(responseData['expiresIn']) ));
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('token', responseData['idToken']);
      preferences.setString('email', email);
      preferences.setString('userId', responseData['localId']);
      preferences.setString('expiryTime', expiryTime.toIso8601String());
    }
    else if(responseData['error']['message']== 'EMAIL_EXISTS'){
      message = 'Email already exists';
    }
    else if(responseData['error']['message']== 'EMAIL_NOT_FOUND'){
      message = 'Email doesnt exists';
    }
    else if(responseData['error']['message']== 'INVALID_PASSWORD'){
      message = 'invalid password';
    }
    isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message };

  }

  void autoAuthenticate() async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String token = preferences.getString('token');
    final String expiryTime = preferences.getString('expiryTime');
    if(token!=null){
      final DateTime now = DateTime.now();
      final parseExpiryTime = DateTime.parse(expiryTime);
      if(parseExpiryTime.isBefore(now)){
        authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String email = preferences.getString('email');
      final String userId = preferences.getString('userId');
      final int tokenSpan = parseExpiryTime.difference(now).inSeconds;
      authenticatedUser = User(id: userId, email: email , token: token);
      userSubject.add(true);
      setAuthTimeout(tokenSpan);
      notifyListeners();
    }
  }

  void logout() async{
    authenticatedUser = null;
    authTimer.cancel();
    selProductID = null;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('token');
    preferences.remove('email');
    preferences.remove('userId');
    userSubject.add(false);
  }

  void setAuthTimeout(int time){
    authTimer = Timer(Duration(seconds: time),logout);
  }


}