import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/fire_particles.dart';

class VentingSpacePage extends StatefulWidget {
  const VentingSpacePage({super.key});

  @override
  State<VentingSpacePage> createState() => _VentingSpacePageState();
}

class _VentingSpacePageState extends State<VentingSpacePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isBurning = false;
  bool _showSoothingMessage = false;

  void _burnThoughts() {
    if (_controller.text.trim().isEmpty) return;
    
    // Unfocus keyboard
    FocusScope.of(context).unfocus();
    HapticFeedback.heavyImpact();

    setState(() {
      _isBurning = true;
    });
  }

  void _onBurnComplete() {
    setState(() {
      _isBurning = false;
      _showSoothingMessage = true;
      _controller.clear();
    });
    HapticFeedback.lightImpact();
  }

  void _reset() {
    setState(() {
      _showSoothingMessage = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Venting Space'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Stack(
        children: [
          // Main Input View
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: (_isBurning || _showSoothingMessage) ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: _isBurning || _showSoothingMessage,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Let it all out.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Write down your frustrations, anger, or worries. Nobody will read this. When you are ready, we will burn it away.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppTheme.darkBorder : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            expands: true,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'I am feeling frustrated because...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white30 : Colors.black26,
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              // Trigger rebuild to enable/disable button
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _controller.text.trim().isNotEmpty ? _burnThoughts : null,
                          icon: const Icon(Icons.local_fire_department, color: Colors.white),
                          label: const Text(
                            'Burn These Thoughts',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935), // Red/Fire color
                            disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Burning Animation Overlay
          if (_isBurning)
            Positioned.fill(
              child: FireParticlesWidget(
                isBurning: _isBurning,
                onBurnComplete: _onBurnComplete,
              ),
            ),

          // Soothing Message View
          if (_showSoothingMessage)
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, val, child) {
                            return Opacity(
                              opacity: val,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - val)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              const Icon(
                                Icons.air,
                                size: 64,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'It is gone.',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'You are not your negative thoughts. Take a deep breath, and let it go.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 48),
                              OutlinedButton(
                                onPressed: _reset,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: const BorderSide(color: AppTheme.primaryColor),
                                ),
                                child: const Text(
                                  'Return',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
