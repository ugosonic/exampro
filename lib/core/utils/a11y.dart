import 'package:flutter/material.dart';

class A11y {
  static Widget semanticsButton({required String label, required Widget child}) => Semantics(
        button: true,
        label: label,
        child: child,
      );
}

