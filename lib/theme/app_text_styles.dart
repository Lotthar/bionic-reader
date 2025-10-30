import 'package:flutter/material.dart';

/// Defines custom text styles for the application theme.
/// This class is used as a ThemeData extension.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.body,
    required this.bodyBold,
    required this.caption,
  });

  final TextStyle body;
  final TextStyle bodyBold;
  final TextStyle caption;

  @override
  AppTextStyles copyWith({
    TextStyle? body,
    TextStyle? bodyBold,
    TextStyle? caption,
  }) {
    return AppTextStyles(
      body: body ?? this.body,
      bodyBold: bodyBold ?? this.bodyBold,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      body: TextStyle.lerp(body, other.body, t)!,
      bodyBold: TextStyle.lerp(bodyBold, other.bodyBold, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}
