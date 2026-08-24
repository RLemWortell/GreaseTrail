import 'package:flutter/material.dart';

import '../theme.dart';

enum AppTab { home, log, setup }

class _TabItem {
  final AppTab key;
  final String label;
  final IconData icon;
  final IconData iconOn;
  const _TabItem(this.key, this.label, this.icon, this.iconOn);
}

const _tabItems = [
  _TabItem(AppTab.home, 'Garage', Icons.home_outlined, Icons.home),
  _TabItem(AppTab.log, 'Log', Icons.description_outlined, Icons.description),
  _TabItem(AppTab.setup, 'Setup', Icons.settings_outlined, Icons.settings),
];

class AppTabBar extends StatelessWidget {
  final AppTab tab;
  final ValueChanged<AppTab> onChanged;

  const AppTabBar({super.key, required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: bottomInset > 10 ? bottomInset : 10),
      color: c.surface,
      child: Row(
        children: [
          for (final item in _tabItems)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(item.key),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab == item.key ? item.iconOn : item.icon, size: 22, color: tab == item.key ? c.accent : c.muted),
                    const SizedBox(height: 4),
                    AppText.tab(item.label, color: tab == item.key ? c.accent : c.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
