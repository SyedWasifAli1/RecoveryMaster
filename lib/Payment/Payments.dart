// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:intl/intl.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: PaymentPage(),
//   ));
// }

// class PaymentPage extends StatefulWidget {
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   List<Client> clients = [];
//   List<Client> filteredClients = [];
//   DateTime? selectedDate;
//   TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchClients();
//   }

//   // Future<void> fetchClients() async {
//   //   try {
//   //     // Replace 'clients' with your actual Firestore collection name
//   //     QuerySnapshot snapshot =
//   //     await FirebaseFirestore.instance.collection('customers').get();
//   //
//   //     setState(() {
//   //       clients = snapshot.docs.map((doc) {
//   //         final data = doc.data() as Map<String, dynamic>;
//   //         return Client(
//   //           id: int.tryParse(doc.id) ?? 0, // Use Firestore document ID
//   //           name: data['name'] ?? 'Unknown', // Fallback if the field is missing
//   //           phone: data['contactNumber'] ?? 'Unknown',
//   //           monthlyBilling: (data['monthlyBilling'] ?? 0).toDouble(),
//   //           lastPaid: (data['lastPaid'] ?? 0).toDouble(),
//   //           paymentDate: (data['createDate'] as Timestamp).toDate(),
//   //         );
//   //       }).toList();
//   //
//   //       // Initially show all clients
//   //       filteredClients = clients;
//   //     });
//   //   } catch (e) {
//   //     print("Error fetching data: $e");
//   //   }
//   // }
//   // Future<void> fetchClients() async {
//   //   try {
//   //     // Fetch customers
//   //     QuerySnapshot customersSnapshot =
//   //     await FirebaseFirestore.instance.collection('customers').get();
//   //
//   //     // Fetch payments
//   //     QuerySnapshot paymentsSnapshot =
//   //     await FirebaseFirestore.instance.collection('payments').get();
//   //
//   //     // Create a map of payments grouped by customerId
//   //     Map<int, List<Map<String, dynamic>>> paymentsByCustomerId = {};
//   //     for (var paymentDoc in paymentsSnapshot.docs) {
//   //       final paymentData = paymentDoc.data() as Map<String, dynamic>;
//   //       int customerId = paymentData['customerId'];
//   //       paymentsByCustomerId[customerId] ??= [];
//   //       paymentsByCustomerId[customerId]!.add(paymentData);
//   //     }
//   //
//   //     // Process customers and associate payments
//   //     setState(() {
//   //       clients = customersSnapshot.docs.map((doc) {
//   //         final customerData = doc.data() as Map<String, dynamic>;
//   //         int customerId = int.tryParse(doc.id) ?? 0;
//   //
//   //         // Find all payments for this customer
//   //         List<Map<String, dynamic>> payments =
//   //             paymentsByCustomerId[customerId] ?? [];
//   //
//   //         return Client(
//   //           id: customerId,
//   //           name: customerData['name'] ?? 'Unknown',
//   //           phone: customerData['contactNumber'] ?? 'Unknown',
//   //           monthlyBilling: (customerData['monthlyBilling'] ?? 0).toDouble(),
//   //           lastPaid: payments.isNotEmpty
//   //               ? (payments.last['amount'] ?? 0).toDouble() // Last payment amount
//   //               : 0.0,
//   //           paymentDate: payments.isNotEmpty
//   //               ? (payments.last['paymentDate'] as Timestamp).toDate()
//   //               : DateTime.now(), // Last payment date or fallback to now
//   //         );
//   //       }).toList();
//   //
//   //       // Initially show all clients
//   //       filteredClients = clients;
//   //     });
//   //   } catch (e) {
//   //     print("Error fetching data: $e");
//   //   }
//   // }
//   // Future<void> fetchClients() async {
//   //   try {
//   //     // Fetch customers
//   //     QuerySnapshot customersSnapshot =
//   //     await FirebaseFirestore.instance.collection('customers').get();
//   //
//   //     // Fetch payments
//   //     QuerySnapshot paymentsSnapshot =
//   //     await FirebaseFirestore.instance.collection('payments').get();
//   //
//   //     // Create a map of payments grouped by customerId
//   //     Map<int, List<Map<String, dynamic>>> paymentsByCustomerId = {};
//   //     for (var paymentDoc in paymentsSnapshot.docs) {
//   //       final paymentData = paymentDoc.data() as Map<String, dynamic>;
//   //       int customerId = paymentData['customerId'];
//   //
//   //       // Add the payment to the map
//   //       paymentsByCustomerId[customerId] ??= [];
//   //       paymentsByCustomerId[customerId]!.add(paymentData);
//   //     }
//   //
//   //     // Process customers and associate payments
//   //     setState(() {
//   //       clients = customersSnapshot.docs.map((doc) {
//   //         final customerData = doc.data() as Map<String, dynamic>;
//   //         int customerId = int.tryParse(doc.id) ?? 0;
//   //
//   //         // Find all payments for this customer
//   //         List<Map<String, dynamic>> payments =
//   //             paymentsByCustomerId[customerId] ?? [];
//   //
//   //         // Sort payments by paymentDate (descending order)
//   //         payments.sort((a, b) {
//   //           return (b['paymentDate'] as Timestamp)
//   //               .compareTo((a['paymentDate'] as Timestamp));
//   //         });
//   //
//   //         return Client(
//   //           id: customerId,
//   //           name: customerData['name'] ?? 'Unknown',
//   //           phone: customerData['contactNumber'] ?? 'Unknown',
//   //           monthlyBilling: (customerData['monthlyBilling'] ?? 0).toDouble(),
//   //           lastPaid: payments.isNotEmpty
//   //               ? (payments.first['amount'] ?? 0).toDouble() // Latest payment amount
//   //               : 0.0,
//   //           paymentDate: payments.isNotEmpty
//   //               ? (payments.first['paymentDate'] as Timestamp).toDate()
//   //               : DateTime.now(), // Latest payment date or fallback to now
//   //         );
//   //       }).toList();
//   //
//   //       // Initially show all clients
//   //       filteredClients = clients;
//   //     });
//   //   } catch (e) {
//   //     print("Error fetching data: $e");
//   //   }
//   // }
//   Future<void> fetchClients() async {
//     try {
//       // Fetch customers
//       QuerySnapshot customersSnapshot =
//       await FirebaseFirestore.instance.collection('customers').get();

