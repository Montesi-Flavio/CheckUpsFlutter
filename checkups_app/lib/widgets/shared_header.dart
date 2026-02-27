import 'package:flutter/material.dart';

class SharedHeader extends StatelessWidget {
  final Widget? rightContent;
  final bool showNavButtons;
  final VoidCallback? onHomePressed;
  final VoidCallback? onAdminPressed;
  final bool isHomeActive;
  final bool isAdminActive;

  const SharedHeader({
    super.key,
    this.rightContent,
    this.showNavButtons = true,
    this.onHomePressed,
    this.onAdminPressed,
    this.isHomeActive = false,
    this.isAdminActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/LOGOCheckUp.png',
            height: 64,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Nav Buttons or Custom Right Content
          if (rightContent != null)
            rightContent!
          else if (showNavButtons) ...[
            _NavButton(
              text: 'HOME',
              isActive: isHomeActive,
              onPressed: onHomePressed ?? () {},
            ),
            const SizedBox(width: 16),
            _NavButton(
              text: 'CREA / MODIFICA',
              isActive: isAdminActive,
              onPressed: onAdminPressed ?? () {},
            ),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavButton({
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isActive
            ? Theme.of(context).primaryColor
            : Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          decoration: isActive ? TextDecoration.underline : null,
          decorationColor: Theme.of(context).primaryColor,
          decorationThickness: 2,
        ),
      ),
    );
  }
}
