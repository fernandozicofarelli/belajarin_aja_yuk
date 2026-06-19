import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../materi/materi_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<Map<String, dynamic>>> _materiMap = {};
  Map<String, double> _progressMap = {};
  bool _showAllProgress = false;
  String? _firstMateriTitle;

  @override
  void initState() {
    super.initState();
    _loadMateri();
    _listenToProgress();
  }

  Future<void> _loadMateri() async {
    try {
      final jsonString = await rootBundle.loadString('assets/semua_materi.json');
      final data = json.decode(jsonString);
      final List pelajaranList = data['mata_pelajaran'];
      final Map<String, List<Map<String, dynamic>>> result = {};

      for (var pelajaran in pelajaranList) {
        final nama = pelajaran['nama'];
        final materi = List<Map<String, dynamic>>.from(pelajaran['materi']);
        result[nama] = materi;
      }

      setState(() {
        _materiMap = result;
        _updateFirstMateriTitle();
      });
    } catch (e) {
      print("❌ Gagal memuat JSON: $e");
    }
  }

  void _listenToProgress() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance.collection('progress').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final Map<String, dynamic> progress = Map<String, dynamic>.from(data['materi'] ?? {});

        setState(() {
          _progressMap = progress.map((key, value) => MapEntry(key, (value as num).toDouble()));
          _updateFirstMateriTitle();
        });
      }
    });
  }

  void _updateFirstMateriTitle() {
    if (_materiMap.isEmpty || _progressMap.isEmpty) return;

    for (var entry in _materiMap.entries) {
      for (var materi in entry.value) {
        if (_progressMap.containsKey(materi['id'])) {
          _firstMateriTitle = materi['title'];
          return;
        }
      }
    }
  }

  void _openDetailMateri(BuildContext context, String pelajaran) {
    final daftarMateri = _materiMap[pelajaran] ?? [];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MateriListPage(
          pelajaran: pelajaran,
          materiList: daftarMateri,
          progressMap: _progressMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? firstMateriId = _progressMap.keys.isNotEmpty ? _progressMap.keys.first : null;
    final double mainProgress = firstMateriId != null ? _progressMap[firstMateriId]! : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Belajarin Aja Yuk!",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.8,
                  child: SizedBox(
                    width: 200,
                    height: 260,
                    child: Lottie.asset(
                      'assets/animations/robot.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 180),
                  const Text(
                    "Hai, studers! Siap belajar hari ini?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.play_circle_fill, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_firstMateriTitle ?? "Set Matematika Dasar", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text("Progress Pembelajaran"),
                                ],
                              ),
                            ),
                            
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: mainProgress,
                          backgroundColor: Colors.white,
                          color: Colors.blue,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text("${(mainProgress * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 14)),
                        TextButton.icon(
                          onPressed: () => setState(() => _showAllProgress = !_showAllProgress),
                          icon: Icon(_showAllProgress ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                          label: Text(_showAllProgress ? "Sembunyikan Semua Progress" : "Lihat Semua Progress"),
                        ),
                        if (_showAllProgress)
                          Column(
                            children: _progressMap.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 14))),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: entry.value,
                                        minHeight: 6,
                                        color: Colors.green,
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text("${(entry.value * 100).toStringAsFixed(0)}%"),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Materi Pelajaran", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  _materiMap.isEmpty
                      ? const Center(child: Text("⛔ Belum ada data materi ditemukan."))
                      : Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: _materiMap.keys.map((pelajaran) {
                            IconData icon;
                            Color iconColor;
                            Color bgColor;

                            switch (pelajaran) {
                              case "Matematika":
                                icon = Icons.calculate;
                                iconColor = Colors.indigo;
                                bgColor = Colors.indigo.shade50;
                                break;
                              case "Bahasa Indonesia":
                                icon = Icons.language;
                                iconColor = Colors.orange;
                                bgColor = Colors.orange.shade50;
                                break;
                              case "IPA":
                                icon = Icons.science;
                                iconColor = Colors.deepPurple;
                                bgColor = Colors.deepPurple.shade50;
                                break;
                              case "Bahasa Inggris":
                                icon = Icons.translate;
                                iconColor = Colors.green;
                                bgColor = Colors.green.shade50;
                                break;
                              case "Computer Science":
                                icon = Icons.memory;
                                iconColor = Colors.blueGrey;
                                bgColor = Colors.blueGrey.shade50;
                                break;
                              case "Cyber Security":
                                icon = Icons.shield;
                                iconColor = Colors.red;
                                bgColor = Colors.red.shade50;
                                break;
                              default:
                                icon = Icons.menu_book;
                                iconColor = Colors.grey;
                                bgColor = Colors.grey.shade100;
                                break;
                            }

                            return _buildFavoriteBox(context, icon, pelajaran, iconColor, bgColor);
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteBox(BuildContext context, IconData icon, String title, Color iconColor, Color bgColor) {
    return _HoverAnimatedBox(
      onTap: () => _openDetailMateri(context, title),
      icon: icon,
      title: title,
      iconColor: iconColor,
      bgColor: bgColor,
    );
  }
}

class _HoverAnimatedBox extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color bgColor;

  const _HoverAnimatedBox({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.bgColor,
    Key? key,
  }) : super(key: key);

  @override
  State<_HoverAnimatedBox> createState() => _HoverAnimatedBoxState();
}

class _HoverAnimatedBoxState extends State<_HoverAnimatedBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 150,
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? widget.bgColor.withOpacity(0.8) : widget.bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.iconColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
            border: _isHovered ? Border.all(color: widget.iconColor, width: 2) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 32),
              const SizedBox(height: 8),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isHovered ? _darken(widget.iconColor, 0.3) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
