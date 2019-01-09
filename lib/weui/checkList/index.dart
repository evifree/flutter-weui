import 'package:flutter/material.dart';
import '../form/index.dart';
import '../cell/index.dart';
import '../theme.dart';
import '../utils.dart';

// onChane
typedef OnChangeBack = void Function(List<dynamic> value);

// icon size
final double _iconSize = 22.0;

class WeChecklist extends StatefulWidget {
  // 选项
  List<Map<String, Object>> options;
  // value
  List<dynamic> value;
  // 默认选中
  List<dynamic> defaultValue;
  // 排列方式
  String align;
  // onChange
  OnChangeBack onChange;
  // max
  int max;
  // icon padding间距
  final double padding = 8.0;
  // left padding
  double _leftPadding;
  // right padding
  double _rightPadding;

  WeChecklist({
    @required this.options,
    value,
    this.defaultValue,
    this.align = 'left',
    this.onChange,
    max
  }) {
    if (align == 'left') {
      _leftPadding = 0.0;
      _rightPadding = padding;
    } else {
      _leftPadding = padding;
      _rightPadding = 0.0;
    }

    if (value != null) {
      this.value = [];
      this.value.addAll(value);
    }

    // 最多选择
    this.max = max is int ? max : options.length; 
  }

  @override
  _ChecklistState createState() => _ChecklistState();
}

class _ChecklistState extends State<WeChecklist> {
  List<dynamic> checkedList = [];

  @override
  void initState() {
    super.initState();
    this.checkedList = widget.defaultValue == null ? [] : widget.defaultValue;
  }

  List<dynamic> getCheckedValue() {
    return widget.value == null ? checkedList : widget.value;
  }

  // change
  void change(item) {
    final value = item['value'];
    List<dynamic> checkedList = getCheckedValue();
    // 禁用
    if (isTrue(item['disabled'])) return;
    // 判断是否选中
    if (checkedList.indexOf(value) >= 0) {
      checkedList.remove(value);
    } else {
      // 限制最大选择
      if (checkedList.length == widget.max) return;
      checkedList.add(value);
    }
    // 更新
    if (widget.value == null) {
      setState(() {});
    }
    // 调用change
    if (widget.onChange is Function) {
      widget.onChange(checkedList);
    }
  }

  Widget renderIcon(item) {
    List<dynamic> checkedList = getCheckedValue();
    // 是否选中
    final bool isChecked = checkedList.indexOf(item['value']) >= 0;
    // 配置了禁用或者达到限制
    final bool isDisabled = isTrue(item['disabled']) || (checkedList.length == widget.max && !isChecked);
    final Color color = Color(0xffc9c9c9);
    Color borderColor;
    Color bgColor;

    // 判断是否禁用
    if (isDisabled) {
      borderColor = bgColor = color;
    } else if (isChecked) {
      borderColor = bgColor = primary;
    } else {
      borderColor = Color(0xffc9c9c9);
      bgColor = Colors.transparent;
    }

    return Container(
      width: _iconSize,
      height: _iconSize,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1, color: borderColor),
        borderRadius: BorderRadius.all(Radius.circular(_iconSize))
      ),
      child: isChecked ? Align(
        alignment: Alignment.center,
        child: Icon(
          IconData(0xe631, fontFamily: 'iconfont'),
          color: Colors.white,
          size: 16
        )
      ) : null
    );
  }

  List<WeCell> renderList() {
    final List<WeCell> list = [];

    widget.options.forEach((item) {
      List<Widget> children;
      // 图标
      final icon = Padding(
        padding: EdgeInsets.only(left: widget._leftPadding, right: widget._rightPadding),
        child: renderIcon(item)
      );
      // 内容
      final content = Expanded(
        flex: 1,
        child: Container(
          child: Opacity(
            opacity: isTrue(item['disabled']) ? 0.65 : 1.0,
            child: toTextWidget(item['label'], 'label')
          )
        )
      );

      // 排列方式
      if (widget.align == 'left') {
        children = [icon, content];
      } else {
        children = [content, icon];
      }

      list.add(
        WeCell(
          content: Row(
            children: children
          ),
          click: () {
            change(item);
          }
        )
      );
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final formContext = WeForm.of(context);

    // 判断是否有form包裹
    return WeCells(
      boxBorder: formContext == null,
      children: renderList()
    );
  }
}