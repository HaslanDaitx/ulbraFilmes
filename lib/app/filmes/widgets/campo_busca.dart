import 'package:flutter/material.dart';

class CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBuscar;
  final VoidCallback onLimpar;
  final ValueChanged<String>? onChanged;

  const CampoBusca({
    super.key,
    required this.controller,
    required this.onBuscar,
    required this.onLimpar,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: (_) => onBuscar(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Digite o nome do filme',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: onLimpar,
        ),
      ),
    );
  }
}