import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/resources/strings.dart';
import 'package:quran_book/utils/context_extensions.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: EasyTextWidget(
          text: kDrawerContactUsText.tr(),
          fontWeight: FontWeight.w600,
          textColor: theme.appBarTheme.titleTextStyle?.color ??
              theme.textTheme.bodyMedium?.color,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kSP20x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.contact_support,
                size: 80,
                color: isDark ? Colors.white : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: kSP20x),
            Center(
              child: EasyTextWidget(
                text: 'Get in Touch',
                fontSize: kFontSize22x,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kSP10x),
            Center(
              child: EasyTextWidget(
                text: 'We would love to hear from you!',
                textColor:
                    theme.textTheme.bodySmall?.color ?? Colors.grey,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: kSP40x),
            _ContactItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@quranbook.com',
              onTap: () => _launchEmail(context, 'support@quranbook.com'),
              onLongPress: () => _copyToClipboard(context, 'support@quranbook.com'),
            ),
            const SizedBox(height: kSP20x),
            _ContactItem(
              icon: Icons.phone,
              title: 'Phone',
              subtitle: '+1 (555) 123-4567',
              onTap: () => _launchPhone(context, '+15551234567'),
              onLongPress: () => _copyToClipboard(context, '+1 (555) 123-4567'),
            ),
            const SizedBox(height: kSP20x),
            _ContactItem(
              icon: Icons.location_on,
              title: 'Address',
              subtitle: '123 Islamic Center Road\nNew York, NY 10001',
              onTap: () => _launchMaps(context),
              onLongPress: () => _copyToClipboard(context, '123 Islamic Center Road, New York, NY 10001'),
            ),
            const SizedBox(height: kSP20x),
            _ContactItem(
              icon: Icons.access_time,
              title: 'Working Hours',
              subtitle: 'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM',
              onTap: null,
            ),
            const SizedBox(height: kSP40x),
            EasyTextWidget(
              text: 'Follow Us',
              fontSize: kFontSize18x,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: kSP20x),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SocialButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () => _launchUrl(context, 'https://facebook.com'),
                ),
                _SocialButton(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  onTap: () => _launchUrl(context, 'https://t.me'),
                ),
                _SocialButton(
                  icon: Icons.web,
                  label: 'Website',
                  onTap: () => _launchUrl(context, 'https://quranbook.com'),
                ),
              ],
            ),
            const SizedBox(height: kSP40x),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Could not open email app');
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Could not open phone app');
      }
    }
  }

  Future<void> _launchMaps(BuildContext context) async {
    final uri = Uri.parse('https://maps.google.com/?q=123+Islamic+Center+Road+New+York+NY');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Could not open maps');
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Could not open link');
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.showSuccessSnackBar('Copied to clipboard');
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(kSP10x),
      child: Container(
        padding: const EdgeInsets.all(kSP15x),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(kSP10x),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(kSP10x),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(kSP10x),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : colorScheme.primary,
              ),
            ),
            const SizedBox(width: kSP15x),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EasyTextWidget(
                    text: title,
                    fontWeight: FontWeight.w600,
                    fontSize: kFontSize16x,
                  ),
                  const SizedBox(height: kSP5x),
                  EasyTextWidget(
                    text: subtitle,
                    textColor:
                        theme.textTheme.bodySmall?.color ?? Colors.grey,
                    fontSize: kFontSize14x,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.iconTheme.color?.withOpacity(0.7) ??
                    (isDark ? Colors.white70 : Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : theme.colorScheme.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kSP10x),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: kSP15x, vertical: kSP10x),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(kSP10x),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
            const SizedBox(height: kSP5x),
            EasyTextWidget(
              text: label,
              fontSize: kFontSize12x,
              textColor: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
