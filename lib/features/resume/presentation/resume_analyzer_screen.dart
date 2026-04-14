import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../data/resume_repository.dart';
import 'analysis_result_card.dart';

class ResumeAnalyzerScreen extends ConsumerStatefulWidget {
  const ResumeAnalyzerScreen({super.key});

  @override
  ConsumerState<ResumeAnalyzerScreen> createState() =>
      _ResumeAnalyzerScreenState();
}

class _ResumeAnalyzerScreenState
    extends ConsumerState<ResumeAnalyzerScreen> {
  PlatformFile? _selectedFile;
  bool _extracting = false;
  final TextEditingController _jobRoleController = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'txt'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _selectedFile = result.files.first);
  }

  Future<void> _analyze() async {
    if (_selectedFile == null) return;
    setState(() => _extracting = true);
    try {
      final text = await _extractText(_selectedFile!);
      if (text.trim().length < 20) {
        throw Exception('Resume text is too short to analyze.');
      }
      await ref.read(resumeAnalysisNotifierProvider.notifier).analyze(
            resumeText: text,
            jobRole: _jobRoleController.text.trim(),
            fileName: _selectedFile!.name,
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  Future<String> _extractText(PlatformFile file) async {
    final extension = file.extension?.toLowerCase();
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();

    if (extension == 'txt') {
      return utf8.decode(bytes);
    }
    if (extension == 'pdf') {
      return _extractPdfText(bytes);
    }
    return '';
  }

  Future<String> _extractPdfText(Uint8List bytes) async {
    final document = await PdfDocument.openData(bytes);
    await document.close();
    return _parsePdfText(bytes);
  }

  String _parsePdfText(Uint8List bytes) {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final buffer = StringBuffer();
    final simpleText = RegExp(r'\(([^)]{1,200})\)\s*Tj');
    for (final match in simpleText.allMatches(raw)) {
      buffer.write('${_cleanPdfText(match.group(1) ?? '')} ');
    }
    final arrayText = RegExp(r'\[(.*?)\]\s*TJ', dotAll: true);
    for (final match in arrayText.allMatches(raw)) {
      final inner = match.group(1) ?? '';
      final innerMatches = RegExp(r'\(([^)]*)\)').allMatches(inner);
      for (final innerMatch in innerMatches) {
        buffer.write('${_cleanPdfText(innerMatch.group(1) ?? '')} ');
      }
    }
    final cleaned = buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  String _cleanPdfText(String text) {
    return text
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\\', '\\')
        .replaceAll(r'\n', ' ')
        .replaceAll(r'\r', ' ')
        .replaceAll(r'\t', ' ')
        .trim();
  }

  Future<void> _downloadReport(Map<String, dynamic> json) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/resume_report_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report saved to ${file.path}')),
    );
  }

  @override
  void dispose() {
    _jobRoleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisAsync = ref.watch(resumeAnalysisNotifierProvider);
    final historyAsync = ref.watch(resumeHistoryProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resume Analyzer'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Results'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _uploadCard(context),
                const SizedBox(height: 12),
                TextField(
                  controller: _jobRoleController,
                  decoration: const InputDecoration(
                    labelText: 'Target job role (optional)',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedFile == null || _extracting
                        ? null
                        : _analyze,
                    child: Text(_extracting ? 'Analyzing...' : 'Analyze'),
                  ),
                ),
                if (_extracting || analysisAsync.isLoading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Analyzing...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                analysisAsync.when(
                  data: (analysis) {
                    if (analysis == null) {
                      return _emptyState(context);
                    }
                    return Column(
                      children: [
                        ScoreGauge(score: analysis.score),
                        const SizedBox(height: 12),
                        AnalysisResultCard(
                          title: 'Strengths',
                          items: analysis.strengths,
                        ),
                        AnalysisResultCard(
                          title: 'Weaknesses',
                          items: analysis.weaknesses,
                        ),
                        AnalysisResultCard(
                          title: 'Missing Keywords',
                          items: analysis.missingKeywords,
                        ),
                        AnalysisResultCard(
                          title: 'Suggestions',
                          items: analysis.suggestions,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _downloadReport(analysis.toJson()),
                            icon: const Icon(Icons.download),
                            label: const Text('Download Report'),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, _) => Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            historyAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _emptyState(context);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _scoreColor(item.score),
                          child: Text(
                            '${item.score}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(item.fileName),
                        subtitle: Text(
                          DateFormatter.shortDateTime(item.analyzedAt),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadCard(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload PDF or TXT',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                _selectedFile?.name ?? 'Tap to select a file',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'No analysis yet. Upload a resume to get started.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.mutedText),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.amber;
    return Colors.redAccent;
  }
}

class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? Colors.green
        : score >= 40
            ? Colors.amber
            : Colors.redAccent;
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: CustomPaint(
            painter: _GaugePainter(progress: score / 100, color: color),
            child: Center(
              child: Text(
                '$score',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ATS Compatibility Score',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.mutedText),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final backgroundPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14,
      3.14,
      false,
      backgroundPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14,
      3.14 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final length = dashWidth + dashSpace;
        final segment = metric.extractPath(
          distance,
          (distance + dashWidth).clamp(0, metric.length),
        );
        canvas.drawPath(segment, paint);
        distance += length;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
