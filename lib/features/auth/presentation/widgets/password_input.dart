// Password input widget
import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(obscureText: true);
  }
} 