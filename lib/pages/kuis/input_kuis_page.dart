import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputKuisPage extends StatefulWidget {
  final String materiId; // dikaitkan dengan materi

  const InputKuisPage({Key? key, required this.materiId}) : super(key: key);

  @override
  State<InputKuisPage> createState() => _InputKuisPageState();
}

class _InputKuisPageState extends State<InputKuisPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> soalList = [];

  final TextEditingController _pertanyaanController = TextEditingController();
  final List<TextEditingController> _opsiControllers = List.generate(3, (_) => TextEditingController());
  String? _jawabanBenar;

  void _tambahSoal() {
    if (_formKey.currentState!.validate()) {
      soalList.add({
        'pertanyaan': _pertanyaanController.text,
        'opsi': _opsiControllers.map((c) => c.text).toList(),
        'jawaban': _jawabanBenar,
      });

      // reset input
      _pertanyaanController.clear();
      for (var c in _opsiControllers) c.clear();
      setState(() {
        _jawabanBenar = null;
      });
    }
  }

  Future<void> _submitKuis() async {
    if (soalList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu soal.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('kuis').doc(widget.materiId).set({
      'materiId': widget.materiId,
      'soal': soalList,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kuis berhasil disimpan')),
    );
    setState(() {
      soalList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Kuis'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Pertanyaan:', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _pertanyaanController,
                validator: (val) => val!.isEmpty ? 'Isi pertanyaan' : null,
              ),
              const SizedBox(height: 16),
              const Text('Opsi Jawaban:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    controller: _opsiControllers[i],
                    decoration: InputDecoration(labelText: 'Opsi ${i + 1}'),
                    validator: (val) => val!.isEmpty ? 'Isi semua opsi' : null,
                  ),
                );
              }),
              const SizedBox(height: 16),
              const Text('Jawaban Benar:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _jawabanBenar,
                items: _opsiControllers.map((c) {
                  return DropdownMenuItem(value: c.text, child: Text(c.text.isEmpty ? '(Kosong)' : c.text));
                }).toList(),
                onChanged: (val) => setState(() => _jawabanBenar = val),
                validator: (val) => val == null ? 'Pilih jawaban yang benar' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _tambahSoal,
                child: const Text('Tambah Soal'),
              ),
              const SizedBox(height: 16),
              if (soalList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daftar Soal Ditambahkan:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...soalList.map((s) => Text('- ${s['pertanyaan']}')).toList(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitKuis,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Simpan Semua ke Firestore'),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
