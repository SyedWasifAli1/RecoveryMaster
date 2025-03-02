import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:london_computers/colors/colors.dart';

class FundsTransferPage extends StatefulWidget {
  @override
  _FundsTransferPageState createState() => _FundsTransferPageState();
}

class _FundsTransferPageState extends State<FundsTransferPage>
    with SingleTickerProviderStateMixin {
  bool _isTransferring = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }


  Future<void> _saveTransferToFirestore(String name, String amount) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in!");
      return;
    }

    final String userUid = user.uid;
    Timestamp transferDate = Timestamp.now();
    double transferAmount = double.tryParse(amount) ?? 0;

    final userRef = FirebaseFirestore.instance.collection('collectors').doc(userUid);

    // Firestore se current totalPayments fetch karna
    final userDoc = await userRef.get();
    num currentTotalPayments = userDoc.data()?['totalPayments'] ?? 0;

    // totalPayments me se transferAmount minus karna
    num updatedTotalPayments = currentTotalPayments - transferAmount;
    if (updatedTotalPayments < 0) updatedTotalPayments = 0; // Negative hone se rokna

    // totalPayments update karna Firestore pe
    await userRef.update({'totalPayments': updatedTotalPayments});

    // ✅ Direct 'transfers' collection me store karna
    await FirebaseFirestore.instance.collection('transfers').add({
      'recipient_name': name,
      'amount': transferAmount,
      'transfer_date': transferDate,
      'collectorId': userUid, // ✅ Collector ID directly store ho rahi hai
    });

    print("Transfer data saved to Firestore & totalPayments updated");

  } catch (e) {
    print("Error saving transfer data: $e");
  }
}

// Future<void> _saveTransferToFirestore(String name, String amount) async {
//   try {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       print("No user logged in!");
//       return;
//     }

//     final String userUid = user.uid;
//     Timestamp transferDate = Timestamp.now();
//     double transferAmount = double.tryParse(amount) ?? 0;

//     final userRef = FirebaseFirestore.instance.collection('collectors').doc(userUid);

//     // Firestore se current totalPayments fetch karna
//     final userDoc = await userRef.get();
//     num currentTotalPayments = userDoc.data()?['totalPayments'] ?? 0;

//     // totalPayments me se transferAmount minus karna
//     num updatedTotalPayments = currentTotalPayments - transferAmount;
//     if (updatedTotalPayments < 0) updatedTotalPayments = 0; // Negative hone se rokna

//     // totalPayments update karna Firestore pe
//     await userRef.update({'totalPayments': updatedTotalPayments});

//     // Transfer ki details store karna
//     await FirebaseFirestore.instance
//         .collection('collectors')
//         .doc(userUid)
//         .collection('transfers')
//         .add({
//       'recipient_name': name,
//       'amount': transferAmount,
//       'transfer_date': transferDate,
//     });

//     print("Transfer data saved to Firestore & totalPayments updated");

