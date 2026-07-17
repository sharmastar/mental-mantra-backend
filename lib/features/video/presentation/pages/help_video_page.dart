import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class HelpVideoPage extends ConsumerStatefulWidget {
  const HelpVideoPage({super.key});

  @override
  ConsumerState<HelpVideoPage> createState() => _HelpVideoPageState();
}

class _HelpVideoPageState extends ConsumerState<HelpVideoPage> {
  YoutubePlayerController? _controller;
  String? _activeVideoId;
  String? _activeVideoTitle;
  bool _isPlayerLoading = false;
  String? _videoError;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  static const _videos = [
    {
      'id': 'guide1',
      'title': 'Getting Started with Mental Mantra',
      'videoId': '4pLUleLdwY4',
      'duration': '15:00'
    },
    {
      'id': 'guide2',
      'title': 'How to Use Mood Tracking',
      'videoId': 'zq07gbFLCAs',
      'duration': '5:00'
    },
    {
      'id': 'guide3',
      'title': 'Guided Meditation Basics',
      'videoId': 'O-6f5wQXSu8',
      'duration': '10:00'
    },
    {
      'id': 'guide4',
      'title': 'Understanding Your Analytics',
      'videoId': 'ZToicYcHIOU',
      'duration': '10:00'
    },
  ];

  Future<void> _playVideo(String videoId, String title) async {
    _activeVideoId = videoId;
    _activeVideoTitle = title;
    _retryCount = 0;
    _controller?.close();
    _controller = null;
    setState(() {
      _videoError = null;
      _isPlayerLoading = true;
    });

    try {
      final controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableJavaScript: true,
          strictRelatedVideos: false,
        ),
      );
      _controller = controller;
      setState(() => _isPlayerLoading = false);
    } catch (e) {
      setState(() {
        _videoError = 'Could not load video: $e';
        _isPlayerLoading = false;
      });
    }
  }

  void _closePlayer() {
    _controller?.close();
    _controller = null;
    _activeVideoId = null;
    _activeVideoTitle = null;
    _videoError = null;
    _isPlayerLoading = false;
    setState(() {});
  }

  void _retryVideo() {
    if (_activeVideoId != null &&
        _activeVideoTitle != null &&
        _retryCount < _maxRetries) {
      _retryCount++;
      _playVideo(_activeVideoId!, _activeVideoTitle!);
    }
  }

  Future<void> _watchOnYouTube() async {
    if (_activeVideoId == null) return;
    final url = 'https://www.youtube.com/watch?v=$_activeVideoId';
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Help & Tutorials'),
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_controller != null || _isPlayerLoading || _videoError != null)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildPlayerArea(),
            ).animate().fadeIn(duration: 300.ms),
          if (_controller != null || _isPlayerLoading || _videoError != null)
            const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.smart_display,
                        color: Colors.white, size: 24)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Watch & Learn',
                          style: TextStyle(
                              fontFamily: 'Playfair Display',
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                      Text('Video guides to get the most out of Mental Mantra',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13)),
                    ])),
              ]),
            ]),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          Text('Tutorials',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 12),
          ..._videos.asMap().entries.map((entry) {
            final v = entry.value;
            return GestureDetector(
              onTap: _controller != null
                  ? null
                  : () => _playVideo(v['videoId']!, v['title']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color:
                          isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                ),
                child: Row(children: [
                  Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(v['title']!,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.schedule,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(v['duration']!,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          const SizedBox(width: 12),
                          const Text('YouTube',
                              style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ]),
                      ])),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ]),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (entry.key * 80).ms)
                .slideX(begin: 0.05, end: 0);
          }),
          const SizedBox(height: 12),
          Text('Need more help?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.chat_outlined,
                      color: AppTheme.primaryColor, size: 22)),
              const SizedBox(width: 14),
              const Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Ask Nova',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    SizedBox(height: 2),
                    Text(
                        'Your AI companion can answer questions about using the app',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ])),
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Chat Now',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea() {
    if (_isPlayerLoading) {
      return const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(color: Colors.white)),
        SizedBox(height: 12),
        Text('Loading video...',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
      ]));
    }

    if (_videoError != null) {
      final canRetry = _retryCount < _maxRetries;
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 8),
        const Text('Video Unavailable',
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(_videoError!,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            textAlign: TextAlign.center),
        if (!canRetry) ...[
          const SizedBox(height: 4),
          const Text('Retry limit reached',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (canRetry)
            ElevatedButton.icon(
              onPressed: _retryVideo,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            ),
          if (canRetry) const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _watchOnYouTube,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(canRetry ? 'Watch on YouTube' : 'Open in YouTube'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          ),
        ]),
      ]));
    }

    return Stack(children: [
      YoutubePlayer(key: ValueKey(_activeVideoId), controller: _controller!),
      Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _closePlayer,
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 18)),
          )),
    ]);
  }
}
