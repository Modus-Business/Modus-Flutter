import 'package:flutter/material.dart';

import '../../../../component/layout/responsive_layout.dart';

enum StudentNavItem { classes, settings }

class StudentShell extends StatelessWidget {
  const StudentShell({
    super.key,
    required this.selectedItem,
    required this.body,
    required this.onClassesTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    required this.appBarTitle,
    this.onPrimaryActionTap,
    this.primaryActionIcon,
    this.showProfileAvatar = true,
  });

  final StudentNavItem selectedItem;
  final Widget body;
  final VoidCallback onClassesTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;
  final Widget appBarTitle;
  final VoidCallback? onPrimaryActionTap;
  final IconData? primaryActionIcon;
  final bool showProfileAvatar;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveLayout.of(context) == ResponsiveSize.mobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      drawer: Drawer(
        width: 304,
        shape: const RoundedRectangleBorder(),
        child: _DrawerContent(
          selectedItem: selectedItem,
          onClassesTap: onClassesTap,
          onSettingsTap: onSettingsTap,
          onLogoutTap: onLogoutTap,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 76,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFD8E1F5))),
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Color(0xFF26324B),
                          size: 30,
                        ),
                      );
                    },
                  ),
                  if (isMobile)
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 6),
                          Image.asset(
                            'assets/images/modus_text_logo.png',
                            width: 108,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: appBarTitle),
                        ],
                      ),
                    )
                  else
                    Expanded(child: appBarTitle),
                  if (onPrimaryActionTap != null && primaryActionIcon != null)
                    IconButton(
                      onPressed: onPrimaryActionTap,
                      icon: Icon(
                        primaryActionIcon,
                        color: const Color(0xFF26324B),
                        size: 30,
                      ),
                    ),
                  if (showProfileAvatar)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFE8EEFF), Color(0xFFD6E0FF)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _DrawerContent extends StatelessWidget {
  const _DrawerContent({
    required this.selectedItem,
    required this.onClassesTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  final StudentNavItem selectedItem;
  final VoidCallback onClassesTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.menu_rounded, size: 30),
          ),
          const SizedBox(height: 24),
          _DrawerButton(
            label: '등록한 수업',
            icon: Icons.fact_check_outlined,
            isSelected: selectedItem == StudentNavItem.classes,
            onTap: onClassesTap,
          ),
          const SizedBox(height: 8),
          _DrawerButton(
            label: '설정',
            icon: Icons.settings_outlined,
            isSelected: selectedItem == StudentNavItem.settings,
            onTap: onSettingsTap,
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onLogoutTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: const BorderSide(color: Color(0xFFD5DDF1)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

class _DrawerButton extends StatelessWidget {
  const _DrawerButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF5D76E8)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF5D76E8)
                    : const Color(0xFF4A556F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
