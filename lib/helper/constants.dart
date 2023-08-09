import 'package:get/get.dart';

/// For UI
const double kLarge = 35;
const double kMedium = 25;
const double kSmall = 10;
const double kVerySmall = 06;

const double percentGapLarge = 0.05;
const double percentGapMedium = 0.03;
const double percentGapSmall = 0.02;
const double percentGapVerySmall = 0.005;


///Theme data
final colorScheme = Get.theme.colorScheme;
final textTheme = Get.theme.textTheme;
final deviceHeight = Get.height;
final deviceWidth = Get.width;

//some default color
final loadColor = colorScheme.onSurface.withOpacity(0.15);
final loadColorLight = colorScheme.onSurface.withOpacity(0.1);

final textColorDefault = colorScheme.onBackground;
final textColorMedium = colorScheme.onBackground.withOpacity(0.85);
final textColorLight = colorScheme.onBackground.withOpacity(0.5);
