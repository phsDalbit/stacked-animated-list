import 'package:flutter/material.dart';
import 'package:stacked_animated_list/models/circular_linked_list_node.dart';
import 'package:stacked_animated_list/utils/item_position_type.dart';

class CircularLinkedListManager {
  CircularLinkedListNode? _head;
  CircularLinkedListNode? _centerNode;

  // 리스트 생성
  void createFromWidgets(List<Widget> widgets) {
    if (widgets.isEmpty) {
      _head = null;
      _centerNode = null;
      return;
    }

    // 첫 번째 노드 생성 (중앙 노드)
    _head = CircularLinkedListNode(
      widget: widgets[0],
      baseIndex: 0,
      positionType: ItemPositionType.center,
      positionTypeForNextItem: ItemPositionType.left,
    );

    _centerNode = _head;

    // 나머지 노드들 생성 및 연결
    CircularLinkedListNode? current = _head;
    for (int i = 1; i < widgets.length; i++) {
      final newNode = CircularLinkedListNode(
        widget: widgets[i],
        baseIndex: i,
        positionType:
            i % 2 == 0 ? ItemPositionType.left : ItemPositionType.right,
        positionTypeForNextItem:
            (i % 2 == 0 ? ItemPositionType.left : ItemPositionType.right)
                .reverse,
      );

      // 양방향 연결
      current!.next = newNode;
      newNode.previous = current;
      current = newNode;
    }

    // 마지막 노드를 첫 번째 노드와 연결 (circular)
    current!.next = _head;
    _head!.previous = current;

    // 모든 위치 재계산
    _centerNode!.refreshAllPositions();
  }

  // 현재 중앙 노드 반환
  CircularLinkedListNode? get centerNode => _centerNode;

  // 리스트가 비어있는지 확인
  bool get isEmpty => _head == null;

  // 리스트 크기 반환
  int get length => _head?.length ?? 0;

  // 모든 노드를 순서대로 반환
  List<CircularLinkedListNode> getAllNodes() {
    if (_head == null) return [];
    return _head!.toList();
  }

  // 드래그 방향에 따라 중앙 노드 변경
  void rotateCenter(bool isDraggingLeft) {
    if (_centerNode == null) return;

    ItemPositionType targetPosition;
    if (isDraggingLeft) {
      targetPosition = ItemPositionType.left;
    } else {
      targetPosition = ItemPositionType.right;
    }

    // 목표 위치의 노드 찾기
    final targetNode = _centerNode!.findNodeByPosition(targetPosition);
    if (targetNode != null) {
      _centerNode = targetNode;
      _centerNode!.refreshAllPositions();
    }
  }

  // 특정 인덱스의 노드 찾기
  CircularLinkedListNode? findNodeByIndex(int index) {
    if (_head == null) return null;

    CircularLinkedListNode current = _head!;
    do {
      if (current.baseIndex == index) {
        return current;
      }
      current = current.next!;
    } while (current != _head);

    return null;
  }

  // 중앙 노드를 특정 인덱스로 설정
  void setCenterByIndex(int index) {
    final node = findNodeByIndex(index);
    if (node != null) {
      _centerNode = node;
      _centerNode!.refreshAllPositions();
    }
  }

  // 리스트 초기화
  void clear() {
    _head = null;
    _centerNode = null;
  }

  // 디버깅용: 리스트 상태 출력
  void debugPrint() {
    if (_head == null) {
      print('List is empty');
      return;
    }

    print('Circular List State:');
    CircularLinkedListNode current = _head!;
    int index = 0;

    do {
      final isCenter = current == _centerNode;
      print(
          '[$index] BaseIndex: ${current.baseIndex}, Position: ${current.positionType}, IsCenter: $isCenter');
      current = current.next!;
      index++;
    } while (current != _head);
  }
}
