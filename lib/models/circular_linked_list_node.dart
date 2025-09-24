import 'package:flutter/material.dart';
import 'package:stacked_animated_list/utils/item_position_type.dart';

class CircularLinkedListNode {
  final Widget widget;
  final int baseIndex;
  ItemPositionType positionType;
  ItemPositionType positionTypeForNextItem;

  CircularLinkedListNode? next;
  CircularLinkedListNode? previous;

  CircularLinkedListNode({
    required this.widget,
    required this.baseIndex,
    required this.positionType,
    required this.positionTypeForNextItem,
  });

  // 현재 노드가 중앙 노드인지 확인
  bool get isCenter => positionType == ItemPositionType.center;

  // 다음 노드로 이동
  CircularLinkedListNode moveNext() {
    return next!;
  }

  // 이전 노드로 이동
  CircularLinkedListNode movePrevious() {
    return previous!;
  }

  // 특정 방향의 노드 찾기 (left 또는 right)
  CircularLinkedListNode? findNodeByPosition(ItemPositionType position) {
    CircularLinkedListNode current = this;

    // 최대 한 바퀴만 검색 (무한 루프 방지)
    int maxIterations = 10; // 충분한 크기로 설정
    int iterations = 0;

    while (iterations < maxIterations) {
      if (current.positionType == position) {
        return current;
      }
      current = current.next!;
      iterations++;
    }

    return null;
  }

  // 모든 노드의 위치를 재계산
  void refreshAllPositions() {
    CircularLinkedListNode current = this;
    int index = 0;

    do {
      if (index == 0) {
        // 첫 번째 노드는 항상 중앙
        current.positionType = ItemPositionType.center;
        current.positionTypeForNextItem = ItemPositionType.left;
      } else {
        // 이전 노드의 위치에 따라 현재 노드의 위치 결정
        final previousNode = current.previous!;
        if (previousNode.positionType == ItemPositionType.center) {
          current.positionType = ItemPositionType.left;
        } else if (previousNode.positionType == ItemPositionType.left) {
          current.positionType = ItemPositionType.right;
        } else {
          current.positionType = ItemPositionType.left;
        }
        current.positionTypeForNextItem = current.positionType.reverse;
      }

      current = current.next!;
      index++;
    } while (current != this);
  }

  // 리스트의 모든 노드를 순서대로 반환
  List<CircularLinkedListNode> toList() {
    List<CircularLinkedListNode> nodes = [];
    CircularLinkedListNode current = this;

    do {
      nodes.add(current);
      current = current.next!;
    } while (current != this);

    return nodes;
  }

  // 리스트의 크기 반환
  int get length {
    int count = 0;
    CircularLinkedListNode current = this;

    do {
      count++;
      current = current.next!;
    } while (current != this);

    return count;
  }
}
