import 'package:flutter/material.dart';
import 'package:skillswap_app/theme/app_theme.dart';

class ChipSelector extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;
  final bool multiSelect;
  final int itemsPerRow;

  const ChipSelector({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.multiSelect = true,
    this.itemsPerRow = 3,
  });

  @override
  State<ChipSelector> createState() => _ChipSelectorState();
}

class _ChipSelectorState extends State<ChipSelector> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  void _toggleItem(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        if (!widget.multiSelect && _selectedItems.isNotEmpty) {
          _selectedItems.clear();
        }
        _selectedItems.add(item);
      }
    });
    widget.onChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.itemsPerRow,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = _selectedItems.contains(item);

        return GestureDetector(
          onTap: () => _toggleItem(item),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentLight : Color(0xFFFAF8F5),
              border: Border.all(
                color: isSelected ? AppColors.accent : Color(0xFFEDE9E3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.accent,
                    size: 20,
                  )
                else
                  SizedBox(height: 20),
                SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
