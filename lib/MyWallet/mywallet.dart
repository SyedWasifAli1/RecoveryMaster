import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:london_computers/FundsTransfer/FundsTransferPage.dart';
import 'package:london_computers/colors/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Transaction model class
class Transaction {
  final String recipientName;
  final double amount;
  final DateTime transferDate;

  // Constructor
  Transaction({
    required this.recipientName,
    required this.amount,
    required this.transferDate,
  });

  // Factory constructor to create a Transaction from Firestore document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      recipientName: data['recipient_name'] ?? '',
      amount: data['amount'] ?? 0.0,
      transferDate: (data['transfer_date'] as Timestamp).toDate(),
    );
  }
}

class MywalletPage extends StatefulWidget {
  @override
  _MywalletPageState createState() => _MywalletPageState();
}
class _MywalletPageState extends State<MywalletPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; 
num totalPayments = 0;
  // List to store transactions fetched from Firestore
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  _fetchTotalPayments();
    _fetchTransactions(); // Fetch transactions from Firestore when the page is loaded
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to fetch transactions from Firestore
Future<void> _fetchTransactions() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in!");
      return;
    }

    final String userId = user.uid; // ✅ Collector ka UID

    // ✅ Direct 'transfers' collection se sirf is collector ki transactions fetch karni hain
    final snapshot = await FirebaseFirestore.instance
        .collection('transfers') // Direct 'transfers' collection
        .where('collectorId', isEqualTo: userId) // ✅ Sirf current collector ke transactions fetch karo
        // .orderBy('transfer_date', descending: true) // ✅ Latest transfers first
        .get();

    if (snapshot.docs.isEmpty) {
      print("No transactions found.");
    }

    // ✅ Firestore se fetched documents ko model me map karna
    final transactionsList = snapshot.docs.map((doc) {
      return Transaction.fromFirestore(doc); // Firestore se Transaction model me convert karo
    }).toList();

    setState(() {
      transactions = transactionsList;
    });

    print("Transactions fetched successfully: ${transactions.length}");
  } catch (e) {
    print("Error fetching transactions: $e");
  }
}

  // double _calculateTotalAmount() {
  //   double totalAmount = 0;
  //   for (var transaction in transactions) {
  //     totalAmount += transaction.amount;
  //   }
  //   return totalAmount;
  // }

