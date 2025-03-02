import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'db_helper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Login Function
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      return await saveUserSession(uid);
    } catch (e) {
      return "Login failed: $e";
    }
  }

  // ✅ Check Firestore Role and Set Session with Expiry
  Future<String?> saveUserSession(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('collectors').doc(uid).get();

    if (!userDoc.exists) return "User not found";

    // Check user role
    String role = userDoc.get('role') ?? 'pending'; // Default to 'pending' if no role is found

    if (role == 'collector') {
      // If the user is a collector, set session expiry time for 30 days
      DateTime expiryDate = DateTime.now().add(Duration(days: 30)); // 30 days from now

      // Save session expiry time to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('session_expiry', expiryDate.millisecondsSinceEpoch);

      return null; // Login Successful
    } else {
      // If the user is not a collector, show a message indicating admin approval
      return "Waiting for admin approval";
    }
  }

  // ✅ Check if session is valid
  Future<bool> isSessionValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sessionExpiryTimestamp = prefs.getInt('session_expiry');

    if (sessionExpiryTimestamp == null) {
      return false; // No session found
    }

    DateTime sessionExpiryDate = DateTime.fromMillisecondsSinceEpoch(sessionExpiryTimestamp);

    // If the session has expired, return false
    return sessionExpiryDate.isAfter(DateTime.now());
  }

  // ✅ Logout Function
  Future<void> logout() async {
    await _auth.signOut();
    await DBHelper().clearSession();

    // Clear session expiry from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_expiry');
  }
}
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'db_helper.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // ✅ Login Function
//   Future<String?> login(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
//       String uid = userCredential.user!.uid;
//       return await saveUserSession(uid);
//     } catch (e) {
//       return "Login failed: $e";
//     }
//   }
//
//   // ✅ Check Firestore Role and Set Session
//   Future<String?> saveUserSession(String uid) async {
//     DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
//
//     if (!userDoc.exists) return "User not found";
//
//     // Check user role
//     String role = userDoc.get('role') ?? 'pending'; // Default to 'pending' if no role is found
//
//     if (role == 'collector') {
//       // If the user is a collector, allow login
//       return null; // Login Successful
//     } else {
//       // If the user is not a collector, show a message indicating admin approval
//       return "Waiting for admin approval";
//     }
//   }
//
//   // ✅ Logout Function
//   Future<void> logout() async {
//     await _auth.signOut();
//     await DBHelper().clearSession();
//   }
// }
//
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'db_helper.dart';
// //
// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //   // ✅ Login Function
// //   Future<String?> login(String email, String password) async {
// //     try {
// //       UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
// //       String uid = userCredential.user!.uid;
// //       return await saveUserSession(uid);
// //     } catch (e) {
// //       return "Login failed: $e";
// //     }
// //   }
// //
// //   // ✅ Check Firestore Subscription & Set Session Expiry
// //   Future<String?> saveUserSession(String uid) async {
// //     DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
// //     if (!userDoc.exists) return "User not found";
// //
// //     bool isActive = userDoc.get('subscription_active'); // Firestore Column
// //     if (!isActive) return "Subscription expired";
// //
// //     Timestamp expiryTimestamp = userDoc.get('expiry_time'); // Firestore Timestamp
// //     int expiryTime = expiryTimestamp.millisecondsSinceEpoch; // Convert to int
// //
// //     await DBHelper().setSessionExpiryTime(expiryTime);
// //     return null; // Login Successful
// //   }
// //
// //   // ✅ Logout Function
// //   Future<void> logout() async {
// //     await _auth.signOut();
// //     await DBHelper().clearSession();
// //   }
// // }
