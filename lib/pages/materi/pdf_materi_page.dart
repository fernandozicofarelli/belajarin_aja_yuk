import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../kuis/kuis_page.dart';
import '../../services/firebase_service.dart';

class PDFMateriPage extends StatefulWidget {
  final String pdfUrl;
  final List<dynamic> kuisData;
  final String materiId;

  const PDFMateriPage({
    super.key,
    required this.pdfUrl,
    required this.kuisData,
    required this.materiId,
  });

  @override
  State<PDFMateriPage> createState() => _PDFMateriPageState();
}

class _PDFMateriPageState extends State<PDFMateriPage> {
  late PdfViewerController _pdfViewerController;
  int totalPages = 0;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  void _checkIfLastPage(int currentPage) {
    if (totalPages > 0 && currentPage == totalPages && !_isLastPage) {
      setState(() {
        _isLastPage = true;
      });

      /// ✅ Simpan progres PDF
      FirebaseService.simpanProgress(widget.materiId, 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Materi PDF")),
      body: Column(
        children: [
          Expanded(
            child: SfPdfViewer.network(
              widget.pdfUrl,
              controller: _pdfViewerController,
              onPageChanged: (details) =>
                  _checkIfLastPage(details.newPageNumber),
              onDocumentLoaded: (details) =>
                  totalPages = details.document.pages.count,
            ),
          ),
          if (_isLastPage)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KuisPage(
                        soalKuis: widget.kuisData.cast<Map<String, dynamic>>(),
                        materiId: widget.materiId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Lanjut ke Kuis"),
              ),
            ),
        ],
      ),
    );
  }
}
