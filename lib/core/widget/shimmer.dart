import 'package:flutter/material.dart';
import 'package:my_api/core/theme.dart';

class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;

  final bool isLoading;

  @override
  State createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with TickerProviderStateMixin {

  late AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late Animation<double> animation = CurvedAnimation(
    parent: controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Child
        widget.child,
        // Loading
        SizeTransition(
          sizeFactor: animation,
          axis: Axis.horizontal,
          axisAlignment: -1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            color: AppTheme.swatches.frontBackground,
            margin: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }


}