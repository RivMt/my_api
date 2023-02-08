import 'package:flutter/material.dart';

class AppTheme {

  static const Color errorPrimary = Colors.red;

  static final Color errorSecondary = Colors.red[300] ?? Colors.redAccent;

  static const int alphaFocused = 36;

  static const int alphaPressed = 24;

  static const int alphaHovered = 12;

  static const int alphaDisabled = 5;

  static const double sizeDisplayLarge = 28;

  static const double sizeTitleLarge = 18;

  static const double sizeTitleMedium = 16;

  static const double sizeTitleSmall = 12;

  static const double sizeBodyMedium = 14;

  static const double sizeBodySmall = 12;

  static const double sizeLabelLarge = 16;

  static const double sizeLabelMedium = 14;

  static const double sizeLabelSmall = 12;

  static MaterialStateProperty<Color?>? textButtonOverlay(Color color) {
    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return color.withAlpha(AppTheme.alphaPressed);
      } else if (states.contains(MaterialState.hovered)) {
        return color.withAlpha(AppTheme.alphaHovered);
      } else if (states.contains(MaterialState.focused)) {
        return color.withAlpha(AppTheme.alphaFocused);
      } else if (states.contains(MaterialState.disabled)) {
        return color.withAlpha(AppTheme.alphaDisabled);
      }
      return null;
    });
  }

  static ThemeData get light {
    return _theme(
      primary: Colors.blue,
      // Foreground
      frontForeground: Colors.grey[900] ?? Colors.black,
      middleForeground: Colors.grey[850] ?? Colors.black,
      rearForeground: Colors.grey[800] ?? Colors.black,
      // Background
      background: Colors.white,
      frontBackground: Colors.grey[500] ?? Colors.white,
      middleBackground: Colors.grey[300] ?? Colors.white,
      rearBackground: Colors.grey[100] ?? Colors.white,
      // Text
      text: Colors.black,
      subtext: Colors.grey[900] ?? Colors.black,
      // AppBar
    );
  }

  static ThemeData get dark {
    return _theme(
      primary: Colors.blue,
      // Foreground
      frontForeground: Colors.white,
      middleForeground: Colors.grey[400] ?? Colors.white,
      rearForeground: Colors.grey[600] ?? Colors.white,
      // Background
      background: Colors.black,
      frontBackground: Colors.grey[800] ?? Colors.grey,
      middleBackground: Colors.grey[850] ?? Colors.grey,
      rearBackground: Colors.grey[900] ?? Colors.grey,
      // Text
      text: Colors.white,
      subtext: Colors.grey[400] ?? Colors.white,
    );
  }

  static ThemeData _theme({
    // Base
    required Color primary,
    // Foreground
    required Color frontForeground,
    required Color middleForeground,
    required Color rearForeground,
    // Background
    required Color background,
    required Color frontBackground,
    required Color middleBackground,
    required Color rearBackground,
    // Text
    required Color text,
    required Color subtext,
  }) {
    // InputDecoration
    final inputDecoration = InputDecorationTheme(
      // Padding
      contentPadding: const EdgeInsets.all(4),
      // Color
      fillColor: middleBackground,
      filled: true,
      // Text
      labelStyle: TextStyle(
        color: subtext,
        fontSize: sizeLabelSmall,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
      ),
      hintStyle: TextStyle(
        color: subtext,
        fontSize: sizeBodyMedium,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
      ),
      helperMaxLines: 2,
      helperStyle: TextStyle(
        color: subtext,
        fontSize: sizeBodySmall,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.25,
      ),
      // Prefix and suffix
      prefixIconColor: subtext,
      prefixStyle: TextStyle(
        color: subtext,
        fontSize: sizeLabelLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
      ),
      suffixIconColor: subtext,
      suffixStyle: TextStyle(
        color: subtext,
        fontSize: sizeLabelLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
      ),
      // Borders
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: middleForeground,
          width: 3,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: middleForeground,
          width: 3,
        ),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: errorPrimary,
          width: 3,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: primary,
          width: 3,
        ),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorSecondary,
          width: 3,
        ),
      ),
      disabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: rearForeground,
          width: 3,
        ),
      ),
    );
    // ThemeData
    return ThemeData(
      // Color
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: text,
        ),
        actionsIconTheme: IconThemeData(
          color: text,
        ),
      ),
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: rearBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        foregroundColor: primary,
      ),
      // Text
      textTheme: TextTheme(
        // Display
        displayLarge: TextStyle(
          color: text,
          fontSize: sizeDisplayLarge,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        // Title
        titleLarge: TextStyle(
          color: text,
          fontSize: sizeTitleLarge,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: sizeTitleMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: subtext,
          fontSize: sizeTitleSmall,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
          //height: 24,
        ),
        // Body
        bodyMedium: TextStyle(
          color: subtext,
          fontSize: sizeBodyMedium,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: subtext,
          fontSize: sizeBodySmall,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        // Label
        labelLarge: TextStyle(
          color: subtext,
          fontSize: sizeLabelLarge,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        labelMedium: TextStyle(
          color: subtext,
          fontSize: sizeLabelMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
        labelSmall: TextStyle(
          color: subtext,
          fontSize: sizeLabelSmall,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          //height: 24,
        ),
      ),
      // TextField
      inputDecorationTheme: inputDecoration,
      // Card
      cardTheme: CardTheme(
        color: rearBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(4),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      // Buttons
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: MaterialStateProperty.all(text),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(const EdgeInsets.all(4)),
          textStyle: MaterialStateProperty.resolveWith((states) {
            late Color color;
            if (states.contains(MaterialState.disabled)) {
              color = rearForeground;
            } else {
              color = text;
            }
            return TextStyle(
              color: color,
              fontSize: sizeTitleMedium,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
            );
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.resolveWith((states) {
            late Color color;
            if (states.contains(MaterialState.disabled)) {
              color = rearForeground;
            } else {
              color = primary;
            }
            return TextStyle(
              color: color,
              fontSize: sizeTitleMedium,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
            );
          }),
          overlayColor: textButtonOverlay(primary),
        )
      ),
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        side: BorderSide(
          color: middleForeground,
          width: 2,
        ),
      ),
      // Modal Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        modalBackgroundColor: rearBackground,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )
        ),
      ),
      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: rearBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          color: text,
          fontSize: sizeTitleMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        contentTextStyle: TextStyle(
          color: subtext,
          fontSize: sizeBodyMedium,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
      ),
      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: text,
        textColor: text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: text,
          fontSize: sizeTitleMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        inputDecorationTheme: inputDecoration,
        menuStyle: MenuStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          )),
        )
      ),
      // Badge
      badgeTheme: BadgeThemeData(
        backgroundColor: primary,
        textColor: frontForeground,
        smallSize: 8,
        largeSize: 16,
      ),
      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: middleBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Chip
      chipTheme: ChipThemeData(
        elevation: 0,
        backgroundColor: middleBackground,
        disabledColor: rearBackground,
        selectedColor: primary,
        labelStyle: TextStyle(
          color: text,
          fontSize: sizeBodyMedium,
        ),
        secondarySelectedColor: primary,
        secondaryLabelStyle: TextStyle(
          color: text,
          fontSize: sizeBodyMedium,
        ),
        shadowColor: Colors.transparent,
        side: const BorderSide(
          color: Colors.transparent,
        )
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: rearForeground,
      ),
    );
  }

}