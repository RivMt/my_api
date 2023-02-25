import 'package:flutter/material.dart';
import 'package:my_api/core/model/user.dart';


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
    return ListTile(
      leading: const Icon(Icons.account_circle_outlined),
      title: Text(
        "${user.firstName} ${user.lastName}", //TODO: Display user name as they set
      ),
      subtitle: Text(user.email),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}