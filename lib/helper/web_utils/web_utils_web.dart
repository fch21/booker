import 'dart:html' as html;

import 'package:booker/helper/web_utils/web_utils_interface.dart';

class WebUtilsImpl extends WebUtilsInterface {

  @override
  Map<String, String> getUrlParameters() {
    Map<String, String> parameters = {};

    final search = html.window.location.search;
    print("html.window.location.search = ${html.window.location.search}");
    if (search?.isEmpty ?? true) return parameters;

    final searchParameters = search!.substring(1).split('&');
    final parameterMap = <String, String>{};

    for (final parameter in searchParameters) {
      final keyValue = parameter.split('=');
      if (keyValue.length != 2) continue;
      final key = Uri.decodeComponent(keyValue[0]);
      final value = Uri.decodeComponent(keyValue[1]);
      parameterMap[key] = value;
    }

    parameters = parameterMap;

    print("parameters = $parameters");
    return parameters;
  }

  @override
  void removeUrlParameters() {
    Uri? uri = Uri.tryParse(html.window.location.href);
    print("uri.origin = ${uri?.origin}");
    print("uri.path = ${uri?.path}");
    if(uri != null){
      Uri? newUri = Uri.tryParse(uri.origin);
      // Atualize a URL sem parâmetros e sem adicionar uma entrada no histórico do navegador
      if(newUri != null) html.window.history.replaceState(null, '', newUri.toString());
    }
  }

  @override
  Future<bool> checkIfIsInstagramBrowser() async {
    bool isInstagramBrowser = false;
    if (html.window.navigator.userAgent.contains('Instagram')) {
      isInstagramBrowser = true;
    }
    return isInstagramBrowser;
  }
}