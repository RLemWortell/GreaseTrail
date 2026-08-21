import 'package:flutter/material.dart';

import '../theme.dart';

class AppScreen extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppScreen({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpace.side),
      child: child,
    );
  }
}

class AppCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.children, this.margin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSpace.radius),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children))
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
    return margin != null ? Padding(padding: margin!, child: content) : content;
  }
}

class StatusDot extends StatelessWidget {
  final DueLevel level;
  const StatusDot({super.key, this.level = DueLevel.none});

  @override
  Widget build(BuildContext context) {
    final color = dotColor(level);
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: level == DueLevel.ok ? Border.all(color: AppColors.faint, width: 1) : null,
      ),
    );
  }
}

class TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const TopBarIconButton({super.key, required this.icon, required this.onPressed, this.color = AppColors.ink, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 24,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

class PlusButton extends StatelessWidget {
  final VoidCallback onPressed;
  const PlusButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.ink),
        ),
        child: const Icon(Icons.add, size: 18, color: AppColors.ink),
      ),
    );
  }
}

/// A labelled, right-aligned text field with a hairline underline — mirrors the
/// `Field` component from the original app (label left, value+unit right).
class AppField extends StatefulWidget {
  final String label;
  final String value;
  final String? unit;
  final String? placeholder;
  final bool emphasis;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBlur;

  const AppField({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.placeholder,
    this.emphasis = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onBlur,
  });

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) widget.onBlur?.call();
    });
  }

  @override
  void didUpdateWidget(AppField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.fieldY),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: widget.emphasis ? AppColors.rule : AppColors.hairline, width: AppSpace.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          AppText.meta(widget.label, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    keyboardType: widget.keyboardType,
                    textAlign: TextAlign.right,
                    style: AppTypography.row.copyWith(color: AppColors.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: widget.placeholder,
                      hintStyle: AppTypography.row.copyWith(color: AppColors.faint),
                    ),
                  ),
                ),
                if (widget.unit != null) ...[
                  const SizedBox(width: 5),
                  AppText.meta(widget.unit!, color: AppColors.muted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OptionList<T> extends StatelessWidget {
  final List<T> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String Function(T) getLabel;

  const OptionList({super.key, required this.options, required this.value, required this.onChanged, required this.getLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final o in options)
          InkWell(
            onTap: () => onChanged(o),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              constraints: const BoxConstraints(minHeight: 48),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.row(getLabel(o), color: AppColors.ink),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: o == value ? AppColors.ink : null,
                      border: o == value ? null : Border.all(color: AppColors.faint),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool destructive;

  const ActionRow({super.key, required this.label, required this.onPressed, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.only(top: 15),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.rule, width: AppSpace.hairline)),
        ),
        child: AppText.body(label, color: destructive ? AppColors.accent : AppColors.ink, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class VehicleSearchField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String placeholder;

  const VehicleSearchField({super.key, required this.value, required this.onChanged, this.placeholder = 'Search vehicles.'});

  @override
  State<VehicleSearchField> createState() => _VehicleSearchFieldState();
}

class _VehicleSearchFieldState extends State<VehicleSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(VehicleSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 16, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: AppTypography.body.copyWith(color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: AppTypography.body.copyWith(color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
