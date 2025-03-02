import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'db_helper.dart';
import 'login_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? sessionTimer;

  @override
  void initState() {
    super.initState();
    checkSession();
    sessionTimer = Timer.periodic(Duration(seconds: 5), (_) => checkSession());
  }

  void checkSession() async {
    int? expiryTime = await DBHelper().getSessionExpiryTime();
    if (expiryTime == null || DateTime.now().millisecondsSinceEpoch >= expiryTime) {
      sessionTimer?.cancel();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Session Expired"),
          content: Text("Your subscription has expired."),
          actions: [
            TextButton(
              onPressed: () {
                AuthService().logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Welcome!")),
    );
  }
}
