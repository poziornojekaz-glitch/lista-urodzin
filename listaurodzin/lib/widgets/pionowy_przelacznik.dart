import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PionowyPrzelacznik extends StatefulWidget {
  const PionowyPrzelacznik({
    super.key,
    this.width,
    this.height,
    required this.initialValue,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  final double? width;
  final double? height;
  final bool initialValue;
  final VoidCallback onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<PionowyPrzelacznik> createState() => _PionowyPrzelacznikState();
}

class _PionowyPrzelacznikState extends State<PionowyPrzelacznik> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(PionowyPrzelacznik oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  void _updateValue(bool newValue) {
    if (_currentValue != newValue) {
      setState(() {
        _currentValue = newValue;
      });
      HapticFeedback.lightImpact();
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _updateValue(!_currentValue),
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -7) {
          _updateValue(true);
        } else if (details.primaryDelta! > 7) {
          _updateValue(false);
        }
      },
      child: Container(
        width: widget.width ?? 40,
        height: widget.height ?? 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _currentValue
              ? (widget.activeColor ?? const Color(0xFF24D193))
              : (widget.inactiveColor ?? const Color(0xFFE0E3E7)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment:
                  _currentValue ? Alignment.topCenter : Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: (widget.width ?? 40) - 8,
                  height: (widget.width ?? 40) - 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
