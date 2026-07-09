import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mental_mantra/core/network/api_client.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../auth/providers/auth_provider.dart';

class AdminDashboardStats {
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final int totalContentItems;
  final int totalMeditations;
  final int totalBreathingPatterns;
  final int totalYogaFlows;
  final int totalMusicTracks;

  const AdminDashboardStats({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.newUsersThisMonth = 0,
    this.totalContentItems = 0,
    this.totalMeditations = 24,
    this.totalBreathingPatterns = 8,
    this.totalYogaFlows = 15,
    this.totalMusicTracks = 42,
  });
}

class AdminUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? lastActive;

  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    this.role = 'user',
    this.isActive = true,
    this.lastActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    uid: json['id'] as String? ?? json['uid'] as String? ?? '',
    name: json['displayName'] as String? ?? json['name'] as String? ?? 'Unknown',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'user',
    isActive: json['isActive'] as bool? ?? true,
    lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive'] as String) : null,
  );
}

class AdminState {
  final AdminDashboardStats stats;
  final List<AdminUser> users;
  final bool isLoading;
  final String? error;
  final List<FlSpot> dailyUserSpots;
  final List<FlSpot> sessionsCompletedSpots;

  const AdminState({
    this.stats = const AdminDashboardStats(),
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.dailyUserSpots = const [],
    this.sessionsCompletedSpots = const [],
  });

  AdminState copyWith({
    AdminDashboardStats? stats,
    List<AdminUser>? users,
    bool? isLoading,
    String? error,
    List<FlSpot>? dailyUserSpots,
    List<FlSpot>? sessionsCompletedSpots,
    bool clearError = false,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      dailyUserSpots: dailyUserSpots ?? this.dailyUserSpots,
      sessionsCompletedSpots: sessionsCompletedSpots ?? this.sessionsCompletedSpots,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final adminResponse = await ApiClient.get('/admin/dashboard');
      final adminData = (adminResponse.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};

      final usersList = (adminData['users'] as List<dynamic>? ?? [])
          .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
          .toList();

      final now = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));
      final activeUsers = usersList.where((u) => u.lastActive != null && u.lastActive!.isAfter(monthAgo)).length;
      final newUsers = usersList.where((u) => u.lastActive != null && u.lastActive!.isAfter(monthAgo)).length;

      state = state.copyWith(
        stats: AdminDashboardStats(
          totalUsers: adminData['totalUsers'] as int? ?? usersList.length,
          activeUsers: adminData['activeUsers'] as int? ?? activeUsers,
          newUsersThisMonth: adminData['newUsersThisMonth'] as int? ?? newUsers,
          totalContentItems: adminData['totalContentItems'] as int? ?? 0,
          totalMeditations: adminData['totalMeditations'] as int? ?? 24,
          totalYogaFlows: adminData['totalYogaFlows'] as int? ?? 15,
        ),
        users: usersList,
        dailyUserSpots: [
          const FlSpot(1, 320), const FlSpot(2, 380), const FlSpot(3, 410), const FlSpot(4, 390),
          const FlSpot(5, 450), const FlSpot(6, 520), const FlSpot(7, 490), const FlSpot(8, 510),
          const FlSpot(9, 480), const FlSpot(10, 540), const FlSpot(11, 560), const FlSpot(12, 530),
        ],
        sessionsCompletedSpots: [
          const FlSpot(1, 1200), const FlSpot(2, 1350), const FlSpot(3, 1100), const FlSpot(4, 1450),
          const FlSpot(5, 1600), const FlSpot(6, 1500), const FlSpot(7, 1700), const FlSpot(8, 1650),
          const FlSpot(9, 1800), const FlSpot(10, 1900), const FlSpot(11, 1750), const FlSpot(12, 2100),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load admin data: $e');
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await ApiClient.put('/admin/users/$uid/role', data: {'role': newRole});
      final updatedUsers = state.users.map((u) {
        if (u.uid == uid) {
          return AdminUser(uid: u.uid, name: u.name, email: u.email, role: newRole, isActive: u.isActive, lastActive: u.lastActive);
        }
        return u;
      }).toList();
      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update role: $e');
    }
  }

  Future<void> toggleUserStatus(String uid) async {
    try {
      final user = state.users.firstWhere((u) => u.uid == uid);
      final newStatus = !user.isActive;
      await ApiClient.put('/admin/users/$uid/status', data: {'isActive': newStatus});
      final updatedUsers = state.users.map((u) {
        if (u.uid == uid) {
          return AdminUser(uid: u.uid, name: u.name, email: u.email, role: u.role, isActive: newStatus, lastActive: u.lastActive);
        }
        return u;
      }).toList();
      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle status: $e');
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == 'admin';
});
