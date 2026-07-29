import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_api/src/core/model/stateful_data.dart';
import 'package:my_api/src/core/widget/home_card.dart';

const List<Color> _itemColors = [
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.brown,
  Colors.blueAccent,
  Colors.lightBlueAccent,
  Colors.cyanAccent,
  Colors.tealAccent,
  Colors.greenAccent,
  Colors.lightGreenAccent,
  Colors.limeAccent,
  Colors.yellowAccent,
  Colors.amberAccent,
  Colors.orangeAccent,
  Colors.deepOrangeAccent,
  Colors.redAccent,
  Colors.pinkAccent,
  Colors.purpleAccent,
  Colors.deepPurpleAccent,
  Colors.indigoAccent,
];

/// Displays paired keys and values as a pie chart with a legend.
class PieChartFragment<K, V> extends StatefulWidget {

  /// Chart heading.
  final String title;

  /// Optional chart subheading.
  final String subtitle;

  /// Items represented by the chart sections.
  final List<K> keys;

  /// Values paired by index with [keys].
  final List<V> values;

  /// Available chart width and height.
  final double width, height;

  /// Maximum number of entries to display.
  final int entries;

  /// Returns the label for a key.
  final String Function(K) getName;

  /// Returns the legend description for a key-value pair.
  final String Function(K, V) getDescription;

  /// Converts a key-value pair to a chart value.
  final double Function(K, V) toDouble;

  /// Optionally builds a legend icon with its section color.
  final Widget Function(K, Color)? getIcon;

  /// State used by the enclosing [HomeCard].
  final StatefulDataState state;

  /// Creates a pie chart and legend.
  const PieChartFragment({
    super.key,
    this.title = "",
    this.subtitle = "",
    required this.keys,
    required this.values,
    required this.getName,
    required this.getDescription,
    required this.toDouble,
    required this.width,
    required this.height,
    this.entries = 5,
    this.getIcon,
    required this.state,
  });

  @override
  State createState() => _PieChartFragmentState<K, V>();
}

class _PieChartFragmentState<K, V> extends State<PieChartFragment<K, V>> {

  int touchedIndex = -1;

  int get entries => math.min(widget.keys.length, widget.entries);

  List<K> get keys => widget.keys.sublist(0, entries);

  List<V> get values => widget.values.sublist(0, entries);

  void onPieChartTouch(FlTouchEvent event, pieTouchResponse) {
    setState(() {
      if (!event.isInterestedForInteractions ||
          pieTouchResponse == null ||
          pieTouchResponse.touchedSection == null) {
        touchedIndex = -1;
        return;
      }
      touchedIndex = pieTouchResponse
          .touchedSection!.touchedSectionIndex;
    });
  }

  List<PieChartSectionData> showingSections() {
    assert(keys.length == values.length);
    final List<PieChartSectionData> sections = [];
    for(int i=0; i < keys.length; i++) {
      final k = keys[i];
      final v = values[i];
      final isTouched = (i == touchedIndex);
      final radius = (isTouched ? 1 : 0.6) * math.min(widget.width, widget.height) * 0.3;
      sections.add(PieChartSectionData(
        value: widget.toDouble(k ,v),
        title: widget.getName(k),
        color: _itemColors[i % _itemColors.length],
        radius: radius,
      ));
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: widget.title,
      subtitle: widget.subtitle,
      state: widget.state,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: onPieChartTouch,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 20,
                sections: showingSections(),
              ),
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: keys.length,
          itemBuilder: (context, index) {
            final key = keys[index];
            final value = values[index];
            return ListTile(
              leading: widget.getIcon == null ? const Icon(Icons.circle) : widget.getIcon!(key, _itemColors[index % _itemColors.length]),
              title: Text(widget.getName(key)),
              subtitle: Text(widget.getDescription(key, value)),
            );
          },
        ),
      ],
    );
  }
}
