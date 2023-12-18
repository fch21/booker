import 'dart:async';
import 'package:flutter/material.dart';

import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';


class Utils {
  static void showSnackBar(BuildContext context, String error) {
    print("showSnackBar = $error");
    if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error),));
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

}
