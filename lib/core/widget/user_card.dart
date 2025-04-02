import 'package:flutter/material.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/widget/user_icon.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onLongPress,
  });

  final User user;

  final Function()? onTap;

  final Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    const emptyPicture = Icon(Icons.account_circle_outlined);
    return ListTile(
      leading: UserIcon(user),
      title: Text(user.displayName),
      subtitle: Text(user.email),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}