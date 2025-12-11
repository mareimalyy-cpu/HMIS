import 'package:flutter/material.dart';

String getLanguageCodeHelper() {
  // Stub restoration
  return 'en';
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
