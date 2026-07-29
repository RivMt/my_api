import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/user.dart';
import 'package:my_api/src/core/widget/user_icon.dart';

/// Displays a user's profile image, name, and email.
class UserCard extends StatelessWidget {
  /// Creates a user summary card.
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onLongPress,
    this.size = 32,
  });

  /// User to display.
  final User user;

  /// Called when the card is tapped.
  final Function()? onTap;

  /// Called when the card is long-pressed.
  final Function()? onLongPress;

  /// Profile image size.
  final double size;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserIcon(user, size: size),
      title: Text(user.displayName),
      subtitle: Text(user.email),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
