import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class VideoCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<VideoInfo> videos;

  const VideoCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.videos,
  });
}

class VideoInfo {
  final String id;
  final String title;
  final String duration;
  final String videoId;

  const VideoInfo({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoId,
  });
}

final _videoCategories = [
  const VideoCategory(
      name: 'Meditation',
      icon: Icons.self_improvement,
      color: AppTheme.primaryColor,
      videos: [
        VideoInfo(
            id: 'vm1',
            title: '10-Minute Mindfulness Meditation',
            duration: '10:00',
            videoId: 'O-6f5wQXSu8'),
        VideoInfo(
            id: 'vm2',
            title: 'Guided Morning Meditation',
            duration: '15:00',
            videoId: 'ZToicYcHIOU'),
        VideoInfo(
            id: 'vm3',
            title: 'Body Scan Meditation',
            duration: '10:00',
            videoId: 'Cdeh5WU5ABo'),
        VideoInfo(
            id: 'vm4',
            title: 'Loving Kindness Meditation',
            duration: '10:00',
            videoId: 'e-TeW9CI0bc'),
      ]),
  const VideoCategory(
      name: 'Sleep',
      icon: Icons.bedtime,
      color: AppTheme.primaryDark,
      videos: [
        VideoInfo(
            id: 'vs1',
            title: 'Deep Sleep Meditation',
            duration: '20:00',
            videoId: 'u6w5sD33NfE'),
        VideoInfo(
            id: 'vs2',
            title: 'Sleep Hypnosis for Deep Rest',
            duration: '25:00',
            videoId: 'rCGGIK0oPkQ'),
        VideoInfo(
            id: 'vs3',
            title: 'Bedtime Yoga Nidra',
            duration: '40:00',
            videoId: 'R9U04pE7688'),
      ]),
  const VideoCategory(
      name: 'Focus',
      icon: Icons.psychology,
      color: AppTheme.secondaryColor,
      videos: [
        VideoInfo(
            id: 'vf1',
            title: 'Focus & Concentration Music',
            duration: '60:00',
            videoId: '5qap5aO4i9A'),
        VideoInfo(
            id: 'vf2',
            title: 'Study with Me - Pomodoro',
            duration: '120:00',
            videoId: 'mYBQPOst-9U'),
        VideoInfo(
            id: 'vf3',
            title: 'ADHD Focus Music',
            duration: '45:00',
            videoId: 'jfKfPfyJRdk'),
      ]),
  const VideoCategory(
      name: 'Yoga',
      icon: Icons.accessibility_new,
      color: AppTheme.errorColor,
      videos: [
        VideoInfo(
            id: 'vy1',
            title: 'Morning Yoga Flow',
            duration: '20:00',
            videoId: 'mMSsHji8LDA'),
        VideoInfo(
            id: 'vy2',
            title: 'Yoga for Beginners',
            duration: '20:00',
            videoId: 'v7AYKMP6rOE'),
        VideoInfo(
            id: 'vy3',
            title: 'Evening Stretch Yoga',
            duration: '20:00',
            videoId: 'gXuq4M5rU9E'),
      ]),
  const VideoCategory(
      name: 'Breathing',
      icon: Icons.air,
      color: AppTheme.secondaryColor,
      videos: [
        VideoInfo(
            id: 'vb1',
            title: 'Pranayama Breathing',
            duration: '20:00',
            videoId: 'hPNjUKfHAyw'),
        VideoInfo(
            id: 'vb2',
            title: 'Box Breathing Technique',
            duration: '5:00',
            videoId: 'zq07gbFLCAs'),
        VideoInfo(
            id: 'vb3',
            title: 'Wim Hof Breathing',
            duration: '11:00',
            videoId: 'nzCaZQqAs9I'),
      ]),
  const VideoCategory(
      name: 'Nature',
      icon: Icons.forest,
      color: AppTheme.successColor,
      videos: [
        VideoInfo(
            id: 'vn1',
            title: 'Forest Sounds for Relaxation',
            duration: '60:00',
            videoId: 'g2EWqOaUTt0'),
        VideoInfo(
            id: 'vn2',
            title: 'Rain Sounds for Sleep',
            duration: '60:00',
            videoId: 'q76bMs-NwRk'),
        VideoInfo(
            id: 'vn3',
            title: 'Ocean Waves for Meditation',
            duration: '60:00',
            videoId: 'f77SKI85I0s'),
      ]),
];

final selectedVideoCategoryProvider = StateProvider<int>((ref) => 0);
final activeVideoProvider = StateProvider<String?>((ref) => null);

