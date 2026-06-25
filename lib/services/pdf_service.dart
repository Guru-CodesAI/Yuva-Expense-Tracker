import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' as fm;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class PdfService {
  // Use a high pixel ratio for sharp text in the PDF
  static const double _pixelRatio = 4.0;

  static Future<void> exportExpenseSummary({
    required List<Expense> expenses,
    required double totalExpense,
    required double savings,
    required double salary,
    required DateTime month,
  }) async {
    final pdf = pw.Document();

    // Pre-render all Tamil strings to images to ensure proper shaping/word formation
    final headerImg = await _textToImage(
      'யுவா செலவு அறிக்கை - ${DateFormat('MMMM yyyy').format(month)}',
      fontSize: 24,
      isBold: true,
    );

    final summaryImgs = [
      await _textToImage('மாத வருமானம்: ₹${salary.toStringAsFixed(2)}'),
      await _textToImage('மொத்த செலவு: ₹${totalExpense.toStringAsFixed(2)}'),
      await _textToImage('மீதமுள்ள சேமிப்பு: ₹${savings.toStringAsFixed(2)}'),
    ];

    final tableHeaderImgs = [
      await _textToImage('தேதி', color: fm.Colors.white, isBold: true),
      await _textToImage('வகை', color: fm.Colors.white, isBold: true),
      await _textToImage('தொகை (₹)', color: fm.Colors.white, isBold: true),
    ];

    List<List<pw.ImageProvider>> dataRows = [];
    for (var e in expenses) {
      dataRows.add([
        await _textToImage(DateFormat('dd/MM/yyyy').format(e.date)),
        await _textToImage(e.category),
        await _textToImage(e.amount.toStringAsFixed(2)),
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          // Header
          pw.Center(child: pw.Image(headerImg, height: 28)),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 20),

          // Summary Section
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: summaryImgs.map((img) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Image(img, height: 16),
              )).toList(),
            ),
          ),
          pw.SizedBox(height: 30),

          // Expense Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              // Table Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                children: tableHeaderImgs.map((img) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: pw.Center(child: pw.Image(img, height: 14)),
                )).toList(),
              ),
              // Table Data
              ...dataRows.map((row) => pw.TableRow(
                children: row.asMap().entries.map((entry) {
                  final img = entry.value;
                  final index = entry.key;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: index == 1 ? pw.Image(img, height: 14) : pw.Center(child: pw.Image(img, height: 14)),
                  );
                }).toList(),
              )),
            ],
          ),
          
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'YUVA Expense Tracker',
              style: const pw.TextStyle(color: PdfColors.grey500, fontSize: 10),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  /// Helper to render Tamil text as a crisp PNG image using Flutter's UI engine.
  /// This is the only 100% reliable way to get correct Tamil shaping in PDFs
  /// without an external shaper library.
  static Future<pw.ImageProvider> _textToImage(
    String text, {
    double fontSize = 16,
    fm.Color color = fm.Colors.black,
    bool isBold = false,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = fm.Canvas(recorder);
    
    // We use the same font as the UI for consistency and shaping support
    final textPainter = fm.TextPainter(
      text: fm.TextSpan(
        text: text,
        style: GoogleFonts.notoSansTamil(
          color: color,
          fontSize: fontSize * _pixelRatio,
          fontWeight: isBold ? fm.FontWeight.bold : fm.FontWeight.normal,
        ),
      ),
      textDirection: fm.TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(canvas, fm.Offset.zero);
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (textPainter.width + 2).toInt(),
      (textPainter.height + 2).toInt(),
    );
    
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return pw.MemoryImage(byteData!.buffer.asUint8List());
  }
}
