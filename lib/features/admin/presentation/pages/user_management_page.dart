import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
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
      appBar: AppBar(title: const Text('User Management')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.users.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return _buildUserCard(context, user, theme);
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No users found', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Users will appear here once they sign up.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(adminProvider.notifier).load(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic user, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isAdmin = user.role == 'admin';
    final isActive = user.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
            child:
                Text(user.name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('${user.role} \u2022 ${isActive ? "Active" : "Inactive"}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
                Text(user.email,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'make_admin') {
                ref
                    .read(adminProvider.notifier)
                    .updateUserRole(user.uid, 'admin');
              } else if (val == 'make_user') {
                ref
                    .read(adminProvider.notifier)
                    .updateUserRole(user.uid, 'user');
              } else if (val == 'toggle_status') {
                ref.read(adminProvider.notifier).toggleUserStatus(user.uid);
              }
            },
            itemBuilder: (context) => [
              if (!isAdmin)
                const PopupMenuItem(
                    value: 'make_admin', child: Text('Promote to Admin')),
              if (isAdmin)
                const PopupMenuItem(
                    value: 'make_user', child: Text('Demote to User')),
              PopupMenuItem(
                value: 'toggle_status',
                child: Text(isActive ? 'Deactivate' : 'Activate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
