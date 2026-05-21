import 'package:flutter/material.dart';

class CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBuscar;
  final ValueChanged<String>? onChanged;

  const CampoBusca({
    super.key,
    required this.controller,
    required this.onBuscar,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: (_) => onBuscar(),
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Digite o nome do filme',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}