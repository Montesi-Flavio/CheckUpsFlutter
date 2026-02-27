import 'package:flutter/material.dart';

class ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final String? tooltip;

  const ModernActionButton({
    super.key,
    required this.icon,
    this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? side;

    if (isDestructive) {
      backgroundColor = colorScheme.errorContainer;
      foregroundColor = colorScheme.onErrorContainer;
      side = BorderSide(color: colorScheme.error.withOpacity(0.5));
    } else if (isPrimary) {
      backgroundColor = colorScheme.primary;
      foregroundColor = colorScheme.onPrimary;
      side = null;
    } else {
      // Secondary / Default (Tonal or Outlined look)
      backgroundColor =
          Colors.white; // Explicitly white for secondary to match clean look
      foregroundColor = colorScheme.onSurface;
      side = BorderSide(color: Colors.grey.withOpacity(0.3));
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: isPrimary ? 2 : 1,
      shadowColor: Colors.black.withOpacity(0.1),
      side: side,
      padding: EdgeInsets.symmetric(
        horizontal: label != null ? 20 : 12,
        vertical: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minimumSize: const Size(48, 48),
    );

    Widget button;
    if (label != null) {
      button = ElevatedButton.icon(
        onPressed: onPressed,
        style: buttonStyle,
        icon: Icon(icon, size: 20),
        label: Text(
          label!,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Icon(icon, size: 22),
      );
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }

    return button;
  }
}
