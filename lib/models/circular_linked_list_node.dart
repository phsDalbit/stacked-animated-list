import 'package:flutter/material.dart';
import 'package:stacked_animated_list/utils/item_position_type.dart';

class CircularLinkedListNode {
  final Widget widget;
  final int baseIndex;

  CircularLinkedListNode? next;
  CircularLinkedListNode? previous;

  CircularLinkedListNode({
    required this.widget,
    required this.baseIndex,
  });

  // center 노드 기준으로 현재 노드의 위치 계산
  ItemPositionType getPositionType(CircularLinkedListNode centerNode) {
    if (this == centerNode) {
      return ItemPositionType.center;
    }

    // center 노드의 이전 노드인지 확인 (left)
    if (this == centerNode.previous) {
      return ItemPositionType.left;
    }

    // center 노드의 다음 노드인지 확인 (right)
    if (this == centerNode.next) {
      return ItemPositionType.right;
    }

    // 그 외의 경우는 center에서 더 멀리 떨어진 노드들
    // center에서 오른쪽으로 몇 번째인지 확인
    int rightDistance = 0;
    CircularLinkedListNode current = centerNode;

    while (current != this && rightDistance < 10) {
      // 무한 루프 방지
      current = current.next!;
      rightDistance++;
    }

    if (current == this) {
      // 오른쪽에 있는 노드들: distance가 홀수면 right, 짝수면 left
      return rightDistance % 2 == 1
          ? ItemPositionType.right
          : ItemPositionType.left;
    }

    // center에서 왼쪽으로 몇 번째인지 확인
    int leftDistance = 0;
    current = centerNode;

    while (current != this && leftDistance < 10) {
      current = current.previous!;
      leftDistance++;
    }

    if (current == this) {
      // 왼쪽에 있는 노드들: distance가 홀수면 left, 짝수면 right
      return leftDistance % 2 == 1
          ? ItemPositionType.left
          : ItemPositionType.right;
    }

    // 기본값 (이론적으로 도달하지 않아야 함)
    return ItemPositionType.left;
  }

  // center 노드 기준으로 다음 아이템의 위치 타입 계산
  ItemPositionType getPositionTypeForNextItem(
      CircularLinkedListNode centerNode) {
    return getPositionType(centerNode).reverse;
  }
}
