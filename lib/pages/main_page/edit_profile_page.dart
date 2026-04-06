import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.user});

  final UserVO user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name.trim();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    if (name == widget.user.name.trim()) {
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    try {
      if (mounted) context.showLoadingDialog();
      await _firebaseModel.updateCurrentUserName(name);
      if (mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar(kProfileUpdatedText.tr());
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: scheme.surface,
        title: Text(kEditProfileText.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          kSP20x,
          kSP10x,
          kSP20x,
          kSP30x + MediaQuery.paddingOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                kRegisterNameTitleText.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: kSP10x),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: kRegisterNameHintText.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kSP20x),
              Text(
                kRegisterEmailTitleText.tr(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: kSP10x),
              TextFormField(
                initialValue: widget.user.email,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(height: kSP5x),
              Text(
                kProfileEmailFixedText.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
              ),
              const SizedBox(height: kSP30x),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  kSaveChangesText.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSize16x,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
