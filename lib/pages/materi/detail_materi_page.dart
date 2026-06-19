import 'package:belajarin_aja_yuk/pages/materi/pdf_materi_page.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/materi_model.dart';
import '../../services/firebase_service.dart';

class DetailMateriPage extends StatefulWidget {
  final MateriModel materi;

  const DetailMateriPage({super.key, required this.materi});

  @override
  State<DetailMateriPage> createState() => _DetailMateriPageState();
}

class _DetailMateriPageState extends State<DetailMateriPage>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _controller;
  bool videoSelesai = false;

  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animasi tombol
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    // Youtube controller
    if (widget.materi.videoUrl.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.materi.videoUrl);
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );

        _controller!.addListener(() async {
          final isEnded = !_controller!.value.isPlaying &&
              _controller!.value.position >=
                  _controller!.value.metaData.duration;

          if (!_controller!.value.isPlaying &&
              _controller!.value.isReady &&
              isEnded &&
              !videoSelesai) {
            setState(() {
              videoSelesai = true;
            });
            _animController.forward(); // mulai animasi saat video selesai

            // Simpan progres video (0.3)
            await FirebaseService.simpanProgress(widget.materi.id, 0.3);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.materi.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_controller != null) ...[
              YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
              ),
              const SizedBox(height: 16),
            ],

            // Tombol Next ke PDF setelah video selesai
            if (videoSelesai)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Simpan progres PDF (0.6)
                      await FirebaseService.simpanProgress(widget.materi.id, 0.6);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PDFMateriPage(
                            pdfUrl: widget.materi.pdfUrl,
                            kuisData: widget.materi.quiz,
                            materiId: widget.materi.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Lanjut ke Materi PDF"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Ringkasan Materi
            Text("📚 Ringkasan Materi:", style: _sectionTitle),
            const SizedBox(height: 4),
            Text(
              widget.materi.summary.isNotEmpty
                  ? widget.materi.summary
                  : "Belum ada ringkasan.",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _sectionTitle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );
}
