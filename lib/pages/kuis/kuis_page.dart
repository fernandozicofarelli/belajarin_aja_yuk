import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class KuisPage extends StatefulWidget {
  final List<Map<String, dynamic>> soalKuis;
  final String materiId;

  const KuisPage({super.key, required this.soalKuis, required this.materiId});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  int currentIndex = 0;
  int skor = 0;
  bool tampilHasil = false;
  int _remainingTime = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTime = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        timer.cancel();
        _lanjutkanKuis();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _lanjutkanKuis() {
    if (currentIndex < widget.soalKuis.length - 1) {
      setState(() {
        currentIndex++;
        _startTimer();
      });
    } else {
      setState(() {
        tampilHasil = true;
      });
       FirebaseService.simpanProgress(widget.materiId, 1.0);
    }
  }

  void cekJawaban(String pilihan) {
    _timer?.cancel();
    if (pilihan == widget.soalKuis[currentIndex]['jawaban']) {
      skor++;
    }
    _lanjutkanKuis();
  }

  void resetKuis() {
    setState(() {
      currentIndex = 0;
      skor = 0;
      tampilHasil = false;
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.soalKuis.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Belum ada kuis untuk materi ini')),
      );
    }

    final current = widget.soalKuis[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuis'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: tampilHasil
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Skor kamu:',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$skor / ${widget.soalKuis.length}',
                      style:
                          const TextStyle(fontSize: 32, color: Colors.blue),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: resetKuis,
                      child: const Text('Ulangi Kuis'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soal ${currentIndex + 1} dari ${widget.soalKuis.length}',
                    style:
                        const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sisa waktu: $_remainingTime detik',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    current['soal'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  ...List<String>.from(current['opsi'] ?? []).map((pilihan) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        onPressed: () => cekJawaban(pilihan),
                        child:
                            Text(pilihan, style: const TextStyle(fontSize: 16)),
                      ),
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