//       // Fetch payments
//       QuerySnapshot paymentsSnapshot =
//       await FirebaseFirestore.instance.collection('payments').get();

//       // Create a map of payments grouped by customerId
//       Map<int, List<Map<String, dynamic>>> paymentsByCustomerId = {};
//       for (var paymentDoc in paymentsSnapshot.docs) {
//         final paymentData = paymentDoc.data() as Map<String, dynamic>;
//         if (!paymentData.containsKey('customerId') ||
//             !paymentData.containsKey('paymentDate')) {
//           print('Invalid payment data: $paymentData');
//           continue; // Skip invalid data
//         }

//         int customerId = paymentData['customerId'];
//         paymentsByCustomerId[customerId] ??= [];
//         paymentsByCustomerId[customerId]!.add(paymentData);
//       }

//       print('Payments grouped by customerId: $paymentsByCustomerId');

//       // Process customers and associate payments
//       setState(() {
//         clients = customersSnapshot.docs.map((doc) {
//           final customerData = doc.data() as Map<String, dynamic>;
//           int customerId = int.tryParse(doc.id) ?? 0;

//           // Find all payments for this customer
//           List<Map<String, dynamic>> payments =
//               paymentsByCustomerId[customerId] ?? [];

//           // Sort payments by paymentDate (descending order)
//           payments.sort((a, b) {
//             return (b['paymentDate'] as Timestamp)
//                 .compareTo((a['paymentDate'] as Timestamp));
//           });

//           if (payments.isNotEmpty) {
//             print(
//                 'Latest payment for Customer $customerId: ${payments.first}');
//           } else {
//             print('No payments found for Customer $customerId');
//           }

