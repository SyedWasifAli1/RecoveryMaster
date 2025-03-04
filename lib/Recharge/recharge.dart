import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:london_computers/colors/colors.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RechargePage(),
  ));
}

class RechargePage extends StatefulWidget {
  @override
  _RechargePageState createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Client> clients = [];
  List<Client> filteredClients = [];
  bool isLoading = true;
  String activeFilter = 'One Month'; // Default active filter

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

void fetchClients() {
  try {
    // Get the current logged-in user
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('No user is currently logged in.');
      return;
    }

    // Listen to real-time changes
    _firestore
        .collection('customers')
        .where('selectedCollector', isEqualTo: currentUser.uid)
        .snapshots()
        .listen((QuerySnapshot snapshot) async {
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;

      List<Client> clientList = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Fetch package details
        String packageId = data['selectedPackage'] ?? '';
        DocumentSnapshot packageDoc = await _firestore.collection('packages').doc(packageId).get();

        String packageName = packageDoc['name'] ?? 'N/A';
        double packagePrice = (packageDoc['price'] ?? 0).toDouble();

        double discountPercentage = (data['discount'] ?? 0).toDouble();
        double discountAmount = packagePrice * (discountPercentage / 100);
        double monthlyBilling = packagePrice - discountAmount;

        Timestamp lastPaidTimestamp = data['lastpay'];
        DateTime lastPaidDate = lastPaidTimestamp.toDate();
        int lastPaidYear = lastPaidDate.year;
        int lastPaidMonth = lastPaidDate.month;

        int monthsSinceLastPayment = (currentYear - lastPaidYear) * 12 + (currentMonth - lastPaidMonth);

        if (lastPaidYear == currentYear && lastPaidMonth == currentMonth) {
          continue;
        }

        Client client = Client(
          billingid: doc.id.hashCode,
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          phone: data['contactNumber'] ?? 'N/A',
          monthlyBilling: monthlyBilling,
          lastPaid: (data['lastPaid'] ?? 0).toDouble(),
          selectedPackage: packageId,
          packageName: packageName,
          packagePrice: packagePrice,
          packageSize: "packageSize",
          pendingMonths: monthsSinceLastPayment,
        );

        clientList.add(client);
      }

      setState(() {
        clients = clientList;
        filteredClients = _filterClients(clientList, activeFilter);
        isLoading = false;
      });
    });
  } catch (e) {
    print('Error fetching clients: $e');
  }
}

  // Filter clients based on the active filter
  List<Client> _filterClients(List<Client> clients, String filter) {
    if (filter == 'One Month') {
      return clients.where((client) => client.pendingMonths == 1).toList();
    } else if (filter == 'Defaulters') {
      return clients.where((client) => client.pendingMonths > 1).toList();
    }
    return clients;
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
                      'Recharge',
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
          // Add One Month and Defaulters buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    activeFilter = 'One Month';
                    filteredClients = _filterClients(clients, activeFilter);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeFilter == 'One Month' ? Colors.blue : Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Current Month',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    activeFilter = 'Defaulters';
                    filteredClients = _filterClients(clients, activeFilter);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeFilter == 'Defaulters' ? Colors.blue : Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Defaulters',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isLoading
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : Expanded(
            child: ListView.builder(
              itemCount: filteredClients.length,
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
                      filteredClients[index].name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      filteredClients[index].phone,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Icon(Icons.arrow_forward, color: Color(0xFF3F51B5)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientDetailsPage(client: filteredClients[index]),
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
  final int billingid;
  final String id;
  final String name;
  final String phone;
  final double monthlyBilling;
  final double lastPaid;
  final int pendingMonths;
  final String selectedPackage; // packageId
  final String packageName; // Add packageName
  final double packagePrice; // Add packagePrice
  final String packageSize; // Add packageSize

  Client({
    required this.billingid,
    required this.id,
    required this.name,
    required this.phone,
    required this.monthlyBilling,
    required this.lastPaid,
    required this.selectedPackage,
    required this.packageName,
    required this.pendingMonths,
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
                          'User ID: ${client.billingid}',
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
                      Text(
                        'Pending months: ${client.pendingMonths}',
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
    final paymentDate = DateTime.now(); // Current date and time
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

      // Add new payment to the payments collection
      await _firestore.collection('payments').add({
        'amount': amount,
        'customerId': client.billingid,
        'customerName': client.name,
        'paymentDate': paymentDate,
        'userId': user.uid,
      });

      // Update the user's totalPayments field
      await userRef.update({
        'totalPayments': totalPayments + amount,
      });
      print(client.id);

      // Update the lastpay field in the customers collection for the specific customer
      await _firestore.collection('customers').doc(client.id).update({
        'lastpay': Timestamp.fromDate(paymentDate), // Update lastpay with current date and time
      });

      print('Payment stored, totalPayments updated, and lastpay field updated successfully');
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
// class RechargePage extends StatefulWidget {
//   @override
//   _RechargePageState createState() => _RechargePageState();
// }
//
// class _RechargePageState extends State<RechargePage> {
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
//     home: RechargePage(),
//   ));
// }
//
// class RechargePage extends StatefulWidget {
//   @override
//   _RechargePageState createState() => _RechargePageState();
// }
//
// class _RechargePageState extends State<RechargePage> {
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
