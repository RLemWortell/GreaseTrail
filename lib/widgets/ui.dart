import 'dart:io';

import 'package:flutter/material.dart';

import '../format.dart';
import '../models.dart';
import '../theme.dart';

class Label extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? margin;
  const Label(this.text, {super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final child = AppText.label(text, color: c.muted);
    return margin != null ? Padding(padding: margin!, child: child) : child;
  }
}

class AppCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({super.key, this.children = const [], this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final content = Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(AppSpace.radius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
    return margin != null ? Padding(padding: margin!, child: content) : content;
  }
}

class AppDivider extends StatelessWidget {
  final bool inset;
  const AppDivider({super.key, this.inset = true});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      height: AppSpace.hairline,
      margin: EdgeInsets.symmetric(horizontal: inset ? AppSpace.cardPad : 0),
      color: c.hairline,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 8), child: AppText.label(text, color: c.muted)),
        Container(height: AppSpace.hairline, color: c.hairline),
      ],
    );
  }
}

class SquareButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const SquareButton({super.key, required this.onPressed, this.icon = Icons.add});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
        child: Icon(icon, size: 20, color: c.ink),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onRightPress;
  final IconData? rightIcon;
  final String? rightLabel;
  final String? subtitle;

  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onRightPress,
    this.rightIcon = Icons.add,
    this.rightLabel,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    Widget right;
    if (onRightPress != null && rightIcon != null) {
      right = SquareButton(icon: rightIcon!, onPressed: onRightPress!);
    } else if (onRightPress != null && rightLabel != null) {
      right = GestureDetector(onTap: onRightPress, child: AppText.label(rightLabel!, color: c.ink));
    } else {
      right = const SizedBox(width: 36);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.side, 4, AppSpace.side, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onBack != null)
                  InkResponse(onTap: onBack, radius: 22, child: Icon(Icons.chevron_left, size: 24, color: c.ink))
                else
                  AppText.date(formatDateHeader(), color: c.muted),
                right,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.only(top: 6), child: AppText.display(title, color: c.ink)),
          if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 4), child: AppText.label(subtitle!, color: c.muted)),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final String? rightLabel;
  final VoidCallback? onRightPress;
  final String? subtitle;

  const TopBar({super.key, required this.title, this.onBack, this.rightLabel, this.onRightPress, this.subtitle});

  @override
  Widget build(BuildContext context) => ScreenHeader(
        title: title,
        onBack: onBack,
        onRightPress: onRightPress,
        rightIcon: null,
        rightLabel: rightLabel,
        subtitle: subtitle,
      );
}

class AppSearchBar extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String placeholder;

  const AppSearchBar({super.key, required this.value, required this.onChanged, this.placeholder = 'Search'});

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(AppSearchBar oldWidget) {
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
    final c = AppColors.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, size: 15, color: c.faint),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  style: AppTypography.body.copyWith(color: c.ink),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: AppTypography.body.copyWith(color: c.faint),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: AppSpace.hairline, color: c.hairline),
      ],
    );
  }
}

class TypeIcon extends StatelessWidget {
  final String type;
  final double size;
  final String? photo;
  final Color? color;

  const TypeIcon({super.key, required this.type, this.size = 36, this.photo, this.color});

  static const _icons = {
    'motorcycle': Icons.motorcycle,
    'car': Icons.directions_car,
    'bicycle': Icons.pedal_bike,
    'scooter': Icons.moped,
  };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          color: c.photo,
          child: Image.file(File(photo!), width: size, height: size, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color ?? c.iconBg, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Icon(_icons[type] ?? Icons.directions_car, size: size * 0.55, color: c.iconFg),
    );
  }
}

/// A tappable card row: optional due-status dot, flexible left/right content
/// (either a String, rendered in the row/meta style, or a widget), optional
/// chevron, and a divider below unless this is the last row in the card.
class CardRow extends StatelessWidget {
  final Object left;
  final Object? right;
  final DueLevel? dot;
  final Color? dotColor;
  final VoidCallback? onPress;
  final bool divider;
  final bool chevron;

  const CardRow({
    super.key,
    required this.left,
    this.right,
    this.dot,
    this.dotColor,
    this.onPress,
    this.divider = true,
    this.chevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final leftWidget = left is String ? AppText.row(left as String, color: c.ink) : left as Widget;
    final rightWidget = right == null ? null : (right is String ? AppText.meta(right as String, color: c.muted) : right as Widget);
    final dotDeco = dotColor != null ? BoxDecoration(shape: BoxShape.circle, color: dotColor) : (dot != null ? dotDecoration(dot!, c) : null);

    final content = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.rowY),
      child: Row(
        children: [
          if (dotDeco != null) ...[
            Container(width: 7, height: 7, decoration: dotDeco),
            const SizedBox(width: 12),
          ],
          Expanded(child: leftWidget),
          if (rightWidget != null) ...[const SizedBox(width: 12), rightWidget],
          if (chevron) ...[const SizedBox(width: 8), Icon(Icons.chevron_right, size: 16, color: c.faint)],
        ],
      ),
    );

