import 'package:flutter/material.dart';

import '../theme/colors.dart';

class Button extends StatelessWidget {
  final String caption;
  final Function onPressed;
  final Gradient gradient;

  const Button({
    super.key,
    required this.caption,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.withdraw.withAlpha(77),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: Text(caption),
        ),
      ),
    );
  }
}
