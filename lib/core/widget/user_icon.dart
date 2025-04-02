import 'package:flutter/material.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';

const String _tag = "UserIcon";

class UserIcon extends StatelessWidget {

  const UserIcon(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    if (user.picture.isEmpty) {
      return const Icon(Icons.account_circle_outlined);
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(user.picture),
      onBackgroundImageError: (o, s) {
        Log.e(_tag, "Unable to display profile picture: ${user.picture}");
      },
    );
  }
}