import 'package:flutter/material.dart';

class LogoutDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String positiveText;
  final String negativeText;

  const LogoutDialogWidget({
    super.key,
    required this.title,
    required this.content,
    required this.positiveText,
    required this.negativeText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(negativeText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(positiveText),
        ),
      ],
    );
  }
}