class MeditationVideosPage extends ConsumerStatefulWidget {
  const MeditationVideosPage({super.key});

  @override
  ConsumerState<MeditationVideosPage> createState() =>
      _MeditationVideosPageState();
}

class _MeditationVideosPageState extends ConsumerState<MeditationVideosPage> {
  YoutubePlayerController? _playerController;
  String? _videoError;
  VideoInfo? _activeVideoInfo;
  bool _isPlayerLoading = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void dispose() {
    _playerController?.close();
    super.dispose();
  }

  Future<void> _playVideo(VideoInfo video) async {
    _activeVideoInfo = video;
    _retryCount = 0;
    ref.read(activeVideoProvider.notifier).state = video.videoId;
    _playerController?.close();
    _playerController = null;
    setState(() {
      _videoError = null;
      _isPlayerLoading = true;
    });

    try {
      final controller = YoutubePlayerController.fromVideoId(
        videoId: video.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableJavaScript: true,
          strictRelatedVideos: false,
        ),
      );
      _playerController = controller;
      setState(() => _isPlayerLoading = false);
    } catch (e) {
      setState(() {
        _videoError = 'Could not load video: $e';
        _isPlayerLoading = false;
      });
    }
  }

  void _retryVideo() {
    if (_activeVideoInfo != null && _retryCount < _maxRetries) {
      _retryCount++;
      _playVideo(_activeVideoInfo!);
    }
  }

  Future<void> _watchOnYouTube() async {
    if (_activeVideoInfo == null) return;
    final url = 'https://www.youtube.com/watch?v=${_activeVideoInfo!.videoId}';
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not open YouTube. Please try again.')),
        );
      }
    }
  }

  void _closePlayer() {
    _playerController?.close();
    _playerController = null;
    _activeVideoInfo = null;
    _videoError = null;
    _isPlayerLoading = false;
    ref.read(activeVideoProvider.notifier).state = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedCat = ref.watch(selectedVideoCategoryProvider);
    final activeVideoId = ref.watch(activeVideoProvider);
    final category = _videoCategories[selectedCat];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Meditation Videos'),
        backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      ),
      body: Column(
        children: [
          if (_activeVideoInfo != null)
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: _buildPlayerArea(activeVideoId),
            ),
          // Category tabs
          Container(
            height: 52,
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _videoCategories.length,
              itemBuilder: (ctx, i) {
                final cat = _videoCategories[i];
                final isSelected = selectedCat == i;
                return GestureDetector(
                  onTap: () => ref
                      .read(selectedVideoCategoryProvider.notifier)
                      .state = i,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [
                              cat.color,
                              cat.color.withValues(alpha: 0.6)
                            ])
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(cat.icon,
                          color: isSelected ? Colors.white : cat.color,
                          size: 16),
                      const SizedBox(width: 6),
                      Text(cat.name,
                          style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400)),
                    ]),
                  ),
                );
              },
            ),
          ),
          // Video list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: category.videos.length,
              itemBuilder: (ctx, i) {
                final video = category.videos[i];
                final isActive = activeVideoId == video.videoId;
                return GestureDetector(
                  onTap: () => _playVideo(video),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(colors: [
                              category.color.withValues(alpha: 0.15),
                              Colors.transparent
                            ])
                          : null,
                      color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isActive
                              ? category.color.withValues(alpha: 0.5)
                              : (isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder)),
                    ),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
                        child: Container(
                          width: 120,
                          height: 76,
                          color: category.color.withValues(alpha: 0.15),
                          child: Stack(alignment: Alignment.center, children: [
                            Icon(category.icon,
                                color: category.color.withValues(alpha: 0.3),
                                size: 36),
                            Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    color:
                                        category.color.withValues(alpha: 0.9),
                                    shape: BoxShape.circle),
                                child: Icon(
                                    isActive ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20)),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(video.title,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(Icons.schedule,
                                          size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(video.duration,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      const SizedBox(width: 12),
                                      Text('YouTube',
                                          style: TextStyle(
                                              color: category.color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500)),
                                    ]),
                                  ]))),
                      const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.play_circle_outline,
                              color: Colors.grey, size: 22)),
                    ]),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (i * 80).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea(String? activeVideoId) {
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
      if (_playerController != null)
        YoutubePlayer(
            key: ValueKey(activeVideoId), controller: _playerController!),
      Positioned(
          top: 8,
          right: 48,
          child: GestureDetector(
            onTap: _watchOnYouTube,
            child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.open_in_new,
                    color: Colors.white, size: 16)),
          )),
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
