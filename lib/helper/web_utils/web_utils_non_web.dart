import 'package:booker/helper/web_utils/web_utils_interface.dart';

class WebUtilsImpl extends WebUtilsInterface{

  @override
  Map<String, String> getUrlParameters() {
    Map<String, String> parameters = {};
    return parameters;
  }

  @override
  void removeUrlParameters() {}

  @override
  Future<bool> checkIfIsInstagramBrowser() async {
    bool isInstagramBrowser = false;
    return isInstagramBrowser;
  }

}