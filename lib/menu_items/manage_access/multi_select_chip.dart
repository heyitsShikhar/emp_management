import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedItems;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectChip({
    Key? key,
    required this.items,
    required this.onSelectionChanged,
    this.initialSelectedItems = const [],
  }) : super(key: key);

  @override
  MultiSelectChipState createState() => MultiSelectChipState();
}

class MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: widget.items.map((item) {
        return FilterChip(
          label: Text(item),
          selected: selectedItems.contains(item),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedItems.add(item);
              } else {
                selectedItems.remove(item);
              }
              widget.onSelectionChanged(selectedItems);
            });
          },
        );
      }).toList(),
    );
  }
}
