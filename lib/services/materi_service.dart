import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/materi_model.dart';

class MateriService {
  static Future<Map<String, List<MateriModel>>> loadSemuaMateri() async {
    final String jsonString = await rootBundle.loadString('assets/semua_materi.json');
    final jsonData = json.decode(jsonString);

    Map<String, List<MateriModel>> result = {};

    for (var pelajaran in jsonData['mata_pelajaran']) {
      final nama = pelajaran['nama'];
      final materiList = (pelajaran['materi'] as List)
          .map((e) => MateriModel.fromJson(e))
          .toList();
      result[nama] = materiList;
    }

    return result;
  }
}
