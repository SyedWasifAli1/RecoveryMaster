import 'package:flutter/material.dart';
import 'package:london_computers/Auth/db_helper.dart';
import 'package:london_computers/Auth/home_screen.dart';
import 'package:london_computers/Auth/login_screen.dart';

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    int? expiryTime = await DBHelper().getSessionExpiryTime();

    if (expiryTime != null && expiryTime > DateTime.now().millisecondsSinceEpoch) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
