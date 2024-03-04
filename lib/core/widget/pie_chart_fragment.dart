import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

class PieChartFragment<K, V> extends StatefulWidget {

  final String title;

  final String subtitle;

  final List<K> keys;

  final List<V> values;

  final double width, height;

  final int entries;

  final String Function(K) getName;

  final String Function(K, V) getDescription;

  final double Function(K, V) toDouble;

  final Widget Function(K, Color)? getIcon;

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
    if (keys.isEmpty) {
      return const Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: widget.title != "",
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Visibility(
                visible: widget.subtitle != "",
                child: Text(
                  widget.subtitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
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