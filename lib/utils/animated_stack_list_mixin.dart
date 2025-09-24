import 'package:flutter/material.dart';
import 'package:stacked_animated_list/models/stacked_item.dart';
import 'package:stacked_animated_list/utils/item_position_type.dart';

mixin AnimatedStackListMixin {
  List<BoxShadow> defaultFocusedItemShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.26),
        blurRadius: 28,
        spreadRadius: 8,
        offset: const Offset(8, 16),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.26),
        blurRadius: 28,
        spreadRadius: 8,
        offset: const Offset(-8, 2),
      ),
    ];
  }

  bool isItemFlicked(DraggableDetails details) {
    return details.velocity.pixelsPerSecond.dx.abs() > 500 ||
        details.velocity.pixelsPerSecond.dy.abs() > 500;
  }

  double getRotationAngleInRadiansForFocusedItem(
    double rotationAngle,
    Animation animation,
  ) {
    return rotationAngle * 3.14 / 180 * (1 - animation.value);
  }

  double getRotationAngleInRadians(double rotationAngle, Animation animation) {
    return rotationAngle * 3.14 / 180 * animation.value;
  }

  Offset getOffsetForFocusedItem(
    double horizontalOffset,
    Animation animation,
    int multiplier,
  ) {
    return Offset(multiplier * horizontalOffset * (1 - animation.value), 0);
  }

  Offset getOffsetForUnfocusedItem(
    double horizontalOffset,
    Animation animation,
    int multiplier,
  ) {
    return Offset(multiplier * horizontalOffset * animation.value, 0);
  }

  List<StackedItem> generateStackedItems(List<Widget> listItems) {
    List<StackedItem> stackedItems = [];
    for (int index = 0; index < listItems.length; index++) {
      final positionType = index == 0
          ? ItemPositionType.center
          : index % 2 == 0
              ? ItemPositionType.left
              : ItemPositionType.right;

      final positionTypeForNextItem = positionType.reverse;

      stackedItems.add(
        StackedItem(
          positionType: positionType,
          positionTypeForNextItem: positionTypeForNextItem,
          widget: listItems[index],
          baseIndex: index,
        ),
      );
    }
    return stackedItems;
  }

  double getListItemHorizontalOffset(
    BuildContext context,
    double widgetWidth,
    double additionalTranslateOffsetBeyondScreen,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenWidthHalf = screenWidth / 2;
    final widgetWidthHalf = widgetWidth / 2;
    final translateX = (widgetWidthHalf > screenWidthHalf
            ? additionalTranslateOffsetBeyondScreen
            : additionalTranslateOffsetBeyondScreen +
                (screenWidthHalf - widgetWidthHalf))
        .toDouble();
    return translateX;
  }

  List<StackedItem> refreshedStackedItems(
      List<StackedItem> stackedItems, bool isDraggingLeft) {
    final removedItem = stackedItems[0];

    // 드래그 방향에 따라 다음에 중앙으로 올 아이템 결정
    StackedItem nextCenterItem;
    if (isDraggingLeft) {
      // 왼쪽으로 드래그하면 왼쪽 아이템이 중앙으로 옴
      nextCenterItem = stackedItems.firstWhere(
        (item) => item.positionType == ItemPositionType.left,
        orElse: () => stackedItems[1], // fallback
      );
    } else {
      // 오른쪽으로 드래그하면 오른쪽 아이템이 중앙으로 옴
      nextCenterItem = stackedItems.firstWhere(
        (item) => item.positionType == ItemPositionType.right,
        orElse: () => stackedItems[1], // fallback
      );
    }

    // 제거된 아이템의 새로운 위치 설정
    final lastItem = stackedItems[stackedItems.length - 1];
    switch (lastItem.positionType) {
      case ItemPositionType.left:
        removedItem.positionType = ItemPositionType.right;
        break;
      case ItemPositionType.center:
      case ItemPositionType.right:
        removedItem.positionType = ItemPositionType.left;
    }
    removedItem.positionTypeForNextItem = removedItem.positionType.reverse;

    // 아이템 순서 재배치
    stackedItems.remove(removedItem);
    stackedItems.insert(stackedItems.length, removedItem);

    // 다음 중앙 아이템을 맨 앞으로 이동
    stackedItems.remove(nextCenterItem);
    stackedItems.insert(0, nextCenterItem);
    nextCenterItem.positionType = ItemPositionType.center;

    return _refreshPositionTypeOfStackedItems(stackedItems);
  }

  List<StackedItem> _refreshPositionTypeOfStackedItems(
    List<StackedItem> stackedItems,
  ) {
    List<StackedItem> refreshItems = [];
    for (int index = 0; index < stackedItems.length; index++) {
      final item = stackedItems[index];

      if (index == 0) {
        refreshItems.add(item);
      } else {
        final newPositionType = item.positionType.reverse;
        final newNextPositionType = item.positionTypeForNextItem.reverse;

        stackedItems[index].positionType = newPositionType;
        stackedItems[index].positionTypeForNextItem = newNextPositionType;
        refreshItems.add(item);
      }
    }

    return refreshItems;
  }
}
