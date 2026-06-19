import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData = [
    {'name': 'Ayu', 'score': 95},
    {'name': 'Budi', 'score': 90},
    {'name': 'Citra', 'score': 85},
    {'name': 'Dimas', 'score': 80},
    {'name': 'Eka', 'score': 75},
  ];

  @override
  Widget build(BuildContext context) {
    leaderboardData.sort((a, b) => b['score'].compareTo(a['score'])); // urutkan skor tertinggi

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: leaderboardData.length,
          itemBuilder: (context, index) {
            final user = leaderboardData[index];
            return Card(
              color: index == 0 ? Colors.yellow.shade100 : Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                ),
                title: Text(
                  user['name'],
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  '${user['score']} pts',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
