library stacked_animated_list;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:stacked_animated_list/models/circular_linked_list_node.dart';
import 'package:stacked_animated_list/models/stacked_item.dart';
import 'package:stacked_animated_list/ui/transformed_list_item_widget.dart';
import 'package:stacked_animated_list/utils/animated_stack_list_mixin.dart';
import 'package:stacked_animated_list/utils/circular_linked_list_manager.dart';

class StackedListWidget extends StatefulWidget {
  final List<Widget> listItems;
  final double listItemWidth;
  final Duration animationDuration;
  final BorderRadiusGeometry? borderRadius;
  final double rotationAngle;
  final double additionalTranslateOffsetBeyondScreen;
  final List<BoxShadow>? focusedItemShadow;
  final void Function(int index)? onCenterCardClick;
  final void Function(int index)? onFocusedItemChanged;
  final int longPressDelay;

  const StackedListWidget({
    required this.listItems,
    required this.listItemWidth,
    this.animationDuration = const Duration(milliseconds: 350),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.rotationAngle = 15,
    this.additionalTranslateOffsetBeyondScreen = 0,
    this.focusedItemShadow,
    this.onCenterCardClick,
    this.onFocusedItemChanged,
    this.longPressDelay = 400,
    super.key,
  });

  @override
  State<StackedListWidget> createState() => _StackedListWidgetState();
}

class _StackedListWidgetState extends State<StackedListWidget>
    with SingleTickerProviderStateMixin, AnimatedStackListMixin {
  late CircularLinkedListManager _listManager;
  AnimationController? _animationCtr;
  Animation? _increaseAnim;
  int _currentFocusedIndex = 0;

  @override
  void initState() {
    _animationCtr = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _increaseAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationCtr!, curve: Curves.easeOut));

    // Circular linked list 생성
    _listManager = createCircularLinkedList(widget.listItems);

    // 초기 focused item 설정
    _currentFocusedIndex = _listManager.centerNode?.baseIndex ?? 0;

    _animationCtr?.forward(from: 0);

    super.initState();

    // 첫 번째 프레임 후에 초기 focused item 콜백 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFocusedItemChanged?.call(_currentFocusedIndex);
    });
  }

  @override
  void dispose() {
    _animationCtr?.dispose();
    _listManager.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _listManager.getAllNodes();

    return Stack(
      children: nodes
          .mapIndexed(
            (index, node) {
              final isFirstItem = index == 0;

              return Center(
                child: TransformedListItemWidget(
                  stackedItem: _convertNodeToStackedItem(node),
                  animation: _increaseAnim!,
                  widgetWidth: widget.listItemWidth,
                  focusedWidget: isFirstItem,
                  borderRadius: widget.borderRadius,
                  rotationAngle: widget.rotationAngle,
                  additionalTranslateOffsetBeyondScreen:
                      widget.additionalTranslateOffsetBeyondScreen,
                  focusedItemShadow: widget.focusedItemShadow,
                  onCenterCardClick: widget.onCenterCardClick,
                  longPressDelay: widget.longPressDelay,
                  onDragEnded: (bool isDraggingLeft) {
                    // Circular linked list 회전 - 훨씬 간단!
                    rotateCircularList(_listManager, isDraggingLeft);

                    // 새로운 focused item의 인덱스 업데이트
                    final newFocusedIndex =
                        _listManager.centerNode?.baseIndex ?? 0;

                    // focused item이 변경되었는지 확인하고 콜백 호출
                    if (newFocusedIndex != _currentFocusedIndex) {
                      _currentFocusedIndex = newFocusedIndex;
                      widget.onFocusedItemChanged?.call(_currentFocusedIndex);
                    }

                    _animationCtr?.forward(from: 0);
                    setState(() {});
                  },
                ),
              );
            },
          )
          .toList()
          .reversed
          .toList(),
    );
  }

  // CircularLinkedListNode를 StackedItem으로 변환 (기존 TransformedListItemWidget과의 호환성)
  StackedItem _convertNodeToStackedItem(CircularLinkedListNode node) {
    final centerNode = _listManager.centerNode;
    if (centerNode == null) {
      throw StateError('Center node is null');
    }

    return StackedItem(
      positionType: node.getPositionType(centerNode),
      positionTypeForNextItem: node.getPositionTypeForNextItem(centerNode),
      widget: node.widget,
      baseIndex: node.baseIndex,
    );
  }
}
