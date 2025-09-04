import 'package:flutter/material.dart';

import '../config.dart';

class MightySelectInput extends StatelessWidget {
  MightySelectInput({
    Key? key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.value,
  }) : super(key: key);

  final String hintText;
  final List<DropdownMenuItem<String>> items;
  final void Function(dynamic) onChanged;
  final String? Function(String?)? validator;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: kdPadding),
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kdBorderRadius),
            border: Border.all(
              color: Colors.black45,
            ),
          ),
          child: DropdownButton(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontSize: 12),
            underline: SizedBox(),
            onChanged: onChanged,
            // showSelectedItem: false,
            isExpanded: true,
            value: value,
            hint: Text("Type"),
            items: items,
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }
}
