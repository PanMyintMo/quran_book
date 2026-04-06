import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran_book/bloc/main_page/local_and_theme_bloc.dart';
import 'package:quran_book/data/model/firebase_model.dart';
import 'package:quran_book/data/vos/user_vo.dart';
import 'package:quran_book/pages/help_support_page.dart';
import 'package:quran_book/pages/main_page/edit_profile_page.dart';
import 'package:quran_book/pages/introduction/login_page.dart';
import 'package:quran_book/pages/introduction/welcome_page.dart';
import 'package:quran_book/pages/main_page/book_mark_page.dart';
import 'package:quran_book/pages/main_page/setting_page.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:quran_book/widgets/primary_button_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseModel _firebaseModel = FirebaseModel();
  UserVO? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _firebaseModel.getCurrentUserVO();
    setState(() {
      _user = user;
    });
  }

  Future<void> _deleteAccount() async {
    if (_user != null) {
      await _firebaseModel.deleteUser(_user!.id);
      await _firebaseModel.currentUser?.delete();
      await _firebaseModel.logout();
      if (context.mounted) {
        context.navigateToNextPageWithRemoveUntil(const WelcomePage());
      }
    }
  }

  Future<void> _logout() async {
    context.showLoadingDialog();
    try {
      await _firebaseModel.logout();
      if (context.mounted) {
        context.hideLoadingDialog();
        context.showSuccessSnackBar(kLogoutText.tr());
        context.navigateToNextPageWithRemoveUntil(const LoginPage());
      }
    } catch (error) {
      if (context.mounted) {
        context.hideLoadingDialog();
        context.showErrorSnackBar(error.toString());
      }
    }
  }

  void _comingSoon(BuildContext context) {
    context.showSuccessSnackBar(kProfileComingSoonText.tr());
  }

  Future<void> _openEditProfile() async {
    final u = _user;
    if (u == null) return;
    final changed = await context.navigateToNextPage(EditProfilePage(user: u));
    if (!mounted) return;
    if (changed == true) await _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      drawer: const HomePageDrawerView(),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(kProfileText.tr()),
        titleTextStyle: TextStyle(
          fontSize: kFontSize18x,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        leading: Builder(
          builder: (ctx) {
            final canPop = Navigator.of(ctx).canPop();
            return IconButton(
              icon: Icon(
                canPop ? Icons.arrow_back_ios_new_rounded : Icons.menu_rounded,
                size: canPop ? 20 : 26,
              ),
              onPressed: () {
                if (canPop) {
                  Navigator.of(ctx).pop();
                } else {
                  Scaffold.of(ctx).openDrawer();
                }
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wb_sunny_outlined),
            onPressed: () async {
              await context.read<LocalAndThemeBloc>().toggleTheme();
            },
          ),
        ],
      ),
      body: _user == null
          ? _GuestProfileBody(
              onLogin: () => context.navigateToNextPageWithRemoveUntil(
                const LoginPage(),
              ),
              // onPrivacy: () => _pushPlaceholderPage(
              //   context,
              //   kProfilePrivacyText.tr(),
              // ),
              // onPurchase: () => _pushPlaceholderPage(
              //   context,
              //   kProfilePurchaseHistoryText.tr(),
              // ),
              onHelp: () => context.navigateToNextPage(const HelpSupportPage()),
              onSettings: () => context.navigateToNextPage(const SettingPage()),
              onInvite: () async {
                await Clipboard.setData(
                  const ClipboardData(text: 'Check out Quran Book app!'),
                );
                if (context.mounted) {
                  context.showSuccessSnackBar(kCopiedText.tr());
                }
              },
            )
          : _SignedInProfileBody(
              user: _user!,
              onUpgrade: () => _comingSoon(context),
              onEditProfile: _openEditProfile,
              onHelp: () => context.navigateToNextPage(const HelpSupportPage()),
              onSettings: () => context.navigateToNextPage(const SettingPage()),
              onLogout: _logout,
              onDeleteAccount: _deleteAccount,
            ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? onSurface.withValues(alpha: 0.88),
                  size: 26,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: titleColor ?? onSurface,
                      fontSize: kFontSize16x,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: onSurface.withValues(alpha: 0.42),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestProfileBody extends StatelessWidget {
  const _GuestProfileBody({
    required this.onLogin,
    // required this.onPrivacy,
    // required this.onPurchase,
    required this.onHelp,
    required this.onSettings,
    required this.onInvite,
  });

  final VoidCallback onLogin;
  // final VoidCallback onPrivacy;
  // final VoidCallback onPurchase;
  final VoidCallback onHelp;
  final VoidCallback onSettings;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        kSP20x,
        kSP10x,
        kSP20x,
        kSP30x + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 64,
              color: onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: kSP20x),
          EasyTextWidget(
            text: 'Guest User',
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            fontSize: kFontSize22x,
            textColor: onSurface,
          ),
          const SizedBox(height: kSP10x),
          EasyTextWidget(
            text: kProfileGuestSubtitleText.tr(),
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
            fontSize: kFontSize14x,
            textColor: onSurface.withValues(alpha: 0.58),
          ),
          const SizedBox(height: kSP20x),
          PrimaryButtonWidget(
            height: kProfilePageButtonHeight,
            width: double.infinity,
            radius: 28,
            onPressed: onLogin,
            buttonText: kLogin.tr(),
            backgroundColor: scheme.primary,
            buttonTextColor: scheme.onPrimary,
            buttonFontWeight: FontWeight.w700,
          ),
          const SizedBox(height: kSP30x),
          // _ProfileMenuTile(
          //   icon: Icons.shield_outlined,
          //   label: kProfilePrivacyText.tr(),
          //   onTap: onPrivacy,
          // ),
          // _ProfileMenuTile(
          //   icon: Icons.history_rounded,
          //   label: kProfilePurchaseHistoryText.tr(),
          //   onTap: onPurchase,
          // ),
          _ProfileMenuTile(
            icon: Icons.headset_mic_outlined,
            label: kDrawerHelpAndSupportText.tr(),
            onTap: onHelp,
          ),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            label: kDrawerSettingText.tr(),
            onTap: onSettings,
          ),
          _ProfileMenuTile(
            icon: Icons.person_add_outlined,
            label: kProfileInviteFriendText.tr(),
            onTap: onInvite,
          ),
        ],
      ),
    );
  }
}

