import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PengaturanPage extends StatelessWidget {
  final void Function(int) onNavigate;

  const PengaturanPage({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        children: [
          const SizedBox(height: 30),

          // Judul utama dalam box biru
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              "Pengaturan",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          _buildItem(Icons.settings, "Pengaturan", () => onNavigate(3)),
          _divider(),
          _buildItem(Icons.chat_bubble_outline, "Hubungi Kami", () => onNavigate(4)),
          _buildItem(Icons.info_outline, "Tentang Kami", () => onNavigate(5)),
          _divider(),
          _buildItem(Icons.privacy_tip_outlined, "Kebijakan Privasi", () => onNavigate(6)),
          _divider(),

          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.red),
            title: const Text(
              "Keluar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(thickness: 8, color: Color(0xFFF5F5F5));
  }
}