    return Column(
      children: [
        onPress != null ? InkWell(onTap: onPress, child: content) : content,
        if (divider) const AppDivider(),
      ],
    );
  }
}

/// A labelled row with a 3-way pill choice ([statusOptions]) for checklist
/// items where a plain checkbox can't say whether something was found fine,
/// flagged, or actually serviced. Tapping the active pill clears it back to
/// unset.
class StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool last;

  const StatusRow({super.key, required this.label, required this.value, required this.onChanged, this.last = false});

  Color _fillFor(String option, AppColors c) => switch (option) {
        'Attention' => c.soon,
        'Replaced' => c.accent,
        _ => c.dotOff,
      };

  Color _textFor(String option, AppColors c) => option == 'OK' ? c.ink : c.iconFg;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.rowY),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.row(label, color: c.ink),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < statusOptions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _StatusPill(
                        label: statusOptions[i],
                        selected: value == statusOptions[i],
                        fill: _fillFor(statusOptions[i], c),
                        textColor: _textFor(statusOptions[i], c),
                        onTap: () => onChanged(value == statusOptions[i] ? '' : statusOptions[i]),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (!last) const AppDivider(),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color fill;
  final Color textColor;
  final VoidCallback onTap;

  const _StatusPill({required this.label, required this.selected, required this.fill, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected ? fill : Colors.transparent,
          border: selected ? null : Border.all(color: c.border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.small.copyWith(color: selected ? textColor : c.muted, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class CheckRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onToggle;
  final bool last;

  const CheckRow({super.key, required this.label, required this.checked, required this.onToggle, this.last = false});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.rowY),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: AppText.row(label, color: c.ink)),
                const SizedBox(width: 12),
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: checked ? null : Border.all(color: c.border),
                    color: checked ? c.accent : Colors.transparent,
                  ),
                  child: checked ? Icon(Icons.check, size: 14, color: c.iconFg) : null,
                ),
              ],
            ),
          ),
        ),
        if (!last) const AppDivider(),
      ],
    );
  }
}

/// A labelled, right-aligned text field with a hairline divider below unless
/// [last] is set — mirrors the original `Field` component.
class AppField extends StatefulWidget {
  final String label;
  final String value;
  final String? unit;
  final String? placeholder;
  final bool last;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBlur;

  const AppField({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.placeholder,
    this.last = false,
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
    final c = AppColors.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.fieldY),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText.meta(widget.label, color: c.muted),
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
                        style: AppTypography.row.copyWith(color: c.ink),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: widget.placeholder,
                          hintStyle: AppTypography.row.copyWith(color: c.faint),
                        ),
                      ),
                    ),
                    if (widget.unit != null) ...[
                      const SizedBox(width: 5),
                      AppText.meta(widget.unit!, color: c.muted),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!widget.last) const AppDivider(),
      ],
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
    final c = AppColors.of(context);
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          Column(
            children: [
              InkWell(
                onTap: () => onChanged(options[i]),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.row(getLabel(options[i]), color: c.ink),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: options[i] == value ? c.accent : null,
                          border: options[i] == value ? null : Border.all(color: c.dotOff),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < options.length - 1) const AppDivider(),
            ],
          ),
      ],
    );
  }
}

/// A full-width filled call-to-action button. Disabled (dimmed, non-tappable)
/// when [onPressed] is null.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PrimaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: enabled ? c.accent : c.hairline,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: enabled ? c.iconFg : c.faint,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ),
      ),
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
    final c = AppColors.of(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.label.copyWith(
            color: destructive ? c.alert : c.accent,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

/// A row of tappable color swatches, used by the app-wide and per-vehicle
/// accent color pickers. [value] is the currently selected color, if any of
/// [colors] matches it.
class ColorSwatchPicker extends StatelessWidget {
  final List<Color> colors;
  final Color? value;
  final ValueChanged<Color> onSelected;

  const ColorSwatchPicker({super.key, required this.colors, required this.value, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.rowY),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final swatch in colors)
            GestureDetector(
              onTap: () => onSelected(swatch),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle, color: swatch),
                alignment: Alignment.center,
                child: value == swatch ? Icon(Icons.check, size: 16, color: c.iconFg) : null,
              ),
            ),
        ],
      ),
    );
  }
}
