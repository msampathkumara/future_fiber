import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:universal_html/html.dart' as html;

class SavePageAsPdf {
  static save(_data, int page, ticketName) {
    PdfDocument document = PdfDocument(inputBytes: _data);

    List<PdfPage> pagesToRemove = [];
    page = page - 1;
    for (var i = 0; i < document.pages.count; i++) {
      if (page != i) {
        pagesToRemove.add(document.pages[i]);
      }
    }

    for (var element in pagesToRemove) {
      document.pages.remove(element);
    }

    // List bytes = document.saveSync();

    //
    // final blob = html.Blob([_data], 'application/pdf');
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // html.window.open(url, 'new tab');

    js.context['pdfData'] = base64.encode(document.saveSync());
    js.context['filename'] = '$ticketName-p${page + 1}.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
    document.dispose();
  }
}
