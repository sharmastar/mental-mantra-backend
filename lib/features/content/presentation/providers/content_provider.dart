import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/content_feed_item.dart';

class ContentState {
  final List<ContentFeedItem> items;
  final String selectedCategory;

  const ContentState({
    this.items = const [],
    this.selectedCategory = 'All',
  });

  List<ContentFeedItem> get filteredItems {
    if (selectedCategory == 'All') return items;
    return items.where((item) => item.category == selectedCategory).toList();
  }

  List<ContentFeedItem> get featuredItems {
    return items.where((f) => f.isFeatured).toList();
  }

  ContentState copyWith({List<ContentFeedItem>? items, String? selectedCategory}) {
    return ContentState(
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

final _curatedContent = [
  const ContentFeedItem(id: 'f1', title: '5-Minute Morning Mindfulness', subtitle: 'Start your day with clarity and calm', category: 'Featured', icon: Icons.wb_sunny_outlined, color: Color(0xFFFFB547), videoId: 'ZToicYcHIOU', isFeatured: true),
  const ContentFeedItem(id: 'f2', title: 'Understanding Your Emotions', subtitle: 'A gentle guide to emotional awareness', category: 'Educational', icon: Icons.psychology_outlined, color: Color(0xFF6C63FF), route: '/home/journal'),
  const ContentFeedItem(id: 'f3', title: 'The Power of Deep Breathing', subtitle: 'How 60 seconds can reset your nervous system', category: 'Educational', icon: Icons.air_outlined, color: Color(0xFF00BFA5), videoId: 'tEmt1ZnE_tY'),
  const ContentFeedItem(id: 'f4', title: 'Building Habits That Stick', subtitle: 'Small changes, lasting impact', category: 'Motivation', icon: Icons.trending_up_outlined, color: Color(0xFF4CAF50), route: '/home/habits'),
  const ContentFeedItem(id: 'f5', title: 'Yoga for Desk Workers', subtitle: 'Release tension without leaving your chair', category: 'Movement', icon: Icons.accessibility_new, color: Color(0xFFFF6B9D), videoId: 'p6N53y2-T7w'),
  const ContentFeedItem(id: 'f6', title: 'Sleep Hygiene Basics', subtitle: 'Prepare your mind and body for restful sleep', category: 'Sleep', icon: Icons.bedtime_outlined, color: Color(0xFF9C27B0), route: '/home/sleep'),
  const ContentFeedItem(id: 'f7', title: 'Gratitude Journaling', subtitle: 'Shift your focus to what\'s going well', category: 'Wellness', icon: Icons.book_outlined, color: Color(0xFFFF6B9D), route: '/home/journal'),
  const ContentFeedItem(id: 'f8', title: 'Urge Surfing Technique', subtitle: 'Ride the wave of cravings without acting', category: 'Recovery', icon: Icons.waves_outlined, color: Color(0xFF6C63FF), route: '/home/recovery'),
  const ContentFeedItem(id: 'f9', title: 'Body Scan for Relaxation', subtitle: 'Release tension from head to toe', category: 'Meditation', icon: Icons.self_improvement, color: Color(0xFF00BFA5), videoId: 'AKGgNq3qQrE'),
  const ContentFeedItem(id: 'f10', title: 'Brain Games Boost Focus', subtitle: 'Train your attention like a muscle', category: 'Games', icon: Icons.psychology_outlined, color: Color(0xFF00BCD4)),
];

class ContentNotifier extends StateNotifier<ContentState> {
  ContentNotifier() : super(ContentState(items: _curatedContent));

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final contentProvider = StateNotifierProvider<ContentNotifier, ContentState>((ref) {
  return ContentNotifier();
});
