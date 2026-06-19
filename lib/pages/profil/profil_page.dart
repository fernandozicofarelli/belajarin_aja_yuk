import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({Key? key}) : super(key: key);

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kelasController = TextEditingController();
  String? _photoUrl;
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data();
        if (data != null) {
          _namaController.text = data['nama'] ?? '';
          _kelasController.text = data['kelas'] ?? '';
          setState(() {
            _photoUrl = data['photoUrl'];
          });
        }
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = picked.name;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memilih gambar: $e")),
        );
      }
    }
  }

  Future<String?> _uploadToCloudinary(Uint8List imageBytes, String fileName) async {
    try {
      const cloudName = 'dbchk4mhm';
      
      // Try different variations of the preset name
      const uploadPresets = [
        'belajarin_aja_yuk',      // Exact match from dashboard
        'belajarin-aja-yuk',      // With dashes instead of underscores
        'belajarin_aja _yuk',     // Original from your first code
      ];

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Validate file size (max 10MB)
      if (imageBytes.length > 10 * 1024 * 1024) {
        throw Exception("Ukuran file terlalu besar (max 10MB)");
      }

      // Create safe filename
      final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalName = '${timestamp}_$safeName';

      Exception? lastError;

      // Try each upload preset
      for (String preset in uploadPresets) {
        try {
          print("Trying upload preset: $preset");
          
          final request = http.MultipartRequest('POST', url);
          request.fields['upload_preset'] = preset;
          request.fields['folder'] = 'profile_images'; // Optional: organize in folder
          
          // Add the image file
          request.files.add(
            http.MultipartFile.fromBytes(
              'file', 
              imageBytes, 
              filename: finalName,
            ),
          );

          print("Uploading image to Cloudinary with preset: $preset");
          final response = await request.send();
          
          print("Response status: ${response.statusCode}");

          if (response.statusCode == 200) {
            final resData = await response.stream.bytesToString();
            final jsonResponse = json.decode(resData);
            
            print("Upload successful with preset $preset: ${jsonResponse['secure_url']}");
            return jsonResponse['secure_url'];
          } else {
            final errorData = await response.stream.bytesToString();
            print("Upload failed with preset $preset - Status: ${response.statusCode}");
            print("Error response: $errorData");
            
            try {
              final errorJson = json.decode(errorData);
              final errorMessage = errorJson['error']?['message'] ?? 'Upload gagal';
              lastError = Exception(errorMessage);
              
              // If it's not a "preset not found" error, don't try other presets
              if (!errorMessage.contains("Upload preset not found")) {
                throw lastError!;
              }
            } catch (jsonError) {
              lastError = Exception("Upload gagal dengan status: ${response.statusCode}");
            }
          }
        } catch (e) {
          print("Error with preset $preset: $e");
          lastError = e is Exception ? e : Exception(e.toString());
          
          // If it's not a preset error, stop trying
          if (!e.toString().contains("Upload preset not found")) {
            rethrow;
          }
        }
      }
      
      // If all presets failed, throw the last error
      if (lastError != null) {
        throw lastError!;
      } else {
        throw Exception("Semua upload preset gagal. Pastikan upload preset sudah dibuat di Cloudinary dashboard.");
      }
      
    } catch (e) {
      print("Cloudinary upload error: $e");
      rethrow;
    }
  }

  Future<void> _simpanProfil() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User tidak ditemukan. Silakan login kembali.");
      }

      String? photoUrl = _photoUrl;

      // Upload new image if selected
      if (_imageBytes != null && _imageName != null) {
        print("Uploading new image...");
        photoUrl = await _uploadToCloudinary(_imageBytes!, _imageName!);
        
        if (photoUrl == null) {
          throw Exception("Gagal mengunggah gambar ke server");
        }
        print("Image uploaded successfully: $photoUrl");
      }

      // Save data to Firestore
      print("Saving profile data to Firestore...");
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nama': _namaController.text.trim(),
        'kelas': _kelasController.text.trim(),
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Profile saved successfully");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil disimpan"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        String errorMessage = _getErrorMessage(e.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains("Upload preset not found")) {
      return "Upload preset tidak ditemukan. Hubungi developer untuk mengatur Cloudinary.";
    } else if (error.contains("network") || error.contains("SocketException")) {
      return "Periksa koneksi internet Anda";
    } else if (error.contains("permission")) {
      return "Tidak memiliki izin untuk menyimpan";
    } else if (error.contains("Ukuran file terlalu besar")) {
      return "Ukuran gambar terlalu besar (max 10MB)";
    } else if (error.contains("Gagal mengunggah gambar")) {
      return "Gagal mengunggah gambar. Coba gambar lain atau periksa koneksi internet";
    } else {
      return "Gagal menyimpan profil. Silakan coba lagi.";
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _imageBytes != null
        ? MemoryImage(_imageBytes!)
        : (_photoUrl != null && _photoUrl!.isNotEmpty
            ? NetworkImage(_photoUrl!)
            : const AssetImage('assets/images/profile.png') as ImageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _isLoading ? null : _pickImage,
                      child: CircleAvatar(
                        backgroundImage: avatar,
                        radius: 50,
                        child: _imageBytes == null && (_photoUrl == null || _photoUrl!.isEmpty)
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                    if (!_isLoading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Ketuk untuk mengubah foto profil',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Masukkan nama';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama terlalu pendek';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(
                  labelText: 'Kelas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Masukkan kelas';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Menyimpan profil...'),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _simpanProfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}