import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_book/resources/colors.dart';
import 'package:quran_book/resources/dimens.dart';
import 'package:quran_book/widgets/easy_text_widget.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Book reader: single-page PDF with bottom controls (page + zoom).
class BookReadDetailsPage extends StatefulWidget {
  const BookReadDetailsPage({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  final String title;
  final String pdfUrl;

  @override
  State<BookReadDetailsPage> createState() => _BookReadDetailsPageState();
}

class _BookReadDetailsPageState extends State<BookReadDetailsPage> {
  static const double _minZoom = 1.0;
  static const double _maxZoom = 5.0;
  static const double _zoomStep = 0.5;

  late final PdfViewerController _pdfController;
  bool _docReady = false;
  String? _loadError;
  int _reloadToken = 0;

  /// Tracks real zoom (pinch + buttons); [PdfViewerController.zoomLevel] can lag after gestures.
  double _liveZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _pdfController.addListener(_onPdfChanged);
  }

  void _onPdfChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pdfController.removeListener(_onPdfChanged);
    _pdfController.dispose();
    super.dispose();
  }

  int get _pageNum {
    final n = _pdfController.pageNumber;
    return n <= 0 ? 1 : n;
  }

  int get _pageTotal {
    final t = _pdfController.pageCount;
    return t <= 0 ? 0 : t;
  }

  bool get _canZoomIn =>
      _docReady && _liveZoom < _maxZoom - 0.02;

  bool get _canZoomOut => _docReady && _liveZoom > _minZoom + 0.02;

  void _zoomIn() {
    if (!_canZoomIn) return;
    final z = (_liveZoom + _zoomStep).clamp(_minZoom, _maxZoom).toDouble();
    _applyZoom(z);
  }

  void _zoomOut() {
    if (!_canZoomOut) return;
    final z = (_liveZoom - _zoomStep).clamp(_minZoom, _maxZoom).toDouble();
    _applyZoom(z);
  }

  void _applyZoom(double target) {
    // Nudge so Syncfusion setter does not no-op on tiny float differences.
    final t = target.clamp(_minZoom, _maxZoom).toDouble();
    _pdfController.zoomLevel = t;
    setState(() => _liveZoom = t);
  }

  void _onZoomLevelChanged(PdfZoomDetails d) {
    if (!mounted) return;
    setState(() => _liveZoom = d.newZoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.pdfUrl.trim();
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    final canvas = scheme.surfaceContainerLow;
    final onCanvas = scheme.onSurface;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        systemNavigationBarColor: canvas,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: SfPdfViewerTheme(
        data: SfPdfViewerThemeData(backgroundColor: canvas),
        child: Scaffold(
          backgroundColor: canvas,
          appBar: AppBar(
            toolbarHeight: 46,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            backgroundColor: canvas,
            foregroundColor: onCanvas,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            title: EasyTextWidget(
              text: widget.title,
              fontWeight: FontWeight.w600,
              fontSize: kFontSize16x,
              maxLines: 1,
              textColor: onCanvas,
            ),
            actions: [
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_horiz, color: onCanvas),
                onSelected: (_) {},
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      'Pinch to zoom, or use − / + below. Double-tap toggles zoom. Drag to pan when zoomed.',
                      style: TextStyle(fontSize: 13, color: onCanvas),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: url.isEmpty
              ? const Center(child: Text('No PDF link for this book.'))
              : _loadError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(kSP20x),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _loadError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: kSP20x),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  _loadError = null;
                                  _docReady = false;
                                  _liveZoom = 1.0;
                                  _reloadToken++;
                                });
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: kAppPrimaryColor,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SfPdfViewer.network(
                            url,
                            key: ValueKey('$url-$_reloadToken'),
                            controller: _pdfController,
                            pageLayoutMode: PdfPageLayoutMode.single,
                            pageSpacing: 0,
                            canShowScrollHead: false,
                            canShowScrollStatus: false,
                            canShowPageLoadingIndicator: true,
                            interactionMode: PdfInteractionMode.pan,
                            enableDoubleTapZooming: true,
                            maxZoomLevel: _maxZoom,
                            onZoomLevelChanged: _onZoomLevelChanged,
                            onDocumentLoaded: (_) {
                              if (mounted) {
                                setState(() {
                                  _docReady = true;
                                  _loadError = null;
                                  _liveZoom = _pdfController.zoomLevel;
                                });
                              }
                            },
                            onDocumentLoadFailed: (details) {
                              if (!mounted) return;
                              setState(() {
                                _docReady = false;
                                _loadError = details.description.isNotEmpty
                                    ? details.description
                                    : details.error;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            4,
                            12,
                            bottomInset > 0 ? bottomInset + 6 : 10,
                          ),
                          child: _ReaderBottomBar(
                            canvas: canvas,
                            onCanvas: onCanvas,
                            primary: kAppPrimaryColor,
                            pageLabel: _docReady && _pageTotal > 0
                                ? '$_pageNum of $_pageTotal'
                                : (_docReady ? '—' : '…'),
                            onPrevious: _docReady &&
                                    _pageTotal > 0 &&
                                    _pageNum > 1
                                ? () => _pdfController.previousPage()
                                : null,
                            onNext: _docReady &&
                                    _pageTotal > 0 &&
                                    _pageNum < _pageTotal
                                ? () => _pdfController.nextPage()
                                : null,
                            onZoomOut: _canZoomOut ? _zoomOut : null,
                            onZoomIn: _canZoomIn ? _zoomIn : null,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

/// Rounded bar: zoom − | prev | page | next | zoom +
class _ReaderBottomBar extends StatelessWidget {
  const _ReaderBottomBar({
    required this.canvas,
    required this.onCanvas,
    required this.primary,
    required this.pageLabel,
    required this.onPrevious,
    required this.onNext,
    required this.onZoomOut,
    required this.onZoomIn,
  });

  final Color canvas;
  final Color onCanvas;
  final Color primary;
  final String pageLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomIn;

  @override
  Widget build(BuildContext context) {
    return Material(
      // elevation: 1.5,
      // shadowColor: Colors.black26,
      color: canvas.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.92 : 1),
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ZoomCircle(
              icon: Icons.remove,
              onPressed: onZoomOut,
              primary: primary,
            ),
            _NavCircle(
              icon: Icons.chevron_left,
              onPressed: onPrevious,
            ),
            Flexible(
              child: Text(
                pageLabel,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: onCanvas,
                ),
              ),
            ),
            _NavCircle(
              icon: Icons.chevron_right,
              onPressed: onNext,
            ),
            _ZoomCircle(
              icon: Icons.add,
              onPressed: onZoomIn,
              primary: primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomCircle extends StatelessWidget {
  const _ZoomCircle({
    required this.icon,
    required this.onPressed,
    required this.primary,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: primary.withValues(alpha: 0.15),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 25,
            height: 25,
            child: Icon(icon, color: primary, size: 25),
          ),
        ),
      ),
    );
  }
}

class _NavCircle extends StatelessWidget {
  const _NavCircle({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Colors.black,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 25,
            height: 25,
            child: Icon(icon, color: Colors.white, size: 25),
          ),
        ),
      ),
    );
  }
}
