abstract class WebUtilsInterface {
  Map<String, String> getUrlParameters();
  void removeUrlParameters();
  Future<bool> checkIfIsInstagramBrowser();
}