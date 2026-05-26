// import 'package:flutter/material.dart';
// import '../../../core/theme/app_theme.dart';
// import 'dashboard_screen.dart';
//
// class AuthScreen extends StatelessWidget {
//   const AuthScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0D11), // Midnight background
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Editorial Header
//               const Text(
//                 "DraftIt.",
//                 style: TextStyle(
//                   fontFamily: 'ClashDisplay',
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: -1,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "From Classroom to Career, One Draft at a Time.",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.white.withOpacity(0.6),
//                 ),
//               ),
//               const SizedBox(height: 48),
//
//               // Decorative Tech Element
//               Container(
//                 height: 2,
//                 width: 60,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 48),
//
//               // Input Fields
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Email address',
//                   hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.05),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 style: const TextStyle(color: Colors.white),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: 'Password',
//                   hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.05),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 style: const TextStyle(color: Colors.white),
//               ),
//               const SizedBox(height: 24),
//
//               // Sign In Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Navigate to dashboard
//                       // Add this line to navigate directly to the dashboard screen
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(builder: (context) => const DashboardScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Sign In",
//                       style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text("or", style: TextStyle(color: Colors.white.withOpacity(0.3))),
//                   ),
//                   Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
//                 ],
//               ),
//               const SizedBox(height: 24),
//
//               // Premium Google Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     // Trigger Google Sign In
//                   },
//                   icon: Image.network(
//                     'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
//                     height: 24,
//                   ),
//                   label: const Text(
//                     "Continue with Google",
//                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: Colors.white.withOpacity(0.15)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }