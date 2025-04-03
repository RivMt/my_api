import 'package:flutter/material.dart';
import 'package:my_api/core/log.dart';
import 'package:my_api/core/model/user.dart';

const String _tag = "UserIcon";

class UserIcon extends StatelessWidget {

  const UserIcon(this.user, {
    super.key,
    this.size = 24,
  });

  final User user;

  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.account_circle_outlined,
      size: size,
    );
    if (user.picture.isEmpty) {
      return icon;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size/2),
      child: Image.network(user.picture,
        width: size,
        height: size,
        errorBuilder: (context, o, s) {
          Log.e(_tag, "Unable to display profile picture: ${user.picture}");
          return icon;
        },
      ),
    );
  }
}