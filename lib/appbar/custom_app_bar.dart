// custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  CustomAppBar({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange, // Set the background color of the AppBar
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // Set bottom border radius
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), // Clip the AppBar to have rounded corners
          child: AppBar(
            flexibleSpace: Stack(
              children: [
                // Background image with gradient
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/Pos_bg.jpg'), // Replace with your background image path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7), // Dark overlay
                        Colors.black.withOpacity(0.5), // Dark overlay
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Title and subtitle
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 35, // Increase font size for "POS"
                        ),
                      ),
                      // SizedBox(height: 4), // Add some space between the title and subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500, // Font size for the subtitle
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent, // Make the AppBar background transparent
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}