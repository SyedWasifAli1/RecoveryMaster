import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:london_computers/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:london_computers/colors/colors.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FindUserPage(),
  ));
}

class FindUserPage extends StatefulWidget {
  @override
  _FindUserPageState createState() => _FindUserPageState();
}

class _FindUserPageState extends State<FindUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance to get UID
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

 Future<void> fetchClients() async {
  try {
    // Get the current logged-in user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('No user is currently logged in.');
      return;
    }

    // Fetch customers collection from Firestore
    QuerySnapshot snapshot = await _firestore
        .collection('customers')
        .where('selectedCollector', isEqualTo: currentUser.uid) // Filter by current user
        .get();

    // Fetch package details for each client
    List<Client> clientList = [];
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Fetch package details from the package collection
      String packageId = data['selectedPackage'] ?? '';
print('Fetching package details for Package ID: $packageId');
DocumentSnapshot packageDoc = await _firestore.collection('packages').doc(packageId).get();
print('Package exists: ${packageDoc.exists}');

      // Extract package details
      String packageName = packageDoc['name'] ?? 'N/A';
      double packagePrice = (packageDoc['price'] ?? 0).toDouble();
      String packageSize = packageDoc['size'] ?? 'N/A';

      // Fetch discount from the customer data
          double discountPercentage = (data['discount']  ?? 0).toDouble();

      // Calculate the discount amount
      double discountAmount = packagePrice * (discountPercentage / 100);

      // Calculate the final result (packagePrice - discountAmount)
      double monthlyBilling = packagePrice - discountAmount;

      // Create Client object
      Client client = Client(
        id: doc.id.hashCode, // Use document ID hash as unique identifier
        name: data['name'] ?? 'Unknown',
        phone: data['contactNumber'] ?? 'N/A',
        monthlyBilling: monthlyBilling, // Store the final result
        lastPaid: (data['lastPaid'] ?? 0).toDouble(),
        selectedPackage: packageId,
        packageName: packageName,
        packagePrice: packagePrice,
        packageSize: packageSize,
      );

      clientList.add(client);
    }

    setState(() {
      clients = clientList;
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching clients: $e');
  }
}
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
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
              Positioned(
                top: 80,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Text(
                      'Find User',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Client',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const SizedBox(height: 16),
          isLoading
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : Expanded(
            child: ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 8,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      clients[index].name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      clients[index].phone,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.arrow_forward, color: Color(0xFF3F51B5)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientDetailsPage(client: clients[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Client {
  final int id;
  final String name;
  final String phone;
  final double monthlyBilling;
  final double lastPaid;
  final String selectedPackage; // packageId
  final String packageName; // Add packageName
  final double packagePrice; // Add packagePrice
  final String packageSize; // Add packageSize

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.monthlyBilling,
    required this.lastPaid,
    required this.selectedPackage,
    required this.packageName,
    required this.packagePrice,
    required this.packageSize,
  });
}
class ClientDetailsPage extends StatelessWidget {
  final Client client;

  ClientDetailsPage({required this.client});

  final TextEditingController amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance to get UID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
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
              Positioned(
                top: 80,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ID: ${client.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor_2,
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
          // Client Info Card with Gradient Background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: Colors.black.withOpacity(0.2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.cardBackgroundColor, AppColors.cardBackgroundColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone: ${client.phone}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.shadowColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Monthly Billing: \PKR ${client.monthlyBilling}',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Last Paid Amount: \PKR ${client.lastPaid}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.shadowColor
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30), // Space below info card

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 18),
                Text(
                  'Cash Collection',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blue.shade400),
                    ),
                    prefixIcon: Icon(Icons.money, color: Colors.blue.shade600),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    await _storePaymentData(amount);
                    _showPaymentReceivedDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                },
                child: Text(
                  'Submit Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _storePaymentData(double amount) async {
  try {
    final paymentDate = DateTime.now();
    final user = _auth.currentUser; // Get the current logged-in user

    if (user != null) {
      // Firestore instance
      final userRef = _firestore.collection('collectors').doc(user.uid);

      // Fetch the current user's document
      final userDoc = await userRef.get();

      double totalPayments = 0.0; // Default value if not present

      if (userDoc.exists && userDoc.data() != null) {
        totalPayments = (userDoc.data()!['totalPayments'] ?? 0.0).toDouble();
      }

      // Add new payment
      await _firestore.collection('payments').add({
        'amount': amount,
        'customerId': client.id,
        'customerName': client.name,
        'paymentDate': paymentDate,
        'userId': user.uid,
      });

      // Update the user's totalPayments field
      await userRef.update({
        'totalPayments': totalPayments + amount,
      });

      print('Payment stored and totalPayments updated successfully');
    }
  } catch (e) {
    print('Error storing payment: $e');
  }
}


  // Future<void> _storePaymentData(double amount) async {
  //   try {
  //     final paymentDate = DateTime.now();
  //     final user = _auth.currentUser; // Get the current logged-in user

  //     if (user != null) {
  //       await _firestore.collection('payments').add({
  //         'amount': amount,
  //         'customerId': client.id,
  //         'customerName': client.name,
  //         'paymentDate': paymentDate,
  //         'userId': user.uid, // Store the UID of the logged-in user
  //       });

  //       print('Payment stored successfully');
  //     }
  //   } catch (e) {
  //     print('Error storing payment: $e');
  //   }
  // }


  void _showPaymentReceivedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Payment Received',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Billing ID: ${client.id}', style: TextStyle(fontSize: 16)),
              Text('${client.name}', style: TextStyle(fontSize: 22)),
              Text('PKR ${amountController.text}', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Icon(Icons.check_circle, color: Colors.green, size: 50),
            ],
          ),
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
  }
}




// directly login uid entered - not complete ui
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
// import 'package:flutter/material.dart';
// import 'package:london_computers/colors/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:london_computers/colors/colors.dart';
//
// class FindUserPage extends StatefulWidget {
//   @override
//   _FindUserPageState createState() => _FindUserPageState();
// }
//
// class _FindUserPageState extends State<FindUserPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance to get UID
//   List<Client> clients = [];
//   bool isLoading = true;
//   TextEditingController amountController = TextEditingController(); // Text controller for the amount input
//
//   @override
//   void initState() {
//     super.initState();
//     fetchClients();
//   }
//
//   Future<void> fetchClients() async {
//     try {
//       // Fetch customers collection from Firestore
//       QuerySnapshot snapshot = await _firestore.collection('customers').get();
//       setState(() {
//         clients = snapshot.docs.map((doc) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           return Client(
//             id: doc.id.hashCode, // Use document ID hash as unique identifier
//             name: data['name'] ?? 'Unknown',
//             phone: data['contactNumber'] ?? 'N/A',
//             monthlyBilling: (data['monthlyBilling'] ?? 0).toDouble(),
//             lastPaid: (data['lastPaid'] ?? 0).toDouble(),
//           );
//         }).toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching clients: $e');
//     }
//   }
//
//   // Function to handle payment submission
//   Future<void> handlePayment(Client client) async {
//     String uid = _auth.currentUser?.uid ?? 'Unknown'; // Get the UID of the logged-in user
//
//     // Add payment details to Firestore
//     await _firestore.collection('payments').add({
//       'amount': double.parse(amountController.text), // Payment amount
//       'customerId': client.id, // Customer's ID
//       'customerName': client.name, // Customer's name
//       'paymentDate': DateTime.now(), // Current date and time
//       'collectorId': uid, // UID of the logged-in user (collector)
//     });
//
//     // Show confirmation dialog after payment
//     _showPaymentReceivedDialog();
//   }
//
//   void _showPaymentReceivedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Center(child: Text('Payment Received')),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Payment received successfully!'),
//               SizedBox(height: 10),
//               Icon(Icons.check_circle, color: Colors.green, size: 50),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // ... Your existing code for header and search bar
//
//           const SizedBox(height: 30), // Space below input field
//
//           // Amount Input Field with Enhanced Style
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 18), // Space between heading and text field
//
//                 // Heading
//                 Text(
//                   'Cash Collection',
//                   style: TextStyle(
//                     fontSize: 34, // Font size for the heading
//                     fontWeight: FontWeight.bold, // Make the heading bold
//                     color: Colors.black, // Text color for the heading
//                   ),
//                 ),
//                 const SizedBox(height: 18), // Space between heading and text field
//
//                 // Cash Collection TextField
//                 TextField(
//                   controller: amountController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Amount',
//                     labelStyle: TextStyle(color: Colors.grey[600]),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide(color: Colors.blue.shade400),
//                     ),
//                     prefixIcon: Icon(Icons.money, color: Colors.blue.shade600),
//                     filled: true,
//                     fillColor: Colors.blue.shade50,
//                     contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                   ),
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(fontSize: 30),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 30), // Space below input field
//
//           // Submit Payment Button with Gradient Background
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // Green gradient
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//               ),
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (amountController.text.isNotEmpty) {
//                     // Call handlePayment when button is pressed
//                     handlePayment(clients[0]); // You can pass the client ID here (you can customize this logic)
//                   }
//                 },
//                 child: Text(
//                   'Submit Payment',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 0,
//                   backgroundColor: Colors.transparent, // Transparent button background
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Client {
//   final int id;
//   final String name;
//   final String phone;
//   final double monthlyBilling;
//   final double lastPaid;
//
//   Client({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.monthlyBilling,
//     required this.lastPaid,
//   });
// }

// // Adding & fetching data below with uid login collector
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:london_computers/colors/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:london_computers/colors/colors.dart';
//
// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: FindUserPage(),
//   ));
// }
//
// class FindUserPage extends StatefulWidget {
//   @override
//   _FindUserPageState createState() => _FindUserPageState();
// }
//
// class _FindUserPageState extends State<FindUserPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Client> clients = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchClients();
//   }
//
//   Future<void> fetchClients() async {
//     try {
//       // Fetch customers collection from Firestore
//       QuerySnapshot snapshot = await _firestore.collection('customers').get();
//       setState(() {
//         clients = snapshot.docs.map((doc) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           return Client(
//             id: doc.id.hashCode, // Use document ID hash as unique identifier
//             name: data['name'] ?? 'Unknown',
//             phone: data['contactNumber'] ?? 'N/A',
//             monthlyBilling: (data['monthlyBilling'] ?? 0).toDouble(),
//             lastPaid: (data['lastPaid'] ?? 0).toDouble(),
//           );
//         }).toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching clients: $e');
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
//               Positioned(
//                 top: 80,
//                 left: 20,
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
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
//                     child: Text(
//                       'Recharge',
//                       style: const TextStyle(
//                         fontSize: 34,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textColor,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 labelText: 'Search Client',
//                 labelStyle: TextStyle(color: Colors.grey[600]),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide(color: Colors.grey.shade300),
//                 ),
//                 prefixIcon: Icon(Icons.search, color: Colors.grey),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           isLoading
//               ? Center(child: CircularProgressIndicator()) // Loading indicator
//               : Expanded(
//             child: ListView.builder(
//               itemCount: clients.length,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   elevation: 8,
//                   shadowColor: Colors.grey.withOpacity(0.5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                     title: Text(
//                       clients[index].name,
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                     ),
//                     subtitle: Text(
//                       clients[index].phone,
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     trailing: Icon(Icons.arrow_forward, color: Color(0xFF3F51B5)),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ClientDetailsPage(client: clients[index]),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class Client {
//   final int id;
//   final String name;
//   final String phone;
//   final double monthlyBilling;
//   final double lastPaid;
//
//   Client({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.monthlyBilling,
//     required this.lastPaid,
//   });
// }
//
// class ClientDetailsPage extends StatelessWidget {
//   final Client client;
//
//   ClientDetailsPage({required this.client});
//
//   final TextEditingController amountController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Stack(
//             children: [
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
//               Positioned(
//                 top: 80,
//                 left: 20,
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
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
//                           client.name,
//                           style: const TextStyle(
//                             fontSize: 34,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'User ID: ${client.id}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: AppColors.textColor_2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//           // Client Info Card with Gradient Background
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Card(
//               elevation: 10,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               shadowColor: Colors.black.withOpacity(0.2),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [AppColors.cardBackgroundColor, AppColors.cardBackgroundColor], // Soft gradient for info card
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Phone: ${client.phone}',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.shadowColor,
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         'Monthly Billing: \PKR ${client.monthlyBilling}',
//                         style: TextStyle(
//                             fontSize: 25,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primaryColor
//                         ),
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         'Last Paid Amount: \PKR ${client.lastPaid}',
//                         style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.shadowColor
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 30), // Space below info card
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 18),
//                 Text(
//                   'Cash Collection',
//                   style: TextStyle(
//                     fontSize: 34,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//
//                 TextField(
//                   controller: amountController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter Amount',
//                     labelStyle: TextStyle(color: Colors.grey[600]),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide(color: Colors.blue.shade400),
//                     ),
//                     prefixIcon: Icon(Icons.money, color: Colors.blue.shade600),
//                     filled: true,
//                     fillColor: Colors.blue.shade50,
//                     contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                   ),
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(fontSize: 30),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 30),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//               ),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   // Get the entered amount
//                   final amount = double.tryParse(amountController.text);
//                   if (amount != null && amount > 0) {
//                     // Store payment data in Firestore
//                     await _storePaymentData(amount);
//                     _showPaymentReceivedDialog(context); // Show success dialog
//                   } else {
//                     // Handle invalid input (e.g., empty or non-numeric value)
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Please enter a valid amount')),
//                     );
//                   }
//                 },
//                 child: Text(
//                   'Submit Payment',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 0,
//                   backgroundColor: Colors.transparent,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _storePaymentData(double amount) async {
//     try {
//       // Get the current date and time
//       final paymentDate = DateTime.now();
//
//       // Add the payment data to Firestore
//       await _firestore.collection('payments').add({
//         'amount': amount,
//         'customerId': client.id,
//         'customerName': client.name,
//         'paymentDate': paymentDate,
//       });
//
//       print('Payment stored successfully');
//     } catch (e) {
//       print('Error storing payment: $e');
//     }
//   }
//
//   void _showPaymentReceivedDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Center(
//             child: Text(
//               'Payment Received',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Billing ID: ${client.id}', style: TextStyle(fontSize: 16)),
//               Text('${client.name}', style: TextStyle(fontSize: 22)),
//               Text('PKR ${amountController.text}', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),
//               Icon(Icons.check_circle, color: Colors.green, size: 50),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
