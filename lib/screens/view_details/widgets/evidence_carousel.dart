import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'fullscreen_viewers.dart';

// Widget that tries multiple network image URLs in order until one succeeds.
class _MultiTryNetworkImage extends StatefulWidget {
  final List<String> urls;
  final BoxFit fit;
  const _MultiTryNetworkImage({Key? key, required this.urls, this.fit = BoxFit.cover}) : super(key: key);

  @override
  State<_MultiTryNetworkImage> createState() => _MultiTryNetworkImageState();
}

class _MultiTryNetworkImageState extends State<_MultiTryNetworkImage> {
  int _index = 0;

  void _next() {
    if (_index < widget.urls.length - 1) {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.urls[_index];
    return Image.network(
      url,
      fit: widget.fit,
      loadingBuilder: (ctx, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (ctx, e, st) {
        // try next candidate
        WidgetsBinding.instance.addPostFrameCallback((_) => _next());
        return Container(
          color: Colors.grey.shade300,
          child: const Center(child: Icon(Icons.videocam_off, size: 48, color: Colors.black26)),
        );
      },
    );
  }
}

class EvidenceCarousel extends StatefulWidget {
  final List<String>? evidences;
  const EvidenceCarousel({Key? key, this.evidences}) : super(key: key);

  @override
  State<EvidenceCarousel> createState() => _EvidenceCarouselState();
}

class _EvidenceCarouselState extends State<EvidenceCarousel> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  bool _isVideoUrl(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm') || u.endsWith('.mkv') || u.contains('video');
  }

  /// If the video is hosted on Cloudinary, attempt to build a poster image URL
  /// by reusing the same resource path but changing the file ext to `.jpg` and
  /// inserting a screenshot transform (`so_0`) after `upload/`.
  String _posterForVideo(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.contains('cloudinary.com')) {
        // Example Cloudinary video URL:
        // https://res.cloudinary.com/<cloud>/video/upload/v123/.../folder/file.mp4
        // Poster URL (first frame):
        // https://res.cloudinary.com/<cloud>/video/upload/so_0/v123/.../folder/file.jpg
        final parts = url.split('/upload/');
        if (parts.length == 2) {
          final before = parts[0] + '/upload/';
          var after = parts[1];
          // remove query params
          final qIndex = after.indexOf('?');
          var query = '';
          if (qIndex >= 0) {
            query = after.substring(qIndex);
            after = after.substring(0, qIndex);
          }
          // replace extension with .jpg
          // NOTE: use end-of-string anchor ($) correctly in the regex
            after = after.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '.jpg');
          // insert screenshot transformation (so_2) immediately after upload/ to avoid initial black frames
          final poster = before + 'so_2/' + after + query;
          return poster;
        }
      }
    } catch (_) {
      // ignore and fallback later
    }
    return url;
  }

  /// Alternative poster generation that switches the resource type to `image`
  /// (some Cloudinary setups deliver extracted frames via the image endpoint).
  String _altPosterForVideo(String url) {
    try {
      if (url.contains('/video/upload/')) {
        final parts = url.split('/video/upload/');
        if (parts.length == 2) {
          final before = parts[0] + '/image/upload/';
          var after = parts[1];
          final qIndex = after.indexOf('?');
          var query = '';
          if (qIndex >= 0) {
            query = after.substring(qIndex);
            after = after.substring(0, qIndex);
          }
          // replace extension with .jpg
          after = after.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '.jpg');
          final poster = before + 'so_2/' + after + query;
          return poster;
        }
      }
    } catch (_) {}
    return url;
  }

  

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final evidences = widget.evidences ?? [];
    if (evidences.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: evidences.length,
            onPageChanged: (i) => setState(() => _pageIndex = i),
            itemBuilder: (context, i) {
              final url = evidences[i];
              final isVideo = _isVideoUrl(url);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      if (isVideo) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FullscreenVideoViewer(videoUrl: url),
                          fullscreenDialog: true,
                        ));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FullscreenImageViewer(imageUrl: url),
                          fullscreenDialog: true,
                        ));
                      }
                    },
                    child: isVideo
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              // Attempt to show a Cloudinary poster (first frame) if possible,
                              // otherwise try the video URL (may fail) and finally show a placeholder.
                              Builder(builder: (ctx) {
                                final poster1 = _posterForVideo(url);
                                final poster2 = _altPosterForVideo(url);
                                final candidates = <String>[];
                                candidates.add(poster1);
                                if (poster2 != poster1) candidates.add(poster2);
                                // final fallback: the raw video URL (may not be an image)
                                candidates.add(url);
                                return _MultiTryNetworkImage(urls: candidates, fit: BoxFit.cover);
                              }),
                              // Play icon overlay
                              const Center(child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 56)),
                            ],
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (ctx, e, st) => Container(
                              color: Colors.grey.shade100,
                              child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.black26)),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(evidences.length, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _pageIndex == i ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _pageIndex == i ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
