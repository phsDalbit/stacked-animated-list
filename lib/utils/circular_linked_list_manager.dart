import 'package:flutter/material.dart';
import 'package:stacked_animated_list/models/circular_linked_list_node.dart';

class CircularLinkedListManager {
  CircularLinkedListNode? _centerNode;

  // 리스트 생성
  void createFromWidgets(List<Widget> widgets) {
    if (widgets.isEmpty) {
      _centerNode = null;
      return;
    }

    // 첫 번째 노드 생성 (중앙 노드)
    _centerNode = CircularLinkedListNode(
      widget: widgets[0],
      baseIndex: 0,
    );

    // 나머지 노드들 생성 및 연결
    CircularLinkedListNode? current = _centerNode;
    for (int i = 1; i < widgets.length; i++) {
      final newNode = CircularLinkedListNode(
        widget: widgets[i],
        baseIndex: i,
      );

      // 양방향 연결
      current!.next = newNode;
      newNode.previous = current;
      current = newNode;
    }

    // 마지막 노드를 첫 번째 노드와 연결 (circular)
    current!.next = _centerNode;
    _centerNode!.previous = current;
  }

  // 현재 중앙 노드 반환
  CircularLinkedListNode? get centerNode => _centerNode;

  // 왼쪽 노드 반환 (center.previous)
  CircularLinkedListNode? get leftNode => _centerNode?.previous;

  // 오른쪽 노드 반환 (center.next)
  CircularLinkedListNode? get rightNode => _centerNode?.next;

  // 리스트가 비어있는지 확인
  bool get isEmpty => _centerNode == null;

  // 리스트 크기 반환
  int get length {
    if (_centerNode == null) return 0;

    int count = 0;
    CircularLinkedListNode current = _centerNode!;

    do {
      count++;
      current = current.next!;
    } while (current != _centerNode);

    return count;
  }

  // 모든 노드를 순서대로 반환 (center부터 시작)
  List<CircularLinkedListNode> getAllNodes() {
    if (_centerNode == null) return [];

    List<CircularLinkedListNode> nodes = [];
    CircularLinkedListNode current = _centerNode!;

    do {
      nodes.add(current);
      current = current.next!;
    } while (current != _centerNode);

    return nodes;
  }

  // 드래그 방향에 따라 중앙 노드 변경
  void rotateCenter(bool isDraggingLeft) {
    if (_centerNode == null) return;

    if (isDraggingLeft) {
      // 왼쪽으로 드래그하면 오른쪽 노드가 새로운 center가 됨 (요청사항 반영)
      _centerNode = _centerNode!.next;
    } else {
      // 오른쪽으로 드래그하면 왼쪽 노드가 새로운 center가 됨 (요청사항 반영)
      _centerNode = _centerNode!.previous;
    }
  }

  // 특정 인덱스의 노드 찾기
  CircularLinkedListNode? findNodeByIndex(int index) {
    if (_centerNode == null) return null;

    CircularLinkedListNode current = _centerNode!;
    do {
      if (current.baseIndex == index) {
        return current;
      }
      current = current.next!;
    } while (current != _centerNode);

    return null;
  }

  // 중앙 노드를 특정 인덱스로 설정
  void setCenterByIndex(int index) {
    final node = findNodeByIndex(index);
    if (node != null) {
      _centerNode = node;
    }
  }

  // 리스트 초기화
  void clear() {
    _centerNode = null;
  }
}
