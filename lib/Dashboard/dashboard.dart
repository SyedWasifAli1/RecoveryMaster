import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore Import
import 'package:london_computers/FundsTransfer/FundsTransferPage.dart';
import 'package:london_computers/MyWallet/mywallet.dart';
import 'package:london_computers/Payment/Payments.dart';
import 'package:london_computers/Recharge/recharge.dart';
import 'package:london_computers/FindUser/finduser.dart';
import 'package:london_computers/colors/colors.dart'; // Import the colors file
import 'package:firebase_auth/firebase_auth.dart';
class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String collectorName = "Loading...";  // Default
  String collectorId = "Loading..."; // Default

  @override
  void initState() {
    super.initState();
    fetchCollectorDetails(); // Function Call on Init
  }

  // ✅ Firestore se Collector Data Fetch Karna
  void fetchCollectorDetails() async {
    try {
      // Collector ID (Hardcoded, isko dynamic bhi bana sakte ho)
       User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in!");
      return;
    }

    final String userId = user.uid; 

      // Firestore se Document Fetch
      DocumentSnapshot collectorDoc = await FirebaseFirestore.instance
          .collection('collectors')
          .doc(userId)
          .get();

      if (collectorDoc.exists) {
        setState(() {
          collectorName = collectorDoc['name'] ?? "Unknown";
          collectorId = collectorDoc['collectorId'] ?? "Unknown";
        });
      } else {
        setState(() {
          collectorName = "Not Found";
          collectorId = "N/A";
        });
      }
    } catch (e) {
      setState(() {
        collectorName = "Error";
        collectorId = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ AppBar Section
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor_g1, AppColors.primaryColor_g2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, left: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collectorName, // ✅ Firestore se Aaya Hua Collector Name
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Collector ID: $collectorId', // ✅ Firestore se Collector ID
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textColorLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ Balance Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PKR 250,294',
                    style: TextStyle(fontSize: 50, color: AppColors.balanceTextColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ✅ Dashboard Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ListView.builder(
                itemCount: (_dashboardItems.length / 2).ceil(),
                itemBuilder: (context, rowIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (rowIndex * 2 < _dashboardItems.length)
                        Expanded(
                          child: _buildDashboardItem(
                            context,
                            _dashboardItems[rowIndex * 2]['title']!,
                            _dashboardItems[rowIndex * 2]['iconPath']!,
                            _dashboardItems[rowIndex * 2]['destinationPage']!,
                          ),
                        ),
                      if (rowIndex * 2 + 1 < _dashboardItems.length)
                        Expanded(
                          child: _buildDashboardItem(
                            context,
                            _dashboardItems[rowIndex * 2 + 1]['title']!,
                            _dashboardItems[rowIndex * 2 + 1]['iconPath']!,
                            _dashboardItems[rowIndex * 2 + 1]['destinationPage']!,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Dashboard Item Builder
  Widget _buildDashboardItem(BuildContext context, String title, String iconPath, Widget destinationPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Card(
        color: AppColors.cardBackgroundColor,
        margin: const EdgeInsets.all(4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(iconPath, height: 50, width: 50),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Dashboard Items
final List<Map<String, dynamic>> _dashboardItems = [
  {'title': 'Payment', 'iconPath': 'assets/payment.jpg', 'destinationPage': PaymentPage()},
  {'title': 'Find User', 'iconPath': 'assets/finduser.jpg', 'destinationPage': FindUserPage()},
  {'title': 'My Wallet', 'iconPath': 'assets/mywallet.jpg', 'destinationPage': MywalletPage()},
  {'title': 'Funds Transfer', 'iconPath': 'assets/fundtransfer.jpg', 'destinationPage': FundsTransferPage()},
  {'title': 'User ', 'iconPath': 'assets/user.jpg', 'destinationPage': DashboardPage()},
  {'title': 'Recharge', 'iconPath': 'assets/fundtransfer.jpg', 'destinationPage': RechargePage()},
];