//           return Client(
//             id: customerId,
//             name: customerData['name'] ?? 'Unknown',
//             phone: customerData['contactNumber'] ?? 'Unknown',
//             monthlyBilling: (customerData['monthlyBilling'] ?? 0).toDouble(),
//             lastPaid: payments.isNotEmpty
//                 ? (payments.first['amount'] ?? 0).toDouble() // Latest payment amount
//                 : 0.0,
//             paymentDate: payments.isNotEmpty
//                 ? (payments.first['paymentDate'] as Timestamp).toDate()
//                 : DateTime.fromMillisecondsSinceEpoch(0), // Default date
//           );
//         }).toList();

//         // Initially show all clients
//         filteredClients = clients;
//       });
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }





//   double calculateTotalAmount() {
//     return filteredClients.fold(0.0, (sum, client) => sum + client.lastPaid);
//   }

//   void filterClients() {
//     String query = searchController.text.toLowerCase();
//     setState(() {
//       filteredClients = clients.where((client) {
//         bool matchesName = client.name.toLowerCase().contains(query);
//         bool matchesDate = selectedDate == null ||
//             client.paymentDate.isAtSameMomentAs(selectedDate!) ||
//             client.paymentDate.isBefore(selectedDate!);
//         return matchesName && matchesDate;
//       }).toList();
//     });
//   }

//   void filterClientsByDate(DateTime date) {
//     setState(() {
//       selectedDate = date;
//       filterClients();
//     });
//   }

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
//                     colors: [Colors.blue, Colors.blueAccent],
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
//                     child: Text(
//                       'All Payments',
//                       style: const TextStyle(
//                         fontSize: 34,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Card(
//               color: Colors.white,
//               shadowColor: Colors.black.withOpacity(0.1),
//               elevation: 5,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15)),
//               child: ListTile(
//                 title: Text(
//                   'Total Amount: PKR ${calculateTotalAmount().toStringAsFixed(2)}',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: TextField(
//               controller: searchController,
//               onChanged: (value) {
//                 filterClients();
//               },
//               decoration: InputDecoration(
//                 labelText: 'Search Client',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 prefixIcon: Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () async {
//               DateTime? pickedDate = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime(2101),
//               );
//               if (pickedDate != null) {
//                 filterClientsByDate(pickedDate);
//               }
//             },
//             child: Text('Pick Date to Filter'),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredClients.length,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 8),
//                   elevation: 8,
//                   shadowColor: Colors.grey.withOpacity(0.2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 12, horizontal: 16),
//                     title: Text(
//                       filteredClients[index].name,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Phone: ${filteredClients[index].phone}'),
//                         Text(
//                             'Last Paid: PKR ${filteredClients[index].lastPaid}'),
//                         Text(
//                             'Payment Date: ${DateFormat.yMMMd().format(filteredClients[index].paymentDate)}'),
//                       ],
//                     ),
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

// class Client {
//   final int id;
//   final String name;
//   final String phone;
//   final double monthlyBilling;
//   final double lastPaid;
//   final DateTime paymentDate;

