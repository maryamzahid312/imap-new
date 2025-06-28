import 'package:flutter/material.dart';

class MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const MiniButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.grey.shade100),
      ),
      onPressed: onPressed,
    );
  }
}
