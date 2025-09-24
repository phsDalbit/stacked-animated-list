import 'dart:math';

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

  // center 노드 기준으로 현재 노드의 위치 계산 (최단 거리 기준)
  ItemPositionType getPositionType(CircularLinkedListNode centerNode) {
    if (this == centerNode) {
      return ItemPositionType.center;
    }

    int rightDistance = 0;
    CircularLinkedListNode? current = centerNode;
    do {
      current = current?.next;
      rightDistance++;
      if (current == this) {
        break;
      }
    } while (current != centerNode && rightDistance <= 100);

    int leftDistance = 0;
    current = centerNode;
    do {
      current = current?.previous;
      leftDistance++;
      if (current == this) {
        break;
      }
    } while (current != centerNode && leftDistance <= 100);

    // If the list is even, there can be a tie. Arbitrarily choose one side.
    if (rightDistance <= leftDistance) {
      return ItemPositionType.left;
    } else {
      return ItemPositionType.right;
    }
  }

  // center 노드 기준으로 다음 아이템의 위치 타입 계산
  ItemPositionType getPositionTypeForNextItem(
      CircularLinkedListNode centerNode) {
    return getPositionType(centerNode).reverse;
  }

  // 다른 노드와의 최단 거리를 계산하는 헬퍼 메서드
  int getDistance(CircularLinkedListNode centerNode) {
    if (this == centerNode) return 0;

    int rightDistance = 0;
    CircularLinkedListNode? current = centerNode;
    do {
      current = current?.next;
      rightDistance++;
      if (current == this) {
        break;
      }
    } while (current != centerNode && rightDistance <= 100);

    int leftDistance = 0;
    current = centerNode;
    do {
      current = current?.previous;
      leftDistance++;
      if (current == this) {
        break;
      }
    } while (current != centerNode && leftDistance <= 100);

    return min(rightDistance, leftDistance);
  }
}
