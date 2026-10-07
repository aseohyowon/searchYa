import 'package:flutter/material.dart';

/// Search field at the top of the home screen. Submits on keyboard action.
class StoreSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  const StoreSearchBar(
      {super.key, required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: '매장 이름을 검색하세요',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              tooltip: '지우기',
              onPressed: () {
                controller.clear();
                onSubmitted('');
              },
            ),
          ),
        ),
      );
}
