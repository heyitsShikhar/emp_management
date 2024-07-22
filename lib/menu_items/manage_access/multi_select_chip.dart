import 'package:flutter/material.dart';

class MultiSelectChip<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialSelectedItems;
  final String Function(T) itemLabelBuilder;
  final void Function(List<T>) onSelectionChanged;

  const MultiSelectChip({
    super.key,
    required this.items,
    required this.itemLabelBuilder,
    this.initialSelectedItems = const [],
    required this.onSelectionChanged,
  });

  @override
  MultiSelectChipState<T> createState() => MultiSelectChipState<T>();
}

class MultiSelectChipState<T> extends State<MultiSelectChip<T>> {
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.initialSelectedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: widget.items.map((item) {
        final isSelected = _selectedItems.contains(item);
        return ChoiceChip(
          label: Text(widget.itemLabelBuilder(item)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedItems.add(item);
              } else {
                _selectedItems.remove(item);
              }
              widget.onSelectionChanged(_selectedItems);
            });
          },
        );
      }).toList(),
    );
  }
}
