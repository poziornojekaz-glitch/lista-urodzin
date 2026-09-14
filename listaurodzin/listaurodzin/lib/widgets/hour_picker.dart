import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HourPicker extends StatefulWidget {
  const HourPicker({
    super.key,
    this.width,
    this.height,
    this.initialHour,
    this.textColor,
    this.fontSize,
    required this.onHourChanged,
  });

  final double? width;
  final double? height;
  final int? initialHour;
  final Color? textColor;
  final double? fontSize;
  final ValueChanged<int> onHourChanged;

  @override
  State<HourPicker> createState() => _HourPickerState();
}

class _HourPickerState extends State<HourPicker> {
  // Lista godzin od 8:00 do 20:00
  final List<int> hours = List.generate(13, (index) => index + 8);
  late int selectedHour;

  @override
  void initState() {
    super.initState();
    int start = widget.initialHour ?? 8;
    selectedHour = hours.contains(start) ? start : 8;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CupertinoPicker(
        backgroundColor: Colors.transparent,
        itemExtent: 45,
        scrollController: FixedExtentScrollController(
          initialItem: hours.indexOf(selectedHour),
        ),
        onSelectedItemChanged: (index) {
          int picked = hours[index];
          setState(() => selectedHour = picked);
          widget.onHourChanged(picked);
        },
        children: hours
            .map((hour) => Center(
                  child: Text(
                    "$hour:00",
                    style: TextStyle(
                      color: widget.textColor ?? Colors.black,
                      fontSize: widget.fontSize ?? 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
