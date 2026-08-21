import 'package:flutter/material.dart';

import '../theme.dart';
import 'ui.dart';

enum AppTab { garage, log, setup }

class TopBar extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final Widget? right;

  const TopBar({super.key, this.title, this.onBack, this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          SizedBox(width: 36, child: onBack != null ? TopBarIconButton(icon: Icons.chevron_left, onPressed: onBack!) : null),
          Expanded(
            child: title != null
                ? Center(child: AppText.name(title!, color: AppColors.ink, maxLines: 1))
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 36, child: Align(alignment: Alignment.centerRight, child: right)),
        ],
      ),
    );
  }
}

class _TabItem {
  final AppTab key;
  final String label;
  final IconData icon;
  const _TabItem(this.key, this.label, this.icon);
}

const _tabItems = [
  _TabItem(AppTab.garage, 'GARAGE', Icons.home_outlined),
  _TabItem(AppTab.log, 'LOG', Icons.article_outlined),
  _TabItem(AppTab.setup, 'SETUP', Icons.settings_outlined),
];

class AppTabBar extends StatelessWidget {
  final AppTab tab;
  final ValueChanged<AppTab> onChanged;

  const AppTabBar({super.key, required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.hairline, width: AppSpace.hairline)),
      ),
      child: Row(
        children: [
          for (final item in _tabItems)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(item.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 22, color: tab == item.key ? AppColors.accent : AppColors.tabOff),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: tab == item.key ? AppColors.accent : AppColors.tabOff,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
