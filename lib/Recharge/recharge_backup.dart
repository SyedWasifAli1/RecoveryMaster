import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:london_computers/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:london_computers/colors/colors.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RechargePage(),
  ));
}

// class RechargePage extends StatelessWidget {
//   final List<Client> clients = [
//     Client(id: 1, name: 'Ali Khan', phone: '0301-2345678', monthlyBilling: 1000, lastPaid: 800),
//     Client(id: 2, name: 'Sara Ahmed', phone: '0312-9876543', monthlyBilling: 1500, lastPaid: 1500),
//     Client(id: 3, name: 'Hassan Raza', phone: '0321-5555555', monthlyBilling: 2000, lastPaid: 2000),
//     Client(id: 4, name: 'Fatima Shah', phone: '0345-6789012', monthlyBilling: 1200, lastPaid: 1100),
//     Client(id: 5, name: 'Zainab Iqbal', phone: '0333-1234567', monthlyBilling: 1700, lastPaid: 1700),
//     Client(id: 6, name: 'Imran Khan', phone: '0300-5555555', monthlyBilling: 2000, lastPaid: 1900),
//   ];
//
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
//                           'Recharge', // Page title
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
//           // Search Field with Enhanced Styling
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
//           // const SizedBox(height: 16),
//           // Client List with Enhanced Cards
//           Expanded(
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
class RechargePage extends StatefulWidget {
  @override
  _RechargePageState createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    try {
      // Fetch customers collection from Firestore
      QuerySnapshot snapshot = await _firestore.collection('customers').get();
      setState(() {
        clients = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Client(
            id: doc.id.hashCode, // Use document ID hash as unique identifier
            name: data['name'] ?? 'Unknown',
            phone: data['contactNumber'] ?? 'N/A',
            monthlyBilling: (data['monthlyBilling'] ?? 0).toDouble(),
            lastPaid: (data['lastPaid'] ?? 0).toDouble(),
          );
        }).toList();
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

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.monthlyBilling,
    required this.lastPaid,
  });
}

class ClientDetailsPage extends StatelessWidget {
  final Client client;

  ClientDetailsPage({required this.client});

  final TextEditingController amountController = TextEditingController();

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
                  icon: Icon(Icons.arrow_back, color: AppColors.textColor, size: 30),
                  onPressed: () {
                    // Handle the back button press (e.g., navigate to previous screen)
                    Navigator.pop(context); // This will pop the current screen from the stack
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
                          client.name, // Client's name
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ID: ${client.id}', // Client ID
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor_2, // Lighter text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), // Space below profile section

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
                      colors: [AppColors.cardBackgroundColor, AppColors.cardBackgroundColor], // Soft gradient for info card
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

          // Amount Input Field with Enhanced Style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const SizedBox(height: 18), // Space between heading and text field

                // Heading
                Text(
                  'Cash Collection',
                  style: TextStyle(
                    fontSize: 34, // Font size for the heading
                    fontWeight: FontWeight.bold, // Make the heading bold
                    color: Colors.black, // Text color for the heading
                  ),
                ),
                const SizedBox(height: 18), // Space between heading and text field

                // Cash Collection TextField
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

          const SizedBox(height: 30), // Space below input field

          // Submit Payment Button with Gradient Background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // Green gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _showPaymentReceivedDialog(context); // Trigger payment dialog
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
                  backgroundColor: Colors.transparent, // Transparent button background
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
  void _showPaymentReceivedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center( // Center the title
            child: Text(
              'Payment Received',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Billing ID: ${client.id}', style: TextStyle(fontSize: 16)), // Assuming phone as billing ID for demo
              Text('${client.name}', style: TextStyle(fontSize: 22)),
              Text('PKR 4,500', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
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