class _SignedInProfileBody extends StatelessWidget {
  const _SignedInProfileBody({
    required this.user,
    required this.onUpgrade,
    required this.onEditProfile,
    required this.onHelp,
    required this.onSettings,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  final UserVO user;
  final VoidCallback onUpgrade;
  final Future<void> Function() onEditProfile;
  final VoidCallback onHelp;
  final VoidCallback onSettings;
  final Future<void> Function() onLogout;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    final name = user.name.trim();
    final initial =
        name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        kSP20x,
        kSP5x,
        kSP20x,
        kSP30x + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: kSP10x),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor:
                      scheme.surfaceContainerHighest.withValues(alpha: 0.85),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: scheme.primary,
                    child: EasyTextWidget(
                      text: initial,
                      fontWeight: FontWeight.w600,
                      fontSize: kFontSize40x,
                      textColor: scheme.onPrimary,
                    ),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -2,
                  child: Material(
                    color: scheme.primaryContainer,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onEditProfile(),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kSP20x),
          EasyTextWidget(
            text: name.isEmpty ? '—' : name,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
            fontSize: kFontSize22x,
            textColor: onSurface,
          ),
          const SizedBox(height: kSP5x),
          EasyTextWidget(
            text: user.email,
            textAlign: TextAlign.center,
            fontSize: kFontSize14x,
            textColor: onSurface.withValues(alpha: 0.58),
          ),
          const SizedBox(height: kSP20x),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: onUpgrade,
              child: Text(
                kProfileUpgradeProText.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: kFontSize16x,
                ),
              ),
            ),
          ),
          const SizedBox(height: kSP30x),
          _ProfileMenuTile(
            icon: Icons.edit_outlined,
            label: kEditProfileText.tr(),
            onTap: () => onEditProfile(),
          ),
          _ProfileMenuTile(
            icon: Icons.headset_mic_outlined,
            label: kDrawerHelpAndSupportText.tr(),
            onTap: onHelp,
          ),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            label: kDrawerSettingText.tr(),
            onTap: onSettings,
          ),
          _ProfileMenuTile(
            icon: Icons.logout_rounded,
            label: kLogoutText.tr(),
            onTap: () => onLogout(),
          ),
          _ProfileMenuTile(
            icon: Icons.delete_outline_rounded,
            label: kDeleteAccountText.tr(),
            onTap: onDeleteAccount,
            titleColor: scheme.error,
            iconColor: scheme.error,
          ),
        ],
      ),
    );
  }
}
