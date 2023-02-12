import 'package:flutter/material.dart';
import 'package:my_api/core/theme.dart';
import 'package:my_api/core/model/user.dart';
import 'package:my_api/core/widget/data_card.dart';


class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  final User user;

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      leading: Icon(
        Icons.account_circle_outlined,
        color: AppTheme.text,
      ), //TODO: Add user image
      top: Text(
        "${user.firstName} ${user.lastName}", //TODO: Display user name as they set
        style: Theme.of(context).textTheme.titleMedium,
      ),
      bottom: Text(
        user.email,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      onTap: onTap,
    );
  }
}