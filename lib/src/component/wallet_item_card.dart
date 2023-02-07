import 'package:flutter/material.dart';
import 'package:my_api/src/component/data_card.dart';
import 'package:my_api/src/model/account.dart';
import 'package:my_api/src/model/payment.dart';

class WalletItemIcon extends StatelessWidget {

  const WalletItemIcon({
    super.key,
    required this.foreground,
    required this.background,
    required this.icon,
    this.selected = false,
  });

  final Color foreground, background;

  final IconData icon;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: selected,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: foreground,
        ),
      ),
    );
  }
}

class WalletItemCard extends StatelessWidget {
  const WalletItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.foreground,
    required this.background,
    required this.icon,
    this.selected = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
  });

  final IconData icon;

  final Color foreground, background;

  final String title, subtitle;

  final bool selected;

  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      leading: WalletItemIcon(
        icon: icon,
        foreground: foreground,
        background: background,
        selected: selected,
      ),
      main: Text(
        subtitle,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      sub: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      color: Colors.transparent,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
    );
  }
}

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.data,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
    this.selected = false,
  });

  /// [Account] instance to display information
  final Account data;

  final bool selected;

  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  Widget build(BuildContext context) {
    return WalletItemCard(
      title: data.currency.format(data.balance),
      subtitle: data.descriptions,
      foreground: data.foreground,
      background: data.background,
      icon: data.icon.icon,
      selected: selected,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
    );
  }

}

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.data,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
    this.selected = false,
  });

  /// [Payment] instance to display information
  final Payment data;

  final bool selected;

  final Function()? onTap, onDoubleTap, onLongPress;

  final Function(bool)? onHover;

  @override
  Widget build(BuildContext context) {
    return WalletItemCard(
      title: data.descriptions,
      subtitle: data.serialNumber,
      foreground: data.foreground,
      background: data.background,
      icon: data.icon.icon,
      selected: selected,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHover: onHover,
    );
  }

}