import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  // Ganti dengan API key OpenRouter kamu
  static const String apiKey = String.fromEnvironment(
  'YOUR_OPENROUTER_API_KEY',
);
  static const apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> sendMessage(String prompt) async {
    print("sendMessage dipanggil dengan prompt: $prompt");
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",  // model OpenRouter
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
        }),
      ).timeout(const Duration(seconds: 15));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        print('AI Response: $reply');
        return reply.trim();
      } else {
        print('Gagal, kode status: ${response.statusCode}');
        print('Body respons: ${response.body}');
        return 'Gagal mendapatkan respons AI. Kode error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error saat request ke AI: $e');
      return 'Terjadi kesalahan saat menghubungi AI: $e';
    }
  }
}
