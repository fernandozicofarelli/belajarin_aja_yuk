import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../shared/app_bar_with_back.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: buildAppBarWithBack(context, 'Pengaturan'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Akun',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Informasi Akun'),
              subtitle: Text('${user?.email ?? "-"}\nUID: ${user?.uid ?? "-"}'),
              isThreeLine: true,
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Ganti Kata Sandi'),
              onTap: () => _showResetPasswordDialog(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('Versi Aplikasi'),
              subtitle: Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    emailController.text = user?.email ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ganti Kata Sandi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kami akan mengirimkan link reset ke email berikut:'),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: emailController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link reset dikirim ke email.'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengirim: $e'),
                    ),
                  );
                }
              },
              child: const Text('Kirim Link'),
            ),
          ],
        );
      },
    );
  }
}
