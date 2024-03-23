
import 'package:booker/helper/web_utils/web_utils_non_web.dart'
if (dart.library.html) 'package:booker/helper/web_utils/web_utils_web.dart';


class WebUtils {

  static Map<String, String> getUrlParameters(){
    WebUtilsImpl webUtilsImpl = WebUtilsImpl();
    return webUtilsImpl.getUrlParameters();
  }

  static void removeUrlParameters() {
    WebUtilsImpl webUtilsImpl = WebUtilsImpl();
    return webUtilsImpl.removeUrlParameters();
  }

  static Future<bool> checkIfIsInstagramBrowser() {
    WebUtilsImpl webUtilsImpl = WebUtilsImpl();
    return webUtilsImpl.checkIfIsInstagramBrowser();
  }

}