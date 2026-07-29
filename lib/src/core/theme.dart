import 'package:flutter/material.dart';

/// Builds application themes and exposes the active color swatches.
class AppTheme {

  /// Primary color for destructive or error actions.
  static const Color errorPrimary = Colors.red;

  /// Secondary color for destructive or error actions.
  static final Color errorSecondary = Colors.red[300] ?? Colors.redAccent;

  /// Overlay alpha for focused controls.
  static const int alphaFocused = 36;

  /// Overlay alpha for pressed controls.
  static const int alphaPressed = 24;

  /// Overlay alpha for hovered controls.
  static const int alphaHovered = 12;

  /// Overlay alpha for disabled controls.
  static const int alphaDisabled = 5;

  /// Large display-text size.
  static const double sizeDisplayLarge = 28;

  /// Medium display-text size.
  static const double sizeDisplayMedium = 24;

  /// Large title-text size.
  static const double sizeTitleLarge = 18;

  /// Medium title-text size.
  static const double sizeTitleMedium = 16;

  /// Small title-text size.
  static const double sizeTitleSmall = 12;

  /// Medium body-text size.
  static const double sizeBodyMedium = 14;

  /// Small body-text size.
  static const double sizeBodySmall = 12;

  /// Large label-text size.
  static const double sizeLabelLarge = 16;

  /// Medium label-text size.
  static const double sizeLabelMedium = 14;

  /// Small label-text size.
  static const double sizeLabelSmall = 12;

  /// Whether the active theme is dark.
  static bool isDarkMode = false;

  /// Color swatches for the active theme.
  static ColorSwatches get swatches => isDarkMode ? _darkSwatches : _lightSwatches;

  static final ColorSwatches _lightSwatches = ColorSwatches(
    isDarkMode: false,
    // Foreground
    frontForeground: Colors.grey[900]!,
    middleForeground: Colors.grey[850]!,
    rearForeground: Colors.grey[800]!,
    // Background
    background: Colors.white,
    frontBackground: Colors.grey[200]!,
    middleBackground: Colors.grey[100]!,
    rearBackground: Colors.white,
    // Disabled
    disabledForeground: Colors.grey[800]!,
    disabledBackground: Colors.grey[500]!,
    // Text
    contentPrimary: Colors.black,
    contentSecondary: Colors.grey[900]!,
  );

  static final ColorSwatches _darkSwatches = ColorSwatches(
    isDarkMode: true,
    // Foreground
    frontForeground: Colors.white,
    middleForeground: Colors.grey[400]!,
    rearForeground: Colors.grey[600]!,
    // Background
    background: Colors.black,
    frontBackground: Colors.grey[800]!,
    middleBackground: Colors.grey[850]!,
    rearBackground: Colors.grey[900]!,
    // Disabled
    disabledForeground: Colors.grey[800]!,
    disabledBackground: Colors.grey[500]!,
    // Text
    contentPrimary: Colors.white,
    contentSecondary: Colors.grey[400]!,
  );

  /// Builds the light theme with [primary] as its seed color.
  static ThemeData light(Color primary) {
    return _theme(primary, _lightSwatches);
  }

  /// Builds the dark theme with [primary] as its seed color.
  static ThemeData dark(Color primary) {
    return _theme(primary, _darkSwatches);
  }

  /// Resolves a text-button overlay from its interaction state.
  static WidgetStateProperty<Color?>? textButtonOverlay(Color color) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return color.withAlpha(alphaPressed);
      } else if (states.contains(WidgetState.hovered)) {
        return color.withAlpha(alphaHovered);
      } else if (states.contains(WidgetState.focused)) {
        return color.withAlpha(alphaFocused);
      } else if (states.contains(WidgetState.disabled)) {
        return color.withAlpha(alphaDisabled);
      }
      return null;
    });
  }

  static ThemeData _theme(Color primary, ColorSwatches swatches) {
    // InputDecoration
    final inputDecoration = InputDecorationTheme(
      // Padding
      contentPadding: const EdgeInsets.all(4),
      // Color
      fillColor: swatches.middleBackground,
      filled: true,
      // Text
      labelStyle: TextStyle(
        color: swatches.contentSecondary,
        fontSize: sizeLabelSmall,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
      ),
      hintStyle: TextStyle(
        color: swatches.contentSecondary,
        fontSize: sizeBodyMedium,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
      ),
      helperMaxLines: 2,
      helperStyle: TextStyle(
        color: swatches.contentSecondary,
        fontSize: sizeBodySmall,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.25,
      ),
      // Prefix and suffix
      prefixIconColor: swatches.contentSecondary,
      prefixStyle: TextStyle(
        color: swatches.contentSecondary,
        fontSize: sizeLabelLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
      ),
      suffixIconColor: swatches.contentSecondary,
      suffixStyle: TextStyle(
        color: swatches.contentSecondary,
        fontSize: sizeLabelLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.15,
      ),
      // Borders
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: swatches.middleForeground,
          width: 3,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: swatches.middleForeground,
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
          color: swatches.rearForeground,
          width: 3,
        ),
      ),
    );
    final primarySchemes = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: swatches.isDarkMode ? Brightness.dark : Brightness.light,
    );
    // ThemeData
    return ThemeData(
      colorScheme: primarySchemes,
      useMaterial3: true,
      brightness: swatches.isDarkMode ? Brightness.dark : Brightness.light,
      // Color
      primaryColor: primary,
      scaffoldBackgroundColor: swatches.background,
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: primary,
        ),
        actionsIconTheme: IconThemeData(
          color: primary,
        ),
        titleTextStyle: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeTitleLarge,
        ),
      ),
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: swatches.rearBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        foregroundColor: primary,
      ),
      // Text
      textTheme: TextTheme(
        // Display
        displayLarge: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeDisplayLarge,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        displayMedium: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeDisplayMedium,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        // Title
        titleLarge: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeTitleLarge,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeTitleMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeTitleSmall,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.15,
          //height: 24,
        ),
        // Body
        bodyMedium: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeBodyMedium,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeBodySmall,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        // Label
        labelLarge: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeLabelLarge,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        labelMedium: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeLabelMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
        labelSmall: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeLabelSmall,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          //height: 24,
        ),
      ),
      // TextField
      inputDecorationTheme: inputDecoration,
      // Card
      cardTheme: CardThemeData(
        color: swatches.rearBackground,
        surfaceTintColor: primary,
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
          iconColor: WidgetStateProperty.all(swatches.contentPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
          textStyle: WidgetStateProperty.resolveWith((states) {
            late Color color;
            if (states.contains(WidgetState.disabled)) {
              color = swatches.rearForeground;
            } else {
              color = swatches.contentPrimary;
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
          textStyle: WidgetStateProperty.resolveWith((states) {
            late Color color;
            if (states.contains(WidgetState.disabled)) {
              color = swatches.rearForeground;
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
          color: swatches.middleForeground,
          width: 2,
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return primary;
          } else if (states.contains(WidgetState.hovered)) {
            return primary;
          } else if (states.contains(WidgetState.selected)) {
            return primary;
          } else {
            return null;
          }
        }),
      ),
      // Modal Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        modalBackgroundColor: swatches.rearBackground,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )
        ),
      ),
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: swatches.rearBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeTitleMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        contentTextStyle: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeBodyMedium,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
      ),
      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: swatches.contentPrimary,
        textColor: swatches.contentPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeTitleMedium,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        inputDecorationTheme: inputDecoration,
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          )),
        )
      ),
      // Badge
      badgeTheme: BadgeThemeData(
        backgroundColor: primary,
        textColor: swatches.frontForeground,
        smallSize: 8,
        largeSize: 16,
      ),
      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: swatches.middleBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Chip
      chipTheme: ChipThemeData(
        elevation: 0,
        backgroundColor: swatches.middleBackground,
        disabledColor: swatches.rearBackground,
        selectedColor: primary,
        labelStyle: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeBodyMedium,
        ),
        secondarySelectedColor: primary,
        secondaryLabelStyle: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeBodyMedium,
        ),
        shadowColor: Colors.transparent,
        side: const BorderSide(
          color: Colors.transparent,
        )
      ),
      // Divider
      dividerTheme: DividerThemeData(
        color: swatches.rearForeground,
      ),
      // TabBar
      tabBarTheme: TabBarThemeData(
        indicatorColor: primary,
        labelStyle: TextStyle(
          color: swatches.contentPrimary,
          fontSize: sizeTitleMedium,
        ),
        unselectedLabelStyle: TextStyle(
          color: swatches.contentSecondary,
          fontSize: sizeTitleMedium,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: swatches.background,
        selectedItemColor: primarySchemes.onSecondaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: swatches.background,
        selectedIconTheme: IconThemeData(
          color: primarySchemes.onSecondaryContainer,
        ),
        selectedLabelTextStyle: TextStyle(
          color: primarySchemes.onSecondaryContainer,
        ),
        indicatorColor: primarySchemes.secondaryContainer,
      )
    );
  }
}

/// Groups semantic colors shared by an application theme.
class ColorSwatches {

  /// Whether these swatches belong to a dark theme.
  final bool isDarkMode;

  /// Foreground colors ordered from front to rear.
  final Color frontForeground, middleForeground, rearForeground;

  /// Base application background.
  final Color background;

  /// Background colors ordered from front to rear.
  final Color frontBackground, middleBackground, rearBackground;

  /// Primary and secondary content colors.
  final Color contentPrimary, contentSecondary;

  /// Colors for disabled foreground and background content.
  final Color disabledForeground, disabledBackground;

  /// Creates a set of semantic color swatches.
  ColorSwatches({
    required this.isDarkMode,
    required this.frontForeground,
    required this.middleForeground,
    required this.rearForeground,
    required this.background,
    required this.frontBackground,
    required this.middleBackground,
    required this.rearBackground,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.disabledForeground,
    required this.disabledBackground,
  });

}
