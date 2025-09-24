import 'package:flutter/material.dart';
import 'package:stacked_animated_list/models/stacked_item.dart';
import 'package:stacked_animated_list/ui/focused_transformed_item_widget.dart';
import 'package:stacked_animated_list/ui/unfocused_transformed_item_widget.dart';
import 'package:stacked_animated_list/utils/animated_stack_list_mixin.dart';
import 'package:stacked_animated_list/utils/item_position_type.dart';

class TransformedListItemWidget extends StatefulWidget
    with AnimatedStackListMixin {
  final void Function(int index)? onCenterCardClick;
  final StackedItem stackedItem;
  final double widgetWidth;
  final bool focusedWidget;
  final Function(bool isDraggingLeft) onDragEnded;
  final Animation animation;
  final BorderRadiusGeometry? borderRadius;
  final double rotationAngle;
  final double additionalTranslateOffsetBeyondScreen;
  final List<BoxShadow>? focusedItemShadow;
  final int longPressDelay;

  const TransformedListItemWidget({
    super.key,
    required this.stackedItem,
    required this.widgetWidth,
    required this.focusedWidget,
    required this.onDragEnded,
    required this.animation,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    required this.rotationAngle,
    required this.additionalTranslateOffsetBeyondScreen,
    this.focusedItemShadow,
    this.onCenterCardClick,
    required this.longPressDelay,
  });

  @override
  State<TransformedListItemWidget> createState() =>
      _TransformedListItemWidgetState();
}

class _TransformedListItemWidgetState extends State<TransformedListItemWidget>
    with AnimatedStackListMixin {
  bool _isDraggingLeft = false;

  @override
  Widget build(BuildContext context) {
    final horizontalOffset = getListItemHorizontalOffset(
      context,
      widget.widgetWidth,
      widget.additionalTranslateOffsetBeyondScreen,
    );

    if (widget.focusedWidget) {
      final childWidget = GestureDetector(
        onTap: () {
          if (widget.onCenterCardClick != null) {
            widget.onCenterCardClick!(widget.stackedItem.baseIndex);
          }
        },
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              boxShadow: widget.focusedItemShadow ?? defaultFocusedItemShadow(),
              borderRadius: widget.borderRadius,
            ),
            child: widget.stackedItem.widget,
          ),
        ),
      );

      // 드래그 방향에 따라 애니메이션 방향 결정
      final animatedFromPosType =
          _isDraggingLeft ? ItemPositionType.left : ItemPositionType.right;

      return AnimatedBuilder(
        animation: widget.animation,
        child: LongPressDraggable(
          feedback: childWidget,
          childWhenDragging: const SizedBox.shrink(),
          delay: Duration(milliseconds: widget.longPressDelay),
          child: childWidget,
          onDragStarted: () {
            // 드래그 시작 시 방향 감지
            setState(() {
              _isDraggingLeft = false; // 기본값
            });
          },
          onDragUpdate: (details) {
            // 드래그 중 방향 감지
            setState(() {
              _isDraggingLeft = details.delta.dx < 0;
            });
          },
          onDragEnd: (details) {
            if (isItemFlicked(details)) {
              // 드래그 방향에 따라 최종 방향 결정
              final finalDragDirection =
                  details.velocity.pixelsPerSecond.dx < 0;
              setState(() {
                _isDraggingLeft = finalDragDirection;
              });
              widget.onDragEnded(finalDragDirection);
            }
          },
        ),
        builder: (_, child) {
          return FocusedTransformedItemWidget(
            animation: widget.animation,
            rotationAngle: widget.rotationAngle,
            horizontalOffset: horizontalOffset,
            positionType: animatedFromPosType,
            child: child!,
          );
        },
      );
    }

    return UnfocusedTransformedItemWidget(
      stackedItem: widget.stackedItem,
      animation: widget.animation,
      rotationAngle: widget.rotationAngle,
      horizontalOffset: horizontalOffset,
      borderRadius: widget.borderRadius,
      positionType: widget.stackedItem.positionType,
    );
  }
}
