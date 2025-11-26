import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'fullscreen_viewers.dart';

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
                              Image.network(url, fit: BoxFit.cover, errorBuilder: (ctx, e, st) => Container(color: Colors.grey.shade100)),
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
