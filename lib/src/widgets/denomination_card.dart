import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DenominationCard extends StatelessWidget {
  final String label;
  final String assetIcon;
  final TextEditingController controller;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const DenominationCard({
    super.key,
    required this.label,
    required this.assetIcon,
    required this.controller,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCoin = label.contains('¢') ||
        label == '\$ 1' ||
        label == '\$1' ||
        label.contains('c') ||
        label.contains('C');

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.08),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Icono y Etiqueta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isCoin
                        ? Colors.amber.withOpacity(0.15)
                        : Colors.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    assetIcon,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Input y Controles
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: colorScheme.primary),
                  onPressed: onDecrement,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (hasFocus && controller.text.isNotEmpty) {
                        controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: controller.text.length,
                        );
                      }
                    },
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 3,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        counterText: "",
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: colorScheme.primary),
                  onPressed: onIncrement,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
