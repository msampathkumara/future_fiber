part of 'Ticket.dart';

Future<File?> _getFile(Ticket ticket, context, {onReceiveProgress}) async {
  final key = GlobalKey<LoadingState>();

  var loadingWidget = Loading(key: key, loadingText: "Downloading Ticket");
  loadingWidget.show(context);

  var dio = Dio();
  String filePath;
  if (kIsWeb) {
    filePath = ticket.isStandardFile ? '/st${ticket.id}.pdf' : '/${ticket.id}.pdf';
  } else {
    var ed = await getExternalStorageDirectory();
    filePath = ticket.isStandardFile ? '${ed!.path}/st${ticket.id}.pdf' : '${ed!.path}/${ticket.id}.pdf';
  }

  final user = FirebaseAuth.instance.currentUser;
  final idToken = await user!.getIdToken();
  dio.options.headers['content-Type'] = 'application/json';
  dio.options.headers["authorization"] = idToken;
  String queryString = Uri(queryParameters: {"id": ticket.id.toString()}).query;

  Response response;
  try {
    var path = ticket.isStandardFile ? "${EndPoints.tickets_standard_getPdf}?" : '${EndPoints.tickets_getTicketFile}?';

    await dio.download(await Server.getServerApiPath(path + queryString), filePath, deleteOnError: true, onReceiveProgress: (
      received,
      total,
    ) {
      // print("${received}/${total}");
      int percentage = ((received / total) * 100).floor();
      key.currentState?.onProgressChange(percentage);
      if (onReceiveProgress != null) {
        onReceiveProgress(percentage);
      }
    }).then((value) async {
      response = value;
      print('+++++++++++++++++++++++++++++++++++++++++++++');
      print(response.headers["fileVersion"].toString());
      String fileVersion = response.headers["fileVersion"]![0];
      await ticket.setLocalFileVersion(int.parse(fileVersion), ticket.getTicketType());
    });
  } on DioError catch (e) {
    if (e.response != null) {
      print('"******************************************** response');
      print(e.response.toString());
      if (e.response!.statusCode == 404) {
        loadingWidget.close(context);
        var errorView = const ErrorMessageView(errorMessage: "File Not Found", icon: Icons.sd_card_alert);
        await errorView.show(context);
        return Future.value(null);
      }

      print(e.response!.statusCode.toString());
      print(e.response!.data);
      print(e.response!.headers.toString());
    } else {
      print(e.message);
    }
  }

  loadingWidget.close(context);
  File file = File(filePath);
  ticket.ticketFile = file;
  return file;
}
