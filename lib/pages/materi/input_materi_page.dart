import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputMateriPage extends StatefulWidget {
  const InputMateriPage({Key? key}) : super(key: key);

  @override
  State<InputMateriPage> createState() => _InputMateriPageState();
}

class _InputMateriPageState extends State<InputMateriPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _teksController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  String? _selectedPelajaran;

  final List<String> pelajaranList = ['Matematika', 'Fisika', 'Kimia']; // bisa diambil dari Firestore juga

  Future<void> _submitMateri() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('materi').add({
        'judul': _judulController.text,
        'teks': _teksController.text,
        'videoUrl': _videoUrlController.text,
        'pelajaran': _selectedPelajaran,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi berhasil ditambahkan!')),
      );

      _judulController.clear();
      _teksController.clear();
      _videoUrlController.clear();
      setState(() {
        _selectedPelajaran = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Materi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPelajaran,
                hint: const Text('Pilih Mata Pelajaran'),
                items: pelajaranList.map((pelajaran) {
                  return DropdownMenuItem(
                    value: pelajaran,
                    child: Text(pelajaran),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPelajaran = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih mata pelajaran' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Materi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'URL video harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teksController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ringkasan Materi (Teks)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Teks materi harus diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitMateri,
                child: const Text('Simpan Materi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
