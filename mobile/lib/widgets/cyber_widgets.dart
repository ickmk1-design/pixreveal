import 'package:flutter/material.dart';
import '../utils/cyber_theme.dart';

enum CyberButtonStyle { primary, secondary, ghost }

/// Refined neon button with hierarchy support.
class CyberButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final CyberButtonStyle style;
  final double width;

  const CyberButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.style = CyberButtonStyle.primary,
    this.width = 280,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: _buildByStyle(),
      ),
    );
  }

  Widget _buildByStyle() {
    switch (widget.style) {
      case CyberButtonStyle.primary:
        return _buildPrimary();
      case CyberButtonStyle.secondary:
        return _buildSecondary();
      case CyberButtonStyle.ghost:
        return _buildGhost();
    }
  }

  Widget _buildPrimary() {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Cyber.accentPink.withValues(alpha: 0.9),
            Cyber.accentPink.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Cyber.accentPink.withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildContent(Cyber.textPrimary),
    );
  }

  Widget _buildSecondary() {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Cyber.bgSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Cyber.accentCyan.withValues(alpha: 0.4), width: 1.5),
      ),
      child: _buildContent(Cyber.accentCyan),
    );
  }

  Widget _buildGhost() {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Cyber.borderStrong, width: 1),
      ),
      child: _buildContent(Cyber.textSecondary),
    );
  }

  Widget _buildContent(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: color, size: 18),
          const SizedBox(width: 10),
        ],
        Text(widget.text.toUpperCase(),
          style: Cyber.label(size: 14, color: color)),
      ],
    );
  }
}

/// Clean dark card with subtle border. No glassmorphism by default.
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool selected;
  final Color accentColor;

  const CyberCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
    this.accentColor = Cyber.accentCyan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Cyber.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accentColor : Cyber.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: child,
      ),
    );
  }
}

/// Section header with subtle accent line
class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(text.toUpperCase(),
            style: Cyber.label(size: 11, color: Cyber.accentCyan, weight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: Cyber.borderSubtle)),
        ],
      ),
    );
  }
}

/// Simple list row item with icon, label, value/action
class CyberListRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CyberListRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Cyber.borderSubtle)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Cyber.accentCyan, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: Cyber.body(size: 15, color: Cyber.textPrimary)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
