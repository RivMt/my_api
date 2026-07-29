import 'package:flutter/material.dart';
import 'package:my_api/src/core/theme.dart';

/// Overlays a loading shimmer on its child.
class Shimmer extends StatefulWidget {
  /// Creates a loading shimmer.
  const Shimmer({
    super.key,
    required this.child,
    required this.isLoading,
  });

  /// Content displayed beneath the shimmer.
  final Widget child;

  /// Whether the loading overlay is visible.
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
