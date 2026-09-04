import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quran_book/services/offline_content_service.dart';
import 'package:quran_book/services/storage_url_service.dart';

class CacheNetworkImageWidget extends StatefulWidget {
  const CacheNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.radius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double? radius;

  @override
  State<CacheNetworkImageWidget> createState() =>
      _CacheNetworkImageWidgetState();
}

class _CacheNetworkImageWidgetState extends State<CacheNetworkImageWidget> {
  String? _localPath;
  int _urlCandidateIndex = 0;
  late List<String> _urlCandidates;

  @override
  void initState() {
    super.initState();
    _urlCandidates = storageUrlCandidates(widget.imageUrl);
    _loadLocalPath();
  }

  @override
  void didUpdateWidget(covariant CacheNetworkImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _urlCandidates = storageUrlCandidates(widget.imageUrl);
      _urlCandidateIndex = 0;
      _loadLocalPath();
    }
  }

  Future<void> _loadLocalPath() async {
    final path = await OfflineContentService.localPathForUrl(widget.imageUrl);
    if (!mounted) return;
    if (path != null && File(path).existsSync()) {
      setState(() => _localPath = path);
    }
  }

  void _tryNextUrl() {
    if (_urlCandidateIndex + 1 < _urlCandidates.length) {
      setState(() => _urlCandidateIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _localPath != null
        ? Image.file(
            File(_localPath!),
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (_, __, ___) => _networkImage(context),
          )
        : _networkImage(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius ?? 0),
      child: child,
    );
  }

  Widget _networkImage(BuildContext context) {
    if (_urlCandidates.isEmpty) {
      return _errorIcon(context);
    }

    final url = _urlCandidates[_urlCandidateIndex];
    return CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (_, __) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).progressIndicatorTheme.color ??
              Theme.of(context).colorScheme.primary,
        ),
      ),
      errorWidget: (_, __, ___) {
        if (_urlCandidateIndex + 1 < _urlCandidates.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _tryNextUrl();
          });
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).progressIndicatorTheme.color,
            ),
          );
        }
        return _errorIcon(context);
      },
    );
  }

  Widget _errorIcon(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