//   Client({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.monthlyBilling,
//     required this.lastPaid,
//     required this.paymentDate,
//   });
// }
// // import 'package:london_computers/colors/colors.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// //
// // void main() {
// //   runApp(MaterialApp(
// //     debugShowCheckedModeBanner: false,
// //     home: PaymentPage(),
// //   ));
// // }
// //
// // class PaymentPage extends StatefulWidget {
// //   @override
// //   _PaymentPageState createState() => _PaymentPageState();
// // }
// //
// // class _PaymentPageState extends State<PaymentPage> {
// //   final List<Client> clients = [
// //     Client(id: 1, name: 'Ali Khan', phone: '0301-2345678', monthlyBilling: 1000, lastPaid: 800, paymentDate: DateTime(2025, 1, 20)),
// //     Client(id: 2, name: 'Sara Ahmed', phone: '0312-9876543', monthlyBilling: 1500, lastPaid: 1500, paymentDate: DateTime(2025, 1, 18)),
// //     Client(id: 3, name: 'Hassan Raza', phone: '0321-5555555', monthlyBilling: 2000, lastPaid: 2000, paymentDate: DateTime(2025, 2, 1)),
// //     Client(id: 4, name: 'Fatima Shah', phone: '0345-6789012', monthlyBilling: 1200, lastPaid: 1100, paymentDate: DateTime(2025, 1, 25)),
// //     Client(id: 5, name: 'Zainab Iqbal', phone: '0333-1234567', monthlyBilling: 1700, lastPaid: 1700, paymentDate: DateTime(2025, 1, 30)),
// //     Client(id: 6, name: 'Imran Khan', phone: '0300-5555555', monthlyBilling: 2000, lastPaid: 1900, paymentDate: DateTime(2025, 2, 3)),
// //   ];
// //
// //   List<Client> filteredClients = [];
// //   DateTime? selectedDate;
// //   TextEditingController searchController = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     filteredClients = clients; // Initially show all clients
// //   }
// //
// //   double calculateTotalAmount() {
// //     return filteredClients.fold(0.0, (sum, client) => sum + client.lastPaid);
// //   }
// //
// //   void filterClients() {
// //     String query = searchController.text.toLowerCase();
// //     setState(() {
// //       filteredClients = clients.where((client) {
// //         bool matchesName = client.name.toLowerCase().contains(query);
// //         bool matchesDate = selectedDate == null || client.paymentDate.isAtSameMomentAs(selectedDate!) || client.paymentDate.isBefore(selectedDate!);
// //         return matchesName && matchesDate;
// //       }).toList();
// //     });
// //   }
// //
// //   void filterClientsByDate(DateTime date) {
// //     setState(() {
// //       selectedDate = date;
// //       filterClients(); // Reapply the filter after selecting the date
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // backgroundColor: Colors.grey[100],
// //       body: Column(
// //         children: [
// //           Stack(
// //             children: [
// //               // Background container with primary color and rounded corners
// //               Container(
// //                 height: 180,
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [AppColors.primaryColor_g1, AppColors.primaryColor_g2], // Gradient color for the AppBar
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                   borderRadius: const BorderRadius.only(
// //                     bottomLeft: Radius.circular(50),
// //                     bottomRight: Radius.circular(50),
// //                   ),
// //                 ),
// //               ),
// //               // Back icon positioned at the top-left corner
// //               Positioned(
// //                 top: 80,
// //                 left: 20,
// //                 child: IconButton(
// //                   icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
// //                   onPressed: () {
// //                     Navigator.pop(context); // Navigate back to the previous screen
// //                   },
// //                 ),
// //               ),
// //               // Client Name and ID in the center
// //               Positioned.fill(
// //                 child: Align(
// //                   alignment: Alignment.center,
// //                   child: Padding(
// //                     padding: const EdgeInsets.only(top: 80),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       children: [
// //                         Text(
// //                           'All Payments', // Page title
// //                           style: const TextStyle(
// //                             fontSize: 34,
// //                             fontWeight: FontWeight.bold,
// //                             color: AppColors.textColor, // Text color
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 16),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
// //             child: Card(
// //               color: Colors.white,
// //               shadowColor: Colors.black.withOpacity(0.1),
// //               elevation: 5,
// //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
// //               child: ListTile(
// //                 title: Text(
// //                   'Total Amount: \PKR ${calculateTotalAmount().toStringAsFixed(2)}',
// //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //             child: TextField(
// //               controller: searchController,
// //               onChanged: (value) {
// //                 filterClients();
// //               },
// //               decoration: InputDecoration(
// //                 labelText: 'Search Client',
// //                 labelStyle: TextStyle(color: Colors.grey[600]),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(30),
// //                   borderSide: BorderSide(color: Colors.grey.shade300),
// //                 ),
// //                 prefixIcon: Icon(Icons.search, color: Colors.grey),
// //                 filled: true,
// //                 fillColor: Colors.white,
// //                 contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //             child: ElevatedButton(
// //               onPressed: () async {
// //                 DateTime? pickedDate = await showDatePicker(
// //                   context: context,
// //                   initialDate: DateTime.now(),
// //                   firstDate: DateTime(2020),
// //                   lastDate: DateTime(2101),
// //                 );
// //                 if (pickedDate != null) {
// //                   filterClientsByDate(pickedDate);
// //                 }
// //               },
// //               style: ButtonStyle(
// //                 backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF3F51B5)),
// //                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
// //                   RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(30),
// //                   ),
// //                 ),
// //               ),
// //               child: Text(
// //                 'Pick Date to Filter',
// //                 style: TextStyle(color: Colors.white),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           Expanded(
// //             child: ListView.builder(
// //               itemCount: filteredClients.length,
// //               itemBuilder: (context, index) {
// //                 return Card(
// //                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                   elevation: 8,
// //                   shadowColor: Colors.grey.withOpacity(0.2),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   color: Colors.white,
// //                   child: ListTile(
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// //                     title: Text(
// //                       filteredClients[index].name,
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.w600,
// //                         color: AppColors.primaryColor,
// //                       ),
// //                     ),
// //                     subtitle: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Icon(Icons.phone, color: Colors.grey[600], size: 18),
// //                             const SizedBox(width: 5),
// //                             Text(
// //                               filteredClients[index].phone,
// //                               style: TextStyle(color: Colors.grey[600]),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 5),
// //                         Row(
// //                           children: [
// //                             Icon(Icons.payment, color: Colors.grey[600], size: 18),
// //                             const SizedBox(width: 5),
// //                             Text(
// //                               'Last Paid: \PKR ${filteredClients[index].lastPaid}',
// //                               style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 5),
// //                         Row(
// //                           children: [
// //                             Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
// //                             const SizedBox(width: 5),
// //                             Text(
// //                               'Payment Date: ${DateFormat.yMMMd().format(filteredClients[index].paymentDate)}',
// //                               style: TextStyle(color: Colors.grey[600], fontSize: 18),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class Client {
// //   final int id;
// //   final String name;
// //   final String phone;
// //   final double monthlyBilling;
// //   final double lastPaid;
// //   final DateTime paymentDate;
// //
// //   Client({
// //     required this.id,
// //     required this.name,
// //     required this.phone,
// //     required this.monthlyBilling,
// //     required this.lastPaid,
// //     required this.paymentDate,
// //   });
// // }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:london_computers/colors/colors.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List<Client> filteredClients = [];

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
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
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
                      'All Payments',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.1),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('payments').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  double totalAmount = snapshot.data!.docs.fold(0, (sum, doc) {
                    return sum + (doc['amount'] as num).toDouble();
                  });

                  return ListTile(
                    title: Text(
                      'Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {}); // Search filter apply karne ke liye
              },
              decoration: InputDecoration(
                labelText: 'Search Client',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {}); // UI ko refresh karne ke liye
              }
            },
            child: Text('Pick Date to Filter'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('payments').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Client> clients = snapshot.data!.docs.map((doc) {
                  return Client(
                    id: doc['customerId'],
                    name: doc['customerName'],
                    // phone: '',
                    lastPaid: (doc['amount'] as num).toDouble(),
                    paymentDate: (doc['paymentDate'] as Timestamp).toDate(),
                  );
                }).toList();
  clients.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
                // Search filter
                if (searchController.text.isNotEmpty) {
                  clients = clients.where((client) =>
                      client.name.toLowerCase().contains(searchController.text.toLowerCase())).toList();
                }

                return ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 8,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        title: Text(
                          clients[index].name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer ID: ${clients[index].id}'),
                            Text('Last Paid: PKR ${clients[index].lastPaid}'),
                            Text('Payment Date: ${DateFormat.yMMMd().format(clients[index].paymentDate)}'),
                          ],
                        ),
                      ),
                    );
                  },
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
  // final int phone;
  final double lastPaid;
  final DateTime paymentDate;

  Client({
    required this.id,
    required this.name,
    // required this.phone,
    required this.lastPaid,
    required this.paymentDate,
  });
}
