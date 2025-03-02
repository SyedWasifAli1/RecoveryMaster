

import 'package:flutter/material.dart';
import 'package:london_computers/Auth/register_screen.dart';
import 'package:london_computers/Dashboard/dashboard.dart';
import 'auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _checkSession();

    // Initialize AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Duration of the animation cycle
    )..repeat(reverse: true); // Repeating animation with reverse

    // Define color animation with a gradient
    _colorAnimation = ColorTween(
      begin: Color(0xFF000000), // Black color
      end: Color(0xFFFFFFFF), // Dark Gray color
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Smooth animation curve
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Check if the user already has an active session
  void _checkSession() async {
    bool isValid = await AuthService().isSessionValid();

    if (isValid) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
    }
  }

  void handleLogin() async {
    setState(() => isLoading = true);
    String? error = await AuthService().login(emailController.text, passwordController.text);
    setState(() => isLoading = false);

    if (error == null) {
      // If the user is a collector, redirect to the next page (HomeScreen)
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
    } else {
      // Show a dialog with the error message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Error"),
          content: Text(error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background to match your logo style
      body: Stack(
        children: [
          // Background gradient animation
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _colorAnimation.value ?? Color(0xFF000000),
                        _colorAnimation.value?.withOpacity(0.8) ?? Color(0xFF1A1A1A),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              child: Card(
                color: Colors.black, // Set the card background color to black
                elevation: 12.0, // Increased shadow for depth
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // More rounded corners
                  side: BorderSide(
                    color: Colors.white, // Color of the border
                    width: 2, // Width of the border
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Section
                      Image.asset(
                        'assets/master.png', // Replace with your logo path
                        // 'assets/icon.jpeg', // Replace with your logo path
                        height: 120, // Slightly larger logo
                      ),
                      SizedBox(height: 20),
                      // Email TextField
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Color(0xFF000000)),
                          prefixIcon: Icon(Icons.email, color: Color(0xFF000000)),
                          filled: true,
                          fillColor: Colors.grey[200], // Light background for the field
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // More rounded
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Password TextField
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Color(0xFF000000)),
                          prefixIcon: Icon(Icons.lock, color: Color(0xFF000000)),
                          filled: true,
                          fillColor: Colors.grey[200], // Light background for the field
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12), // More rounded
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Login Button
                      ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Custom color for button
                          // backgroundColor: Color(0xFFe1c43c), // Custom color for button
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Login',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Register Button (Text Button)
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => RegisterScreen()),
                      //     );
                      //   },
                      //   child: Text(
                      //     'Don\'t have an account? Register',
                      //     style: TextStyle(color: Colors.white, fontSize: 16),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}