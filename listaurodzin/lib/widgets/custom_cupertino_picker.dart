import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomCupertinoPicker extends StatefulWidget {
  const CustomCupertinoPicker({
    super.key,
    this.width,
    this.height,
    this.initialDate,
    this.textColor,
    this.backgroundColor,
    this.fontSize,
    this.languageCode = 'pl',
    required this.showYear,
    required this.onDateChanged,
  });

  final double? width;
  final double? height;
  final DateTime? initialDate;
  final Color? textColor;
  final Color? backgroundColor;
  final double? fontSize;
  final String languageCode;
  final bool showYear;
  final ValueChanged<DateTime> onDateChanged;

  @override
  State<CustomCupertinoPicker> createState() => _CustomCupertinoPickerState();
}

class _CustomCupertinoPickerState extends State<CustomCupertinoPicker> {
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  final Map<String, List<String>> _localizedMonths = {
    'pl': [
      'stycznia',
      'lutego',
      'marca',
      'kwietnia',
      'maja',
      'czerwca',
      'lipca',
      'sierpnia',
      'września',
      'października',
      'listopada',
      'grudnia'
    ],
    'ru': [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ],
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],
    'de': [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember'
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeInternalState();
  }

  void _initializeInternalState() {
    final now = DateTime.now();

    bool isDefault = widget.initialDate != null &&
        widget.initialDate!.year == 2000 &&
        widget.initialDate!.month == 1 &&
        widget.initialDate!.day == 1;

    if (widget.initialDate == null || isDefault) {
      _selectedDay = now.day;
      _selectedMonth = now.month;
      _selectedYear = 2000;
    } else {
      _selectedDay = widget.initialDate!.day;
      _selectedMonth = widget.initialDate!.month;
      _selectedYear = widget.initialDate!.year;
    }

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearController =
        FixedExtentScrollController(initialItem: _selectedYear - 1900);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateChanged(DateTime(_selectedYear, _selectedMonth, _selectedDay));
    });
  }

  List<String> _getCurrentMonths() {
    return _localizedMonths[widget.languageCode] ?? _localizedMonths['en']!;
  }

  void _validateAndEmit() {
    final now = DateTime.now();
    int daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;

    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
      _dayController.animateToItem(
        _selectedDay - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    DateTime selectedFullDate =
        DateTime(_selectedYear, _selectedMonth, _selectedDay);

    if (widget.showYear && selectedFullDate.isAfter(now)) {
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;

      _yearController.animateToItem(
        _selectedYear - 1900,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      _monthController.animateToItem(
        _selectedMonth - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      _dayController.animateToItem(
        _selectedDay - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );

      selectedFullDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    }

    HapticFeedback.selectionClick();
    widget.onDateChanged(selectedFullDate);
  }

  @override
  Widget build(BuildContext context) {
    final months = _getCurrentMonths();
    final TextStyle textStyle = TextStyle(
      color: widget.textColor ?? Colors.black,
      fontSize: (widget.fontSize ?? 18.0) * (widget.showYear ? 0.9 : 1.0),
      fontWeight: FontWeight.bold,
    );

    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.backgroundColor ?? Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              scrollController: _dayController,
              itemExtent: 45,
              looping: true,
              onSelectedItemChanged: (i) {
                setState(() => _selectedDay = i + 1);
                _validateAndEmit();
              },
              children: List.generate(
                31,
                (i) => Center(child: Text('${i + 1}', style: textStyle)),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: CupertinoPicker(
              scrollController: _monthController,
              itemExtent: 45,
              looping: true,
              onSelectedItemChanged: (i) {
                setState(() => _selectedMonth = i + 1);
                _validateAndEmit();
              },
              children: months
                  .map(
                    (name) => Center(
                      child: Text(
                        name,
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            flex: 3,
            child: widget.showYear
                ? CupertinoPicker(
                    scrollController: _yearController,
                    itemExtent: 45,
                    onSelectedItemChanged: (i) {
                      setState(() => _selectedYear = 1900 + i);
                      _validateAndEmit();
                    },
                    children: List.generate(
                      151,
                      (i) => Center(child: Text('${1900 + i}', style: textStyle)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
