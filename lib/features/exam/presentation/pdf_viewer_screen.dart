import 'dart:io';

import 'package:dio/dio.dart';
import 'package:exampro/features/exam/data/exam_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String source; // http(s) URL or local file path (or file://)
  final int? examId; // to persist progress
  final String? userEmail; // to persist progress
  final int initialPage;
  const PdfViewerScreen({super.key, required this.source, this.examId, this.userEmail, this.initialPage = 0});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  String? _localPath;
  String? _error;
  bool _loading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final src = widget.source.trim();
      if (src.startsWith('http://') || src.startsWith('https://')) {
        final tmp = File(_tmpFilePath());
        await Dio().download(src, tmp.path, options: Options(responseType: ResponseType.bytes));
        setState(() {
          _localPath = tmp.path;
          _loading = false;
        });
        return;
      }
      // local path
      if (src.startsWith('file://')) {
        setState(() {
          _localPath = Uri.parse(src).toFilePath();
          _loading = false;
        });
      } else {
        setState(() {
          _localPath = src;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to open PDF: $e';
        _loading = false;
      });
    }
  }

  String _tmpFilePath() => '${Directory.systemTemp.path}/exam_${DateTime.now().millisecondsSinceEpoch}.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
              ? Center(child: Text(_error!))
              : (_localPath == null)
                  ? const Center(child: Text('No PDF path'))
                  : PDFView(
                      filePath: _localPath!,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: true,
                      pageFling: true,
                      defaultPage: widget.initialPage,
                      onPageChanged: (page, total) async {
                        _currentPage = page ?? 0;
                        if (widget.examId != null && (widget.userEmail?.isNotEmpty ?? false)) {
                          // Persist progress quietly
                          try {
                            await ref.read(examRepositoryProvider).savePdfProgress(
                                  examId: widget.examId!, userEmail: widget.userEmail!, page: _currentPage,
                                );
                          } catch (_) {}
                        }
                      },
                    ),
    );
  }
}
