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

    // center 노드에서 현재 노드까지의 거리 계산
    int distance = 0;
    CircularLinkedListNode current = centerNode;

    // 오른쪽으로 검색
    while (current != this && distance < 10) {
      // 무한 루프 방지
      current = current.next!;
      distance++;
    }

    if (current == this) {
      return distance % 2 == 1 ? ItemPositionType.right : ItemPositionType.left;
    }

    // 왼쪽으로 검색
    distance = 0;
    current = centerNode;
    while (current != this && distance < 10) {
      current = current.previous!;
      distance++;
    }

    return distance % 2 == 1 ? ItemPositionType.left : ItemPositionType.right;
  }

  // center 노드 기준으로 다음 아이템의 위치 타입 계산
  ItemPositionType getPositionTypeForNextItem(
      CircularLinkedListNode centerNode) {
    return getPositionType(centerNode).reverse;
  }
}
