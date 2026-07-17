import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.go('/home/dashboard'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Control Panel',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      'Manage users, content curation, and review system analytics.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 16),
                  _buildStatRow(theme, state.stats),
                  const SizedBox(height: 24),
                  _buildAdminMenuOption(
                      context,
                      'Content Management',
                      'Update meditation packages, breathing exercises, and yoga poses.',
                      Icons.library_books,
                      AppTheme.primaryColor,
                      () => context.go('/admin/content')),
                  const SizedBox(height: 16),
                  _buildAdminMenuOption(
                      context,
                      'User Management',
                      'Review registered users, update permissions, and role management.',
                      Icons.people,
                      AppTheme.secondaryColor,
                      () => context.go('/admin/users')),
                  const SizedBox(height: 16),
                  _buildAdminMenuOption(
                      context,
                      'System Analytics',
                      'View active user trends, content completion, and performance metrics.',
                      Icons.bar_chart,
                      AppTheme.accentColor,
                      () => context.go('/admin/analytics')),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(ThemeData theme, AdminDashboardStats stats) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(theme, 'Total Users', '${stats.totalUsers}',
                Icons.people, AppTheme.primaryColor)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildStatCard(theme, 'Active Users', '${stats.activeUsers}',
                Icons.person_pin, AppTheme.successColor)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildStatCard(
                theme,
                'Content Items',
                '${stats.totalContentItems}',
                Icons.library_books,
                AppTheme.accentColor)),
      ],
    );
  }

  Widget _buildStatCard(
      ThemeData theme, String label, String value, IconData icon, Color color) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAdminMenuOption(BuildContext context, String title,
      String description, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
