import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/tracker_session.dart';

class ExportsEngine {
  static Future<void> exportToClipboard(List<TrackerSession> sessions) async {
    if (sessions.isEmpty) return;
    final StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln('ID,Subject,Hours,Mood,Date,Tags');
    for (var session in sessions) {
      final dateStr = session.date.toIso8601String();
      final tagsStr = session.tags.join(';');
      csvBuffer.writeln(
        '${session.id},"${session.subject}",${session.hours},${session.mood},$dateStr,"$tagsStr"',
      );
    }
    await Clipboard.setData(ClipboardData(text: csvBuffer.toString()));
  }

  static Future<void> exportToPDF(List<TrackerSession> sessions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Focus Pulse - Study Log',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              if (sessions.isEmpty)
                pw.Text('No sessions logged yet.')
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Subject', 'Hours', 'Date', 'Tags'],
                    ...sessions.map(
                      (s) => [
                        s.subject,
                        s.hours.toString(),
                        s.date.toIso8601String().split('T').first,
                        s.tags.join(', '),
                      ],
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'study_logs.pdf',
    );
  }
}
