import 'dart:ui';
import 'package:flutter/material.dart';

showLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Image.asset(
              'assets/icons/loadergif.gif',
              width: 120,
              height: 120,
            ),
          ),
        ),
      );
    },
  );
}

// hideLoader(BuildContext context) {
//   Navigator.pop(context);
// }
