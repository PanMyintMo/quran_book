import 'package:flutter/material.dart';

class PromptDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String? positiveText;
  final String? negativeText;
  final Function? onPositivePressed;
  final Function? onNegativePressed;

  const PromptDialogWidget.oneBtnDialog({
    super.key,
    required this.title,
    required this.content,
    required String buttonText,
    required Function onButtonPressed,
  })  : positiveText = buttonText,
        onPositivePressed = onButtonPressed,
        negativeText = null,
        onNegativePressed = null;

  const PromptDialogWidget.twoBtnDialog({
    super.key,
    required this.title,
    required this.content,
    required String positiveButtonText,
    required Function this.onPositivePressed,
    required String negativeButtonText,
    required Function this.onNegativePressed,
  })  : positiveText = positiveButtonText,
        negativeText = negativeButtonText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (negativeText != null && onNegativePressed != null) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onNegativePressed!();
          },
          child: Text(negativeText!),
        ),
      );
    }

    if (positiveText != null && onPositivePressed != null) {
      actions.add(
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPositivePressed!();
          },
          child: Text(positiveText!),
        ),
      );
    }

    return actions;
  }
}