//   } catch (e) {
//     print("Error saving transfer data: $e");
//   }
// }

  // Future<void> _saveTransferToFirestore(String name, String amount) async {
  //   try {
  //     // Get the current user's UID
  //     User? user = FirebaseAuth.instance.currentUser;

  //     if (user == null) {
  //       // If no user is logged in, show an error
  //       print("No user logged in!");
  //       return;
  //     }

  //     final String userUid = user.uid; // Get the UID of the logged-in user

  //     // Get the current timestamp
  //     Timestamp transferDate = Timestamp.now();

  //     // Add the transfer data to Firestore under the collector's document
  //     await FirebaseFirestore.instance
  //         .collection('collectors') // The collection to store the collector's data
  //         .doc(userUid) // Use the logged-in user's UID as the document ID
  //         .collection('transfers') // Subcollection to store transfers
  //         .add({
  //       'recipient_name': name,
  //       'amount': double.tryParse(amount) ?? 0, // Parse amount to a double
  //       'transfer_date': transferDate, // Store the transfer date
  //     });

  //     print("Transfer data saved to Firestore");

  //   } catch (e) {
  //     print("Error saving transfer data: $e");
  //   }
  // }


  void _startTransfer() {
    final String name = _nameController.text.trim();
    final String amount = _amountController.text.trim();

    if (name.isEmpty || amount.isEmpty) {
      // Show error if name or amount is empty
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Please fill in both the name and amount fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _isTransferring = true;
    });

    _controller.forward();

    // Simulate a network request or transfer process
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isTransferring = false;
      });

      _controller.reverse();

      // Save transfer data to Firestore
      _saveTransferToFirestore(name, amount);

      // Show success message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Transfer Complete', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('Your funds have been successfully transferred.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to the previous page
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    colors: [AppColors.primaryColor_g1, AppColors.primaryColor_g2], // Gradient color for the AppBar
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
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
                          'Fund Transfer', // Page title
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: _isTransferring
                  ? AnimatedSwitcher(
                duration: Duration(seconds: 2),
                child: Column(
                  key: ValueKey<int>(1),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitWave(
                      color: Colors.blue,
                      size: 70.0,
                    ),
                    SizedBox(height: 20),
                    FadeTransition(
                      opacity: _animation,
                      child: Text(
                        'Transferring funds...',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recipient Name Input Field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Recipient Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      hintText: 'Enter recipient name',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Amount Input Field
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      hintText: 'Enter amount to transfer',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  // Transfer Button
                  ElevatedButton(
                    onPressed: _startTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Text(
                      'Start Transfer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
}
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FundsTransferPage extends StatefulWidget {
//   @override
//   _FundsTransferPageState createState() => _FundsTransferPageState();
// }
//
// class _FundsTransferPageState extends State<FundsTransferPage>
//     with SingleTickerProviderStateMixin {
//   bool _isTransferring = false;
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _nameController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveTransferToFirestore(String name, String amount) async {
//     try {
//       // Get the current user's UID
//       User? user = FirebaseAuth.instance.currentUser;
//
//       if (user == null) {
//         // If no user is logged in, show an error
//         print("No user logged in!");
//         return;
//       }
//
//       final String userUid = user.uid; // Get the UID of the logged-in user
//
//       // Get the current timestamp
//       Timestamp transferDate = Timestamp.now();
//
//       // Add the transfer data to Firestore under the collector's document
//       await FirebaseFirestore.instance
//           .collection('collectors') // The collection to store the collector's data
//           .doc(userUid) // Use the logged-in user's UID as the document ID
//           .collection('transfers') // Subcollection to store transfers
//           .add({
//         'recipient_name': name,
//         'amount': double.tryParse(amount) ?? 0, // Parse amount to a double
//         'transfer_date': transferDate, // Store the transfer date
//       });
//
//       print("Transfer data saved to Firestore");
//       // Optionally, show success dialog or snack bar
//
//     } catch (e) {
//       print("Error saving transfer data: $e");
//       // Optionally, show an error dialog or handle errors
//     }
//   }
//
//   void _startTransfer() {
//     final String name = _nameController.text.trim();
//     final String amount = _amountController.text.trim();
//
//     if (name.isEmpty || amount.isEmpty) {
//       // Show error if name or amount is empty
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
//             content: Text('Please fill in both the name and amount fields.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }
//
//     setState(() {
//       _isTransferring = true;
//     });
//
//     _controller.forward();
//
//     // Simulate a network request or transfer process
//     Future.delayed(Duration(seconds: 3), () {
//       setState(() {
//         _isTransferring = false;
//       });
//
//       _controller.reverse();
//
//       // Save transfer data to Firestore
//       _saveTransferToFirestore(name, amount);
//
//       // Show success message
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Transfer Complete', style: TextStyle(fontWeight: FontWeight.bold)),
//             content: Text('Your funds have been successfully transferred.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                   Navigator.of(context).pop(); // Go back to the previous page
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//                     colors: [Colors.blue, Colors.green], // Replace with your gradient colors
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
//                   icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
//                           'Fund Transfer', // Page title
//                           style: const TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white, // Text color
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Center(
//               child: _isTransferring
//                   ? AnimatedSwitcher(
//                 duration: Duration(seconds: 2),
//                 child: Column(
//                   key: ValueKey<int>(1),
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 20),
//                     FadeTransition(
//                       opacity: _animation,
//                       child: Text(
//                         'Transferring funds...',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Recipient Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(color: Colors.blue),
//                       ),
//                       hintText: 'Enter recipient name',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   TextField(
//                     controller: _amountController,
//                     decoration: InputDecoration(
//                       labelText: 'Amount',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(color: Colors.blue),
//                       ),
//                       hintText: 'Enter amount to transfer',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _startTransfer,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                     ),
//                     child: Text(
//                       'Start Transfer',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:london_computers/colors/colors.dart';
//
// class FundsTransferPage extends StatefulWidget {
//   @override
//   _FundsTransferPageState createState() => _FundsTransferPageState();
// }
//
// class _FundsTransferPageState extends State<FundsTransferPage> with SingleTickerProviderStateMixin {
//   bool _isTransferring = false;
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _nameController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   void _startTransfer() async {
//     final String name = _nameController.text.trim();
//     final String amount = _amountController.text.trim();
//
//     if (name.isEmpty || amount.isEmpty) {
//       // Show error if name or amount is empty
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
//             content: Text('Please fill in both the name and amount fields.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }
//
//     setState(() {
//       _isTransferring = true;
//     });
//
//     _controller.forward();
//
//     // Simulate a network request or transfer process
//     await Future.delayed(Duration(seconds: 3));
//
//     // Save the transfer data to Firestore
//     await _saveTransferToFirestore(name, amount);
//
//     setState(() {
//       _isTransferring = false;
//     });
//
//     _controller.reverse();
//
//     // Show success message
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Transfer Complete', style: TextStyle(fontWeight: FontWeight.bold)),
//           content: Text('Your funds have been successfully transferred.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//                 Navigator.of(context).pop(); // Go back to the previous page
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _saveTransferToFirestore(String name, String amount) async {
//     try {
//       // Get the current user's UID
//       final String userUid = 'collector_uid_here'; // You will get the actual UID dynamically from FirebaseAuth or your session
//
//       // Get the current timestamp
//       Timestamp transferDate = Timestamp.now();
//
//       // Add the transfer data to Firestore
//       await FirebaseFirestore.instance.collection('collectors').doc(userUid).collection('transfers').add({
//         'recipient_name': name,
//         'amount': double.tryParse(amount) ?? 0,
//         'transfer_date': transferDate,
//       });
//
//       print("Transfer data saved to Firestore");
//     } catch (e) {
//       print("Error saving transfer data: $e");
//       // Optionally, show an error dialog
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//                           'Fund Transfer', // Page title
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
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Center(
//               child: _isTransferring
//                   ? AnimatedSwitcher(
//                 duration: Duration(seconds: 2),
//                 child: Column(
//                   key: ValueKey<int>(1),
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SpinKitWave(
//                       color: Colors.blue,
//                       size: 70.0,
//                     ),
//                     SizedBox(height: 20),
//                     FadeTransition(
//                       opacity: _animation,
//                       child: Text(
//                         'Transferring funds...',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Recipient Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(color: AppColors.primaryColor),
//                       ),
//                       hintText: 'Enter recipient name',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   TextField(
//                     controller: _amountController,
//                     decoration: InputDecoration(
//                       labelText: 'Amount',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(color: AppColors.primaryColor),
//                       ),
//                       hintText: 'Enter amount to transfer',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _startTransfer,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                     ),
//                     child: Text(
//                       'Start Transfer',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondaryColor),
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
// }
// import 'package:london_computers/colors/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
//
// class FundsTransferPage extends StatefulWidget {
//   @override
//   _FundsTransferPageState createState() => _FundsTransferPageState();
// }
//
// class _FundsTransferPageState extends State<FundsTransferPage>
//     with SingleTickerProviderStateMixin {
//   bool _isTransferring = false;
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _nameController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   void _startTransfer() {
//     final String name = _nameController.text.trim();
//     final String amount = _amountController.text.trim();
//
//     if (name.isEmpty || amount.isEmpty) {
//       // Show error if name or amount is empty
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
//             content: Text('Please fill in both the name and amount fields.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }
//
//     setState(() {
//       _isTransferring = true;
//     });
//
//     _controller.forward();
//
//     // Simulate a network request or transfer process
//     Future.delayed(Duration(seconds: 3), () {
//       setState(() {
//         _isTransferring = false;
//       });
//
//       _controller.reverse();
//
//       // Show success message
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Transfer Complete', style: TextStyle(fontWeight: FontWeight.bold)),
//             content: Text('Your funds have been successfully transferred.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                   Navigator.of(context).pop(); // Go back to the previous page
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//                           'Fund Transfer', // Page title
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
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Center(
//               child: _isTransferring
//                   ? AnimatedSwitcher(
//                 duration: Duration(seconds: 2),
//                 child: Column(
//                   key: ValueKey<int>(1),
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SpinKitWave(
//                       color: Colors.blue,
//                       size: 70.0,
//                     ),
//                     SizedBox(height: 20),
//                     FadeTransition(
//                       opacity: _animation,
//                       child: Text(
//                         'Transferring funds...',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Recipient Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(color: AppColors.primaryColor),
//                       ),
//                       hintText: 'Enter recipient name',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   TextField(
//                     controller: _amountController,
//                     decoration: InputDecoration(
//                       labelText: 'Amount',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide(color: AppColors.primaryColor),
//                       ),
//                       hintText: 'Enter amount to transfer',
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _startTransfer,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                     ),
//                     child: Text(
//                       'Start Transfer',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondaryColor),
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
// }