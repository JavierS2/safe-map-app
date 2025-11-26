import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../theme/app_colors.dart';

// Fullscreen image viewer
class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const FullscreenImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (ctx, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (ctx, e, st) => const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
          ),
        ),
      ),
    );
  }
}

// Fullscreen video viewer using video_player
class FullscreenVideoViewer extends StatefulWidget {
  final String videoUrl;
  const FullscreenVideoViewer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<FullscreenVideoViewer> createState() => _FullscreenVideoViewerState();
}

class _FullscreenVideoViewerState extends State<FullscreenVideoViewer> {
  VideoPlayerController? _controller;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initializing = false;
        });
        _controller?.play();
      }).catchError((_) {
        setState(() {
          _initializing = false;
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Center(
        child: _initializing || _controller == null
            ? const CircularProgressIndicator()
            : Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: VideoProgressIndicator(_controller!, allowScrubbing: true, colors: VideoProgressColors(playedColor: AppColors.primary)),
                  ),
                  // small centered play/pause button just above the progress bar
                  Positioned(
                    bottom: 56,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        elevation: 6,
                        child: InkWell(
                          onTap: () {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                            setState(() {});
                          },
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                      } else {
                        _controller!.play();
                      }
                      setState(() {});
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ],
              ),
      ),
      floatingActionButton: null,
    );
  }
}