void _fetchTotalPayments() async {
  final user = _auth.currentUser;
  if (user == null) return;

  final userDoc = await _firestore.collection('collectors').doc(user.uid).get();
  final fetchedTotal = userDoc.data()?['totalPayments'] ?? 0;

  setState(() {
    totalPayments = fetchedTotal; // Update variable
  });

  print("Total Payments: $totalPayments"); // Console pe print karna
}





  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              // Background container with primary color and rounded corners
              Container(
                height: 180,
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
              // Back icon positioned at the top-left corner
              Positioned(
                top: 80,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous screen
                  },
                ),
              ),
              // Client Name and ID in the center
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'My Wallet', // Page title
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor, // Text color
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
                    'In Wallet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\PKR ${totalPayments}', // Dynamic balance
                    style: TextStyle(fontSize: 50, color: AppColors.balanceTextColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAnimatedButton(),
          const SizedBox(height: 16),
          // Transaction List (removed extra spacing above and below)
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  // Wrap the ListView with a fixed-height container
                  Container(
                    height: 400, // Adjust height here as per the design
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final formattedDate = DateFormat('dd MMM yyyy').format(transaction.transferDate);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              transaction.recipientName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${transaction.amount} PKR\nDate: $formattedDate'),
                            trailing: Text(
                              'PKR ${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            leading: Icon(Icons.history, color: Colors.blue),
                            onTap: () {
                              // Optionally, navigate to a detailed transaction page
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FundsTransferPage()),
        );
      },
      onTapDown: (_) {
        _animationController.forward(); // Scale up the button on tap down
      },
      onTapUp: (_) {
        _animationController.reverse(); // Scale back to normal size on tap up
      },
      onTapCancel: () {
        _animationController.reverse(); // Ensure the scale is reversed if the tap is cancelled
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 250,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green, // Customize the color of the button
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Funds Transfer',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class _MywalletPageState extends State<MywalletPage> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//
//   // List to store transactions fetched from Firestore
//   List<Transaction> transactions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//
//     _fetchTransactions(); // Fetch transactions from Firestore when the page is loaded
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   // Method to fetch transactions from Firestore
//   Future<void> _fetchTransactions() async {
//     try {
//       final userId = 'JJcQc0cKqRPoTy3SKERXPPdlAKm2'; // Replace this with the actual collector UID
//
//       final snapshot = await FirebaseFirestore.instance
//           .collection('collectors') // Collection name
//           .doc(userId) // Collector document
//           .collection('transfers') // Subcollection name
//           .get();
//
//       if (snapshot.docs.isEmpty) {
//         print("No transactions found.");
//       }
//
//       // Map the documents to the Transaction model
//       final transactionsList = snapshot.docs.map((doc) {
//         return Transaction.fromFirestore(doc); // Create Transaction from Firestore
//       }).toList();
//
//       setState(() {
//         transactions = transactionsList;
//       });
//
//       print("Transactions fetched successfully: ${transactions.length}");
//     } catch (e) {
//       print("Error fetching transactions: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               // Background container with primary color and rounded corners
//               Container(
//                 height: 180,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [AppColors.primaryColor_g1, AppColors.primaryColor_g2],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(50),
//                     bottomRight: Radius.circular(50),
//                   ),
//                 ),
//               ),
//               // Back icon positioned at the top-left corner
//               Positioned(
//                 top: 80,
//                 left: 20,
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
//                   onPressed: () {
//                     Navigator.pop(context); // Navigate back to the previous screen
//                   },
//                 ),
//               ),
//               // Client Name and ID in the center
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 80),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           'My Wallet', // Page title
//                           style: const TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textColor, // Text color
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'In Wallet',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     '\PKR 250,294',
//                     style: TextStyle(fontSize: 50, color: AppColors.balanceTextColor, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildAnimatedButton(),
//           const SizedBox(height: 16),
//           // Transaction List (removed extra spacing above and below)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Recent Transactions',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   // Wrap the ListView with a fixed-height container
//                   Container(
//                     height: 400, // Adjust height here as per the design
//                     child: ListView.builder(
//                       itemCount: transactions.length,
//                       itemBuilder: (context, index) {
//                         final transaction = transactions[index];
//                         final formattedDate = DateFormat('dd MMM yyyy').format(transaction.transferDate);
//
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 2,
//                           child: ListTile(
//                             title: Text(
//                               transaction.recipientName,
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text('${transaction.amount} PKR\nDate: $formattedDate'),
//                             trailing: Text(
//                               'PKR ${transaction.amount.toStringAsFixed(2)}',
//                               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//                             ),
//                             leading: Icon(Icons.history, color: Colors.blue),
//                             onTap: () {
//                               // Optionally, navigate to a detailed transaction page
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnimatedButton() {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FundsTransferPage()),
//         );
//       },
//       onTapDown: (_) {
//         _animationController.forward(); // Scale up the button on tap down
//       },
//       onTapUp: (_) {
//         _animationController.reverse(); // Scale back to normal size on tap up
//       },
//       onTapCancel: () {
//         _animationController.reverse(); // Ensure the scale is reversed if the tap is cancelled
//       },
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           width: 250,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.green, // Customize the color of the button
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 5,
//                 spreadRadius: 2,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               'Funds Transfer',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:london_computers/FundsTransfer/FundsTransferPage.dart';
// import 'package:london_computers/colors/colors.dart'; // Import for date formatting
// class Transaction {
//   final String title;
//   final String description;
//   final double amount;
//   final DateTime date;
//
//   Transaction({
//     required this.title,
//     required this.description,
//     required this.amount,
//     required this.date,
//   });
// }
// class MywalletPage extends StatefulWidget {
//   @override
//   _MywalletPageState createState() => _MywalletPageState();
// }
// class _MywalletPageState extends State<MywalletPage> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//
//   List<Transaction> transactions = [
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Dec month - Remaining due',
//       amount: 45000.0,
//       date: DateTime.now().subtract(Duration(days: 1)),
//     ),
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Street 9 - Collection',
//       amount: 150000.0,
//       date: DateTime.now().subtract(Duration(days: 7)),
//     ),
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Jan month - Remaining due',
//       amount: 1200.0,
//       date: DateTime.now().subtract(Duration(days: 2)),
//     ),
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Dec month - Remaining due',
//       amount: 45000.0,
//       date: DateTime.now().subtract(Duration(days: 1)),
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               // Background container with primary color and rounded corners
//               Container(
//                 height: 180,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [AppColors.primaryColor_g1, AppColors.primaryColor_g2], // Gradient color for the AppBar
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(50),
//                     bottomRight: Radius.circular(50),
//                   ),
//                 ),
//               ),
//               // Back icon positioned at the top-left corner
//               Positioned(
//                 top: 80,
//                 left: 20,
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
//                   onPressed: () {
//                     Navigator.pop(context); // Navigate back to the previous screen
//                   },
//                 ),
//               ),
//               // Client Name and ID in the center
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 80),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           'My Wallet', // Page title
//                           style: const TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.textColor, // Text color
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'In Wallet',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     '\PKR 250,294',
//                     style: TextStyle(fontSize: 50, color: AppColors.balanceTextColor, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildAnimatedButton(),
//           const SizedBox(height: 16),
//           // Transaction List (removed extra spacing above and below)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Recent Transactions',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   // Wrap the ListView with a fixed-height container
//                   Container(
//                     height: 400, // Adjust height here as per the design
//                     child: ListView.builder(
//                       itemCount: transactions.length,
//                       itemBuilder: (context, index) {
//                         final transaction = transactions[index];
//                         final formattedDate = DateFormat('dd MMM yyyy').format(transaction.date);
//
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 2,
//                           child: ListTile(
//                             title: Text(
//                               transaction.title,
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text('${transaction.description}\nDate: $formattedDate'),
//                             trailing: Text(
//                               'PKR ${transaction.amount.toStringAsFixed(2)}',
//                               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//                             ),
//                             leading: Icon(Icons.history, color: Colors.blue),
//                             onTap: () {
//                               // Optionally, navigate to a detailed transaction page
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnimatedButton() {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FundsTransferPage()),
//         );
//       },
//       onTapDown: (_) {
//         _animationController.forward(); // Scale up the button on tap down
//       },
//       onTapUp: (_) {
//         _animationController.reverse(); // Scale back to normal size on tap up
//       },
//       onTapCancel: () {
//         _animationController.reverse(); // Ensure the scale is reversed if the tap is cancelled
//       },
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           width: 250,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.green, // Customize the color of the button
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 5,
//                 spreadRadius: 2,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               'Funds Transfer',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _MywalletPageState extends State<MywalletPage> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//
//   List<Transaction> transactions = [
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Dec month - Remaining due',
//       amount: 45000.0,
//       date: DateTime.now().subtract(Duration(days: 1)),
//     ),
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Street 9 - Collection',
//       amount: 150000.0,
//       date: DateTime.now().subtract(Duration(days: 7)),
//     ),
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Jan month - Remaining due',
//       amount: 1200.0,
//       date: DateTime.now().subtract(Duration(days: 2)),
//     ),
//     Transaction(
//       title: 'Mr. Iftikhar Ahmad (Admin)',
//       description: 'Dec month - Remaining due',
//       amount: 45000.0,
//       date: DateTime.now().subtract(Duration(days: 1)),
//     ),
//     // Add more transactions as needed
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 height: 180,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF283593), Color(0xFF3F51B5)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(50),
//                     bottomRight: Radius.circular(50),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 80,
//                 left: 20,
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 80),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           'My Wallet',
//                           style: const TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'In Wallet',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     '\PKR 250,294',
//                     style: TextStyle(fontSize: 50, color: AppColors.balanceTextColor, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildAnimatedButton(),
//           const SizedBox(height: 16),
//           // Transaction List (with fixed height for scrolling)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Recent Transactions',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   // Wrap the ListView with a fixed-height container
//                   Container(
//                     height: 400, // You can adjust the height as per your design
//                     child: ListView.builder(
//                       itemCount: transactions.length,
//                       itemBuilder: (context, index) {
//                         final transaction = transactions[index];
//                         final formattedDate = DateFormat('dd MMM yyyy').format(transaction.date);
//
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 2,
//                           child: ListTile(
//                             title: Text(
//                               transaction.title,
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text('${transaction.description}\nDate: $formattedDate'),
//                             trailing: Text(
//                               'PKR ${transaction.amount.toStringAsFixed(2)}',
//                               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//                             ),
//                             leading: Icon(Icons.history, color: Colors.blue),
//                             onTap: () {
//                               // Optionally, navigate to a detailed transaction page
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnimatedButton() {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FundsTransferPage()),
//         );
//       },
//       onTapDown: (_) {
//         _animationController.forward(); // Scale up the button on tap down
//       },
//       onTapUp: (_) {
//         _animationController.reverse(); // Scale back to normal size on tap up
//       },
//       onTapCancel: () {
//         _animationController.reverse(); // Ensure the scale is reversed if the tap is cancelled
//       },
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           width: 250,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.green, // Customize the color of the button
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 5,
//                 spreadRadius: 2,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               'Funds Transfer',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:london_computers/FundsTransfer/FundsTransferPage.dart';
// import 'package:london_computers/Payment/Payments.dart';
// import 'package:london_computers/Recharge/recharge.dart';
// import 'package:london_computers/colors/colors.dart'; // Import the colors file
//
// class MywalletPage extends StatefulWidget {
//   @override
//   _MywalletPageState createState() => _MywalletPageState();
// }
//
// class Transaction {
//   final String title;
//   final String description;
//   final double amount;
//   final DateTime date;
//
//   Transaction({
//     required this.title,
//     required this.description,
//     required this.amount,
//     required this.date,
//   });
// }
// class _MywalletPageState extends State<MywalletPage> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//
//   List<Transaction> transactions = [
//     Transaction(
//       title: 'Mr. Farhan (Admin)',
//       description: 'Dec month - remaining due',
//       amount: 45000.0,
//       date: DateTime.now().subtract(Duration(days: 1)),
//     ),
//     Transaction(
//       title: 'Mr. Farhan (Admin)',
//       description: 'Jan month - remaining due',
//       amount: 1200.0,
//       date: DateTime.now().subtract(Duration(days: 2)),
//     ),
//     Transaction(
//       title: 'Mr. Farhan (Admin)',
//       description: 'Street 9 collection',
//       amount: 150000.0,
//       date: DateTime.now().subtract(Duration(days: 7)),
//     ),
//     // Add more transactions as needed
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Animation controller for scaling effect
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     // Defining the scale animation
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               Container(
//                 height: 180,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF283593), Color(0xFF3F51B5)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(50),
//                     bottomRight: Radius.circular(50),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 80,
//                 left: 20,
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 80),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           'My Wallet',
//                           style: const TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'In Wallet',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     '\PKR 250,294',
//                     style: TextStyle(fontSize: 50, color: AppColors.balanceTextColor, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildAnimatedButton(),
//           const SizedBox(height: 16),
//           // Transaction List
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowColor.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Recent Transactions',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   // const SizedBox(height: 8),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: transactions.length,
//                     itemBuilder: (context, index) {
//                       final transaction = transactions[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 2,
//                         child: ListTile(
//                           title: Text(
//                             transaction.title,
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text(transaction.description),
//                           trailing: Text(
//                             'PKR ${transaction.amount.toStringAsFixed(2)}',
//                             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//                           ),
//                           leading: Icon(Icons.history, color: Colors.blue),
//                           onTap: () {
//                             // Optionally, navigate to a detailed transaction page
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnimatedButton() {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FundsTransferPage()),
//         );
//       },
//       onTapDown: (_) {
//         _animationController.forward(); // Scale up the button on tap down
//       },
//       onTapUp: (_) {
//         _animationController.reverse(); // Scale back to normal size on tap up
//       },
//       onTapCancel: () {
//         _animationController.reverse(); // Ensure the scale is reversed if the tap is cancelled
//       },
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Container(
//           width: 250,
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.green, // Customize the color of the button
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 5,
//                 spreadRadius: 2,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               'Funds Transfer',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
