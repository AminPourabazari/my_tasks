import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

///یک تابع برای تبدیل شماره‌ها و برخی حروف در زبان‌های فارسی، عربی و انگلیسی به همدیگر
String convertNumber(String text, String language) {
  // دیکشنری‌ها در یک Map کلی
  const Map<String, Map<String, String>> languageMaps = {
    'fa-en': {'۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4', '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9', '،': ',', '؟': '?', '؛': ';', '٪': '%'},
    'fa-ar': {'۴': '٤', '۶': '٦', 'ی': 'ي', 'ک': 'ك'},
    'en-fa': {'0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴', '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹', ',': '،', '?': '؟', ';': '؛', '%': '٪'},
    'en-ar': {'0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '٤', '5': '۵', '6': '٦', '7': '۷', '8': '۸', '9': '۹', ',': '،', '?': '؟', ';': '؛', '%': '٪'},
    'ar-fa': {'٤': '۴', '٦': '۶', 'ي': 'ی', 'ك': 'ک'},
    'ar-en': {'۰': '0', '۱': '1', '۲': '2', '۳': '3', '٤': '4', '۵': '5', '٦': '6', '۷': '7', '۸': '8', '۹': '9', '،': ',', '؟': '?', '؛': ';', '٪': '%'}
  };

  // پیدا کردن دیکشنری مربوطه
  final selectedMap = languageMaps[language];

  // اگر دیکشنری برای زبان وجود ندارد، همان متن را برمی‌گردانیم
  if (selectedMap == null) return text;

  // استفاده از StringBuffer برای بهینه‌تر کردن عملیات جایگزینی
  StringBuffer buffer = StringBuffer();

  // جایگزینی هر کاراکتر در متن با استفاده از دیکشنری
  for (int i = 0; i < text.length; i++) {
    // جایگزینی کاراکتر با استفاده از دیکشنری یا نگه داشتن همان کاراکتر اگر موجود نباشد
    buffer.write(selectedMap[text[i]] ?? text[i]);
  }
  return buffer.toString();
}

/// تابع امتیازدهی مارکت‌ها
Future rateApplication({required String packageName, required AppMarket market, BuildContext? context}) async {
  String url;

  switch (market) {
    case AppMarket.bazaar: url = 'bazaar://details?id=$packageName';
      break;
    case AppMarket.myket: url = 'myket://comment?id=$packageName';
      break;
    case AppMarket.parshub: url = 'jhoobin://comment?q=$packageName';
      break;
    case AppMarket.playStore: url = 'market://details?id=$packageName';
      break;
    case AppMarket.samsungApps: url = 'samsungapps://ProductDetail/$packageName';
      break;
    case AppMarket.other:
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Other market logic not implemented yet.')),
        );
      }
      return;
  }

  final uri = Uri.parse(url);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (market == AppMarket.playStore) {
        final webUrl = 'https://play.google.com/store/apps/details?id=$packageName';///todo
        final webUri = Uri.parse(webUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open Play Store for $packageName')),
            );
          }
          print('Could not launch $webUrl');
        }
      } else if (market == AppMarket.samsungApps) {
        final webUrl = 'https://galaxystore.samsung.com/detail/$packageName';
        final webUri = Uri.parse(webUrl);
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          // اگر حتی نسخه وب هم باز نشد
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open Samsung Apps for $packageName')),
            );
          }
          print('Could not launch $webUrl');
        }
      }
      else {
        // برای سایر مارکت‌هایی که نسخه وب عمومی ندارند یا URL آن را نمی‌دانیم
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open ${market.name} for $packageName')),
          );
        }
        print('Could not launch $url');
      }
    }
  } catch (e) {
    // گرفتن خطاهای احتمالی دیگر در هنگام اجرای launchUrl
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
    print('Error launching URL: $e');
  }
}
