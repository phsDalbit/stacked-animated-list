import 'package:flutter/material.dart';
import 'package:stacked_animated_list/models/stacked_item.dart';
import 'package:stacked_animated_list/utils/circular_linked_list_manager.dart';
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

  // 기존 메서드 (하위 호환성을 위해 유지)
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

  // 새로운 circular linked list 기반 메서드
  CircularLinkedListManager createCircularLinkedList(List<Widget> listItems) {
    final manager = CircularLinkedListManager();
    manager.createFromWidgets(listItems);
    return manager;
  }

  // CircularLinkedListNode를 StackedItem으로 변환 (기존 코드와의 호환성)
  List<StackedItem> convertCircularListToStackedItems(
      CircularLinkedListManager manager) {
    final nodes = manager.getAllNodes();
    final centerNode = manager.centerNode;

    if (centerNode == null) return [];

    return nodes
        .map((node) => StackedItem(
              positionType: node.getPositionType(centerNode),
              positionTypeForNextItem:
                  node.getPositionTypeForNextItem(centerNode),
              widget: node.widget,
              baseIndex: node.baseIndex,
            ))
        .toList();
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

  // 기존 메서드 (하위 호환성을 위해 유지)
  List<StackedItem> refreshedStackedItems(
      List<StackedItem> stackedItems, bool isDraggingLeft) {
    // 현재 중앙 아이템을 제거
    final removedItem = stackedItems.removeAt(0);

    // 드래그 방향에 따라 다음에 중앙으로 올 아이템 결정
    StackedItem nextCenterItem;

    if (isDraggingLeft) {
      // 왼쪽으로 드래그하면 왼쪽 아이템이 중앙으로 옴
      // 스택에서 가장 앞에 있는 왼쪽 아이템을 찾음
      nextCenterItem = stackedItems.firstWhere(
        (item) => item.positionType == ItemPositionType.left,
        orElse: () => stackedItems[0], // fallback
      );
    } else {
      // 오른쪽으로 드래그하면 오른쪽 아이템이 중앙으로 옴
      // 스택에서 가장 앞에 있는 오른쪽 아이템을 찾음
      nextCenterItem = stackedItems.firstWhere(
        (item) => item.positionType == ItemPositionType.right,
        orElse: () => stackedItems[0], // fallback
      );
    }

    // 다음 중앙 아이템을 맨 앞으로 이동
    stackedItems.remove(nextCenterItem);
    stackedItems.insert(0, nextCenterItem);

    // 제거된 아이템을 맨 뒤에 추가하고 위치 설정
    final lastItem = stackedItems[stackedItems.length - 1];
    removedItem.positionType = lastItem.positionType == ItemPositionType.left
        ? ItemPositionType.right
        : ItemPositionType.left;
    removedItem.positionTypeForNextItem = removedItem.positionType.reverse;
    stackedItems.add(removedItem);

    // 모든 아이템의 위치를 올바르게 재설정
    return _refreshPositionTypeOfStackedItems(stackedItems);
  }

  // 새로운 circular linked list 기반 메서드 - 훨씬 간단!
  void rotateCircularList(
      CircularLinkedListManager manager, bool isDraggingLeft) {
    manager.rotateCenter(isDraggingLeft);
  }

  List<StackedItem> _refreshPositionTypeOfStackedItems(
    List<StackedItem> stackedItems,
  ) {
    // 첫 번째 아이템은 항상 중앙
    if (stackedItems.isNotEmpty) {
      stackedItems[0].positionType = ItemPositionType.center;
      stackedItems[0].positionTypeForNextItem = ItemPositionType.left; // 기본값
    }

    // 나머지 아이템들의 위치를 순차적으로 설정
    for (int index = 1; index < stackedItems.length; index++) {
      final item = stackedItems[index];

      // 이전 아이템의 위치에 따라 현재 아이템의 위치 결정
      final previousItem = stackedItems[index - 1];
      if (previousItem.positionType == ItemPositionType.center) {
        // 중앙 다음은 왼쪽
        item.positionType = ItemPositionType.left;
      } else if (previousItem.positionType == ItemPositionType.left) {
        // 왼쪽 다음은 오른쪽
        item.positionType = ItemPositionType.right;
      } else {
        // 오른쪽 다음은 왼쪽
        item.positionType = ItemPositionType.left;
      }

      // positionTypeForNextItem 설정
      item.positionTypeForNextItem = item.positionType.reverse;
    }

    return stackedItems;
  }
}
