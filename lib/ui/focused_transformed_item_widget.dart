import 'package:flutter/material.dart';
import 'package:stacked_animated_list/utils/animated_stack_list_mixin.dart';
import 'package:stacked_animated_list/utils/item_position_type.dart';

class FocusedTransformedItemWidget extends StatelessWidget
    with AnimatedStackListMixin {
  final Widget child;
  final Animation animation;
  final double rotationAngle;
  final double horizontalOffset;
  final ItemPositionType positionType;

  const FocusedTransformedItemWidget({
    required this.child,
    required this.animation,
    required this.rotationAngle,
    required this.horizontalOffset,
    required this.positionType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 드래그 방향에 따라 multiplier 결정
    // 왼쪽으로 드래그하면 왼쪽 아이템이 중앙으로 오므로 multiplier = 1
    // 오른쪽으로 드래그하면 오른쪽 아이템이 중앙으로 오므로 multiplier = -1
    final multiplier = (positionType == ItemPositionType.left ? 1 : -1);

    return Transform.rotate(
      angle: multiplier *
          getRotationAngleInRadiansForFocusedItem(
            rotationAngle,
            animation,
          ),
      child: Transform.translate(
        offset: getOffsetForFocusedItem(
          horizontalOffset,
          animation,
          multiplier,
        ),
        child: child,
      ),
    );
  }
}
