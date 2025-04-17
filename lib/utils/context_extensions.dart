import 'package:flutter/material.dart';
import 'package:quran_book/widgets/dialog/loading_dialog_widget.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';

extension ContextExtensions on BuildContext {
  PageRoute<T> _slideRoute<T>(Widget nextPage) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, anim, secondaryAnim) => nextPage,
      transitionsBuilder: (context, anim, secondaryAnim, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: anim.drive(tween),
          child: child,
        );
      },
    );
  }

  Future navigateToNextPage(Widget nextPage) => Navigator.of(this).push(_slideRoute(nextPage));

  Future navigateToNextPageWithReplacement(Widget nextPage) => Navigator.of(this).pushReplacement(_slideRoute(nextPage));

  Future navigateToNextPageWithRemoveUntil(Widget nextPage) => Navigator.of(this).pushAndRemoveUntil(
        _slideRoute(nextPage),
        (route) => false,
      );

  void navigateBack([Object? argument]) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop(argument);
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: EasyTextWidget(text: message, textColor: Colors.white),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: EasyTextWidget(text: message, textColor: Colors.white),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showLoadingDialog({String? message}) {
    showDialog(
        context: this,
        barrierDismissible: false,
        builder: (_) => LoadingDialogWidget(
              message: message ?? '',
            ));
  }

  void hideLoadingDialog() {
    navigateBack();
  }
}
