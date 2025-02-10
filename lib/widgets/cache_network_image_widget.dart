import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheNetworkImageWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(Icons.error),
        ),
      ),
    );
  }
}
