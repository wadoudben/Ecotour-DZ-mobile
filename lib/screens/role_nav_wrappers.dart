import 'package:flutter/material.dart';

import 'admin/admincomments_screen.dart';
import 'admin/admincontent_screen.dart';
import 'admin/adminusers_screen.dart';
import 'admin/dashboard.dart';
import 'author/authormyblog_screen.dart';
import 'author/dashboard.dart';
import 'blog/blog_list_screen.dart';
import 'home/home_screen.dart';
import 'user/messagelist_screen.dart';
import 'user/profile_entry_screen.dart';

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BlogListScreen();
  }
}

class DashboardScreen extends StatelessWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'admin') return const AdminDashboardScreen();
    if (role == 'author') return const AuthorDashboardScreen();
    return const HomeScreen();
  }
}

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminContentScreen();
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminUsersScreen();
  }
}

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminCommentsScreen();
  }
}

class MyBlogsScreen extends StatelessWidget {
  const MyBlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthorMyBlogsScreen();
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MessagesListScreen();
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileEntryScreen();
  }
}
