import 'package:flutter/material.dart';

/// Test widget to verify font loading and availability
/// This widget displays all configured fonts with different weights
/// Use this for testing during development - remove in production
class FontTestWidget extends StatelessWidget {
  const FontTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Font Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manrope font family tests
            const Text(
              'Manrope Font Family:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text(
              'Manrope Regular (400)',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Manrope Medium (500)',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Manrope Bold (700)',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              'Manrope ExtraBold (800)',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 32),

            // Fredoka One font family test
            const Text(
              'Fredoka One Font Family:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text(
              'Dualify - Login Title Style',
              style: TextStyle(
                fontFamily: 'Fredoka One',
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 32),

            // Lexend font family test
            const Text(
              'Lexend Font Family:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text(
              'Login screen body text - Track your apprenticeship progress',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 32),

            // Material Icons test
            const Text(
              'Material Icons Test:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Row(
              children: [
                Icon(Icons.dashboard, size: 32),
                SizedBox(width: 16),
                Icon(Icons.groups, size: 32),
                SizedBox(width: 16),
                Icon(Icons.support_agent, size: 32),
                SizedBox(width: 16),
                Icon(Icons.person, size: 32),
                SizedBox(width: 16),
                Icon(Icons.school, size: 32),
                SizedBox(width: 16),
                Icon(Icons.edit_square, size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
