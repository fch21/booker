import 'dart:async';
import 'package:booker/helper/route_generator.dart';
import 'package:booker/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

import 'Strings.dart';


class Utils {
  static void showSnackBar(BuildContext context, String message) {
    print("showSnackBar = $message");
    if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),));
  }

  static DateTime? getDateTimeFromFormattedStrings(String date, String time) {

    DateTime? dateTime;

    var dateList = date.split("/");
    var timeList = time.split(":");

    if(dateList.length == 3 && timeList.length == 2){

      int? year = int.tryParse(dateList[2]);
      int? month = int.tryParse(dateList[1]);
      int? day = int.tryParse(dateList[0]);
      int? hour = int.tryParse(timeList[0]);
      int? minute = int.tryParse(timeList[1]);

      if(year != null && month != null && day != null && hour != null && minute != null){
        dateTime = DateTime(year + 2000, month, day, hour, minute);
      }
    }

    return dateTime;
  }

  /*
  static Future<File?> getImage(String source) async {
    File? image;
    final picker = ImagePicker();

    switch (source) {
      case Strings.CAMERA:
        final pickedFileCamera = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 15,
        );
        image = File(pickedFileCamera?.path ?? "");
        break;
      case Strings.GALLERY:
        final pickedFileGallery = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 15,
        );
        image = File(pickedFileGallery?.path ?? "");
        break;
    }

    return image;
  }

   */
  static Future<html.File> getImageWeb() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';

    final completer = Completer<html.File>();
    input.onChange.listen((event) {
      final file = input.files!.first;
      completer.complete(file);
    });

    input.click();
    return completer.future;
  }

  static Color darkenColor(Color color, double threshold) {
    // Convert the color to HSL
    HSLColor hsl = HSLColor.fromColor(color);
    // Calculate the lightness based on the threshold
    double lightness = hsl.lightness - (hsl.lightness - threshold).clamp(0.0, 1.0) * 0.2;

    // Ensure the new lightness does not exceed the threshold
    lightness = lightness < threshold ? lightness : threshold;

    // Return the color with adjusted lightness
    return hsl.withLightness(lightness).toColor();
  }

  static Color getNotTooLightColor(Color color) {
    double threshold = 0.8;

    // Compute the luminance of the input color.
    double luminance = color.computeLuminance();

    // If the color's luminance is greater than the threshold, darken it.
    if (luminance > threshold) {
      return darkenColor(color, threshold);
    }

    // If the color's luminance is lower than the threshold, return it as is.
    return color;
  }

  static Color? getContrastingColor(Color? color) {
    if(color == null) return null;
    // Calculating the luminance of the color
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    // If the color is very light, return black; otherwise, return white
    // Increase the threshold for "very light" color
    return luminance > 0.7 ? Colors.black : Colors.white; // Adjusted threshold to 0.7
  }

  static Future<void> sendEmailTo(BuildContext context, {required String email}) async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: email,
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if(context.mounted) Utils.showSnackBar(context, 'Não foi possível abrir o e-mail');
    }
  }

  static Future<void> sendMessageToWhatsApp(BuildContext context, {required String phoneNumber}) async {
    // Formata o número de telefone para o formato internacional (exemplo: '+5511999999999')
    final Uri whatsappUri = Uri(
      scheme: 'https',
      host: 'api.whatsapp.com',
      path: '/send',
      queryParameters: {
        'phone': phoneNumber, // Inclua o código do país no número de telefone
      },
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      if (context.mounted) Utils.showSnackBar(context, 'Não foi possível abrir o WhatsApp');
    }
  }

  static bool checkIfUserCanAccess({required bool subscriptionNeeded}){
    if(!subscriptionNeeded || (currentAppUser!.subscription?.isActive ?? false)){
      return true;
    }
    return false;
  }

  static Future<bool> showSubscriptionNeededDialogIfNecessary({required BuildContext context, required bool subscriptionNeeded}) async {
    bool userCanAccess = checkIfUserCanAccess(subscriptionNeeded: subscriptionNeeded);

    print("userCanAccess = $userCanAccess");
    if(!userCanAccess){
      bool goToSubscriptionsPage = false;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Assinatura necessária'),
            content: Text('Para acessar essa funcionalidade você precisa fazer a assinatura'),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: Text('Voltar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Detalhes da assinatura'),
                onPressed: () async {
                  goToSubscriptionsPage = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      if(context.mounted && goToSubscriptionsPage) await  Navigator.pushNamed(context, RouteGenerator.SUBSCRIPTION_MANAGEMENT);
    }
    return userCanAccess;
  }

  static Future<void> quitScreenIfUserIsNotASubscriber({
    required BuildContext context,
    required bool subscriptionNeeded,
    Duration duration = const Duration(seconds: 5)
  }) async {
    await Future.delayed(duration);
    if(context.mounted){
      bool canAccess = await showSubscriptionNeededDialogIfNecessary(context: context, subscriptionNeeded: subscriptionNeeded);
      if(!canAccess && context.mounted){
        Navigator.of(context).pop();
      }
    }
  }

  static DateFormat dateFormatForOrdering = DateFormat('yyyy-MM-dd HH:mm');
  static DateFormat dateFormatForVisualization = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDateTimeToOrder(DateTime dateTime) {
    final DateFormat formatter = dateFormatForOrdering;
    return formatter.format(dateTime);
  }

  static String formatDateTimeToVisualize(DateTime dateTime, {bool onlyDate = false}) {
    final DateFormat formatter = dateFormatForVisualization;
    String dateTimeString = formatter.format(dateTime);
    if(!onlyDate){
      return dateTimeString.replaceAll(" ", " às ");
    }
    else{
      return dateTimeString.substring(0, 10);
    }
  }

  static DateTime getDateTimeSimplified(DateTime dateTime){
    DateTime dateTimeSimplified = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateTimeSimplified;
  }

  static int getWeekDay(DateTime date) {
    // Dart 'weekday' dá 1 para Segunda-feira, 2 para Terça-feira e assim por diante.
    // Por isso vamos realizar o resto da divisao por 7 para fazer com que domingo (7) seja 0, segunda (1) seja 1...
    return  (date.weekday) % 7;
  }

  static String getWeekDayString(DateTime date) {
    return  Strings.WEEK_DAYS[getWeekDay(date)];
  }

  static String getFullWeekDayString(DateTime date) {
    return  Strings.FULL_WEEK_DAYS[getWeekDay(date)];
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  static String getFullWeekDayUpperCaseString(DateTime date) {
    return  capitalizeFirstLetter(Strings.FULL_WEEK_DAYS[getWeekDay(date)]);
  }
  
}
