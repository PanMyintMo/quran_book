import 'package:flutter/material.dart';
import 'package:quran_book/resources/strings.dart';

class LoadingDialogWidget extends StatelessWidget {
  final String message;

  const LoadingDialogWidget({
    super.key,
    this.message = kDefaultLoadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16.0),
            Text(message),
          ],
        ),
      ),
    );
  }
}
