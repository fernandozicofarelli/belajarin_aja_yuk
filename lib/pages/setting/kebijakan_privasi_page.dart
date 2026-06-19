import 'package:flutter/material.dart';
import '../shared/app_bar_with_back.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithBack(context, 'Kebijakan Privasi'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Privasi Kamu Penting',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Kami menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi pengguna. Informasi Anda hanya digunakan untuk keperluan aplikasi Belajarin.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Dengan menggunakan aplikasi ini, Anda menyetujui kebijakan privasi kami.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
