import 'package:demo1/scoped_models/main.dart';
import 'package:demo1/widgets/products/ui_elements/adaptive_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:demo1/models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthState();
  }
}

class _AuthState extends State<AuthPage> with TickerProviderStateMixin {
  final Map<String, dynamic> credentials = {
    'email': null,
    'password': null,
    'terms': false
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;
  AnimationController controller;
  Animation<Offset> slideAnimation;

  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    slideAnimation =
        Tween<Offset>(
            begin: Offset(0.0, -1.0),
            end: Offset.zero)
            .animate(CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        colorFilter:
        ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
        fit: BoxFit.cover,
        image: AssetImage('assets/background.jpg'));
  }

  showWarningDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Terms and Conditions'),
            content:
            Text('Terms and Conditions are required to proceed further'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Invalid Email ID, try again';
        }
      },
      decoration: InputDecoration(
          labelText: 'Email',
          filled: true,
          fillColor: Colors.white.withOpacity(0.2)),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String value) {
        credentials['email'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeIn),
      child: SlideTransition(
        position: slideAnimation,
        child: TextFormField(
          validator: (String value) {
            if (_passwordTextController.text != value &&
                _authMode == AuthMode.SignUp) {
              return 'Invalid Password';
            }
          },
          decoration: InputDecoration(
              labelText: 'Confirm Password',
              filled: true,
              fillColor: Colors.white.withOpacity(0.2)),
          keyboardType: TextInputType.text,
          obscureText: true,
        ),),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.length < 8) {
          return 'Password empty or invalid length, try again';
        }
      },
      decoration: InputDecoration(
          labelText: 'Password',
          filled: true,
          fillColor: Colors.white.withOpacity(0.2)),
      keyboardType: TextInputType.text,
      obscureText: true,
      onSaved: (String value) {
        credentials['password'] = value;
      },
    );
  }

  Widget _buildSwitchTile() {
    return SwitchListTile(
      activeColor: Colors.red,
      value: credentials['terms'],
      onChanged: (bool value) {
        setState(() {
          credentials['terms'] = value;
        });
      },
      title: Text('Accept Terms and Conditions'),
    );
  }

  void onLoginButtonPressed(Function authenticate) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (credentials['terms']) {
      _formKey.currentState.save();
      Map<String, dynamic> successInformation;
      successInformation = await authenticate(
          credentials['email'], credentials['password'], _authMode);
      if (successInformation['success']) {
        /*Navigator.pushReplacementNamed(context, '/');*/
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('An Error Occurred!'),
                content: Text(successInformation['message']),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    } else {
      showWarningDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(image: _buildBackgroundImage()),
        padding: EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: _buildEmailTextField(), //text field for email
                    ),
                    SizedBox(height: 10.0),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child:
                      _buildPasswordTextField(), //text field for password
                    ),
                    SizedBox(height: 10.0),
                    DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: _buildConfirmPasswordTextField() //text field for password confirmation
                    ),
                    SizedBox(height: 10.0),
                    DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.3)),
                      child:
                      _buildSwitchTile(), //switch tile for terms and condition
                    ),
                    SizedBox(height: 10.0),
                    Center(child: ScopedModelDescendant<MainModel>(builder:
                        (BuildContext context, Widget child, MainModel model) {
                      return model.isLoading
                          ? Center(child: AdaptiveProgressIndicator())
                          : RaisedButton(
                          child: Text(_authMode == AuthMode.Login
                              ? 'Login'
                              : 'SignUp'),
                          onPressed: () =>
                              onLoginButtonPressed(model.authenticate));
                    })),
                    FlatButton(
                        child: Text(
                          'Switch To ${_authMode == AuthMode.Login
                              ? 'SignUp'
                              : 'Login'}',
                        ),
                        onPressed: () {
                          if (_authMode == AuthMode.Login) {
                            setState(() {
                              _authMode = AuthMode.SignUp;
                            });
                            controller.forward();
                          } else {
                            setState(() {
                              _authMode = AuthMode.Login;
                            });
                            controller.reverse();
                          }
                        })
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
