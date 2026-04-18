import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<UserProfile> _allUsers = [];
  bool _isLoading = true;
  String? _error;

  String _searchQuery = '';
  String _roleFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _api.fetchAdminUsers(search: _searchController.text);
      if (!mounted) return;
      setState(() {
        _allUsers = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRole(UserProfile user, String role) async {
    try {
      final updated = await _api.updateAdminUserRole(
        userId: user.id ?? 0,
        role: role,
      );
      if (!mounted) return;
      setState(() {
        _allUsers = _allUsers.map((u) {
          if (u.id == updated.id) return updated;
          return u;
        }).toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Role updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _deleteUser(UserProfile user) async {
    try {
      await _api.deleteAdminUser(user.id ?? 0);
      if (!mounted) return;
      setState(() {
        _allUsers = _allUsers.where((u) => u.id != user.id).toList();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User deleted.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF15D30);

    final filtered = _allUsers.where((u) {
      final name = u.name ?? '';
      final email = u.email ?? '';
      final role = u.role ?? 'user';

      final q = _searchQuery.toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          name.toLowerCase().contains(q) ||
          email.toLowerCase().contains(q);

      final matchesRole = _roleFilter == 'All'
          ? true
          : role.toLowerCase() == _roleFilter.toLowerCase();

      return matchesSearch && matchesRole;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: const Text('Users'),
      ),
      body: Column(
        children: [
          // SEARCH & FILTER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _loadUsers();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (_) => _loadUsers(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _RoleFilterDropdown(
                    value: _roleFilter,
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _roleFilter = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : filtered.isEmpty
                ? const Center(child: Text('No users found.'))
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        return _UserCard(
                          user: user,
                          onTap: () {
                            _showUserActions(context, user);
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showUserActions(BuildContext context, UserProfile user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final name = user.name ?? 'User';
        final email = user.email ?? '';
        final role = user.role ?? 'user';
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                'Role',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _RoleChipOption(
                    label: 'user',
                    selected: role == 'user',
                    onTap: () {
                      Navigator.pop(context);
                      _updateRole(user, 'user');
                    },
                  ),
                  _RoleChipOption(
                    label: 'author',
                    selected: role == 'author',
                    onTap: () {
                      Navigator.pop(context);
                      _updateRole(user, 'author');
                    },
                  ),
                  _RoleChipOption(
                    label: 'admin',
                    selected: role == 'admin',
                    onTap: () {
                      Navigator.pop(context);
                      _updateRole(user, 'admin');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser(user);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Delete user',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dropdown for role filter
class _RoleFilterDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _RoleFilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: const [
          DropdownMenuItem(value: 'All', child: Text('All')),
          DropdownMenuItem(value: 'user', child: Text('Users')),
          DropdownMenuItem(value: 'author', child: Text('Authors')),
          DropdownMenuItem(value: 'admin', child: Text('Admins')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

// User row card
class _UserCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  Color _roleColor() {
    switch (user.role ?? 'user') {
      case 'admin':
        return Colors.redAccent;
      case 'author':
        return Colors.blueAccent;
      default:
        return Colors.green;
    }
  }

  String _roleLabel() {
    switch (user.role ?? 'user') {
      case 'admin':
        return 'Admin';
      case 'author':
        return 'Author';
      default:
        return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = user.name ?? 'User';
    final email = user.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: Text(
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            color: _roleColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _roleLabel(),
            style: TextStyle(
              fontSize: 11,
              color: _roleColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// Chip option in bottom sheet
class _RoleChipOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChipOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  Color _roleColor() {
    switch (label) {
      case 'admin':
        return Colors.redAccent;
      case 'author':
        return Colors.blueAccent;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _roleColor();
    return ChoiceChip(
      label: Text(label[0].toUpperCase() + label.substring(1)),
      selected: selected,
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? color : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
