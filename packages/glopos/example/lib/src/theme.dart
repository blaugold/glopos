import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lang_utils.dart';

ThemeData _sharedThemeCustomizations(ThemeData theme) => theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );

ThemeData lightTheme(BuildContext context) =>
    ThemeData.from(colorScheme: const ColorScheme.light())
        .let(_sharedThemeCustomizations);

ThemeData darkTheme(BuildContext context) =>
    ThemeData.from(colorScheme: const ColorScheme.dark())
        .let(_sharedThemeCustomizations);
