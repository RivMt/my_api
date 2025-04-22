import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/user.dart';
import 'package:my_api/src/core/widget/user_icon.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onLongPress,
    this.size = 32,
  });

  final User user;

  final Function()? onTap;

  final Function()? onLongPress;

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