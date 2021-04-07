import 'dart:math';

import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  static const String routeName = "/auth";
  @override
  Widget build(BuildContext context) {
    final Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(215, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTitle(context),
                  Flexible(
                    child: AuthCard(),
                    flex: deviceSize.width > 600 ? 2 : 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Flexible buildTitle(BuildContext context) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 94,
        ),
        transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.deepOrange.shade900,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black26,
                offset: Offset(0, 2),
              ),
            ]),
        child: Text(
          "My Shop",
          style: TextStyle(
            color: Theme.of(context).textTheme.headline6.color,
            fontSize: 50,
            fontFamily: "Anton",
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { SignUp, Login }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    "email": "",
    "password": "",
  };

  bool _isLoading = false;

  bool get _isSignUp => _authMode == AuthMode.SignUp;

  final TextEditingController _passwordController = new TextEditingController();

  AnimationController _animationController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0)).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {} catch (error) {}

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_isSignUp) {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _isSignUp ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _isSignUp ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "E-Mail"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val.isEmpty || !val.contains("@")) {
                      return "Invalid e-mail";
                    } else
                      return null;
                  },
                  onSaved: (val) => _authData["email"] = val,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (val) {
                    if (val.isEmpty || val.length < 8) {
                      return "Password is too short";
                    } else
                      return null;
                  },
                  onSaved: (val) => _authData["password"] = val,
                ),
                if (_isSignUp)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    constraints: BoxConstraints(
                      maxHeight: _isSignUp ? 120 : 0,
                      minHeight: _isSignUp ? 60 : 0,
                    ),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: TextFormField(
                            enabled: _isSignUp,
                            decoration:
                                InputDecoration(labelText: "Conferm password"),
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            validator: _isSignUp
                                ? (val) {
                                    if (_passwordController.text != val) {
                                      return "Passwords do not match";
                                    } else
                                      return null;
                                  }
                                : null,
                          ),
                        )),
                  ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_isSignUp ? "SIGNUP" : "LOGIN"),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor),
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color,
                        ),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text("${!_isSignUp ? "SIGNUP" : "LOGIN"} INSTED"),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 4,
                      ),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
