import 'package:flutter/material.dart';
import '../shared/app_bar_with_back.dart';

class HubungiKamiPage extends StatelessWidget {
  const HubungiKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithBack(context, 'Hubungi Kami'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ada Pertanyaan?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kami siap membantu. Hubungi tim support kami untuk bantuan atau masukan.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('iniemailbukantahu@gmail.com'),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('+62 812 676 676'),
            ),
          ],
        ),
      ),
    );
  }
}
