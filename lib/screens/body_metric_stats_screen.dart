import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import 'package:flutter/cupertino.dart';
import '../database/app_database.dart';

class ChartPoint {
  final DateTime date;
  final double value;

  ChartPoint(this.date, this.value);
}

class BodyMetricStatsScreen extends StatefulWidget {
  final BodyMetric metric;

  const BodyMetricStatsScreen({
    super.key,
    required this.metric,
  });

  @override
  State<BodyMetricStatsScreen> createState() =>
      _BodyMetricStatsScreenState();
}

class _BodyMetricStatsScreenState
    extends State<BodyMetricStatsScreen> {
  final db = AppDatabase.instance;
  String range = "all";

  List<BodyMetricEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    entries = await (db.select(db.bodyMetricEntries)
      ..where((t) => t.metricId.equals(widget.metric.id))
      ..orderBy([
            (t) => OrderingTerm(
            expression: t.date,
            mode: OrderingMode.asc)
      ]))
        .get();

    setState(() {});
  }

  double _niceStep(double range) {
    if (range <= 0) return 1;

    const steps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 1000
    ];

    final target = range / 4;

    for (final s in steps) {
      if (target <= s) return s.toDouble();
    }

    return target.ceilToDouble();
  }

  List<FlSpot> _spotsFromPoints(List<ChartPoint> data) {
    return List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), data[i].value);
    });
  }

  List<String> _datesFromPoints(
      List<ChartPoint> data,
      String range,
      ) {

    return data.map((e) {

      switch (range) {

      /// только месяц
        case "year":
        case "all":
          return DateFormat("MMM", "ru").format(e.date);

      /// день + месяц
        default:
          return DateFormat("d MMM", "ru").format(e.date);
      }

    }).toList();
  }

  List<ChartPoint> _aggregate(List<BodyMetricEntry> data) {
    if (data.isEmpty) return [];

    Map<DateTime, List<double>> buckets = {};

    DateTime key;

    for (final e in data) {
      final d = e.date;

      switch (range) {
        case "week":
        case "month":
          key = DateTime(d.year, d.month, d.day);
          break;

        case "3m":
        case "6m":
          final weekStart =
          d.subtract(Duration(days: d.weekday - 1));
          key = DateTime(
              weekStart.year, weekStart.month, weekStart.day);
          break;

        case "year":
        case "all":
          key = DateTime(d.year, d.month);
          break;

        default:
          key = DateTime(d.year, d.month, d.day);
      }

      buckets.putIfAbsent(key, () => []).add(e.value);
    }

    final result = buckets.entries.map((entry) {
      final values = entry.value;

      final avg =
          values.reduce((a, b) => a + b) / values.length;

      return ChartPoint(entry.key, avg);
    }).toList();

    result.sort((a, b) => a.date.compareTo(b.date));

    /// ограничение до 9 точек
    if (result.length > 9) {
      final step = result.length / 9;
      List<ChartPoint> reduced = [];

      for (int i = 0; i < 9; i++) {
        final index = (i * step).floor();
        reduced.add(result[index]);
      }

      return reduced;
    }

    return result;
  }

  List<BodyMetricEntry> _filter(String range) {
    if (range == "all") return entries;

    final now = DateTime.now();

    Duration d;

    switch (range) {
      case "week":
        d = const Duration(days: 7);
        break;
      case "month":
        d = const Duration(days: 30);
        break;
      case "3m":
        d = const Duration(days: 90);
        break;
      case "6m":
        d = const Duration(days: 180);
        break;
      case "year":
        d = const Duration(days: 365);
        break;
      default:
        return entries;
    }

    return entries.where((e) {
      final diff = now.difference(e.date);
      return diff.inDays >= 0 && diff <= d;
    }).toList();
  }

  List<FlSpot> _spots(List<BodyMetricEntry> data) {
    return List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), data[i].value);
    });
  }

  List<String> _dates(List<BodyMetricEntry> data) {
    final formatter = DateFormat("d MMM", "ru");

    return data.map((e) => formatter.format(e.date)).toList();
  }

  Widget _miniFilter() {
    final items = ["week", "month", "3m", "6m", "year", "all"];

    final labels = {
      "week": "НЕД",
      "month": "МЕС",
      "3m": "3 МЕС",
      "6m": "6 МЕС",
      "year": "ГОД",
      "all": "ВСЕ",
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((key) {
        final selected = key == range;

        return GestureDetector(
          onTap: () {
            setState(() {
              range = key;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF363636)
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              labels[key]!,
              style: TextStyle(
                color:
                selected ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _addEntry() async {
    final controller = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Material(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// полоска сверху
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Добавить измерение",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: controller,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: "Введите значение",
                            filled: true,
                            fillColor: const Color(0xFFF0F0F0),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () async {

                            DateTime tempDate = selectedDate;

                            await showCupertinoModalPopup(
                              context: context,
                              builder: (ctx) {
                                return Container(
                                  height: 370,
                                  color: Colors.white,
                                  child: Column(
                                    children: [

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: CupertinoButton(
                                          child: Text(
                                            "Готово",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF363636),
                                            ),
                                          ),
                                          onPressed: () {

                                            setModalState(() {
                                              selectedDate = tempDate;
                                            });

                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                      ),

                                      Expanded(
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          initialDateTime: selectedDate,
                                          minimumDate: DateTime(2020),
                                          maximumDate: DateTime(2100),

                                          onDateTimeChanged: (date) {
                                            tempDate = date;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },

                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              DateFormat('dd.MM.yyyy').format(selectedDate),
                              style: GoogleFonts.inter(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              final value = double.tryParse(
                                controller.text.replaceAll(',', '.'),
                              );

                              if (value == null) return;

                              await db.into(
                                db.bodyMetricEntries,
                              ).insert(
                                BodyMetricEntriesCompanion.insert(
                                  metricId: widget.metric.id,
                                  value: value,
                                  date: selectedDate,
                                ),
                              );

                              Navigator.pop(context);
                              _load();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                              const Color(0xFF363636),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Сохранить',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<FlSpot> get spots {
    return List.generate(entries.length, (i) {
      return FlSpot(
        i.toDouble(),
        entries[i].value,
      );
    });
  }

  Widget _chart(List<BodyMetricEntry> data) {

    final aggregated = _aggregate(data);

    final spots = aggregated.isEmpty
        ? [const FlSpot(0, 0)]
        : _spotsFromPoints(aggregated);

    final dates = _datesFromPoints(
      aggregated,
      range,
    );

    final maxYRaw = spots.isEmpty
        ? 0.0
        : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    final minYRaw = spots.isEmpty
        ? 0.0
        : spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);

    final yPadding = (maxYRaw - minYRaw) * 0.15;

    final maxY = maxYRaw + yPadding;
    final minY = (minYRaw - yPadding) < 0.0 ? 0.0 : minYRaw - yPadding;

    final yRange = maxY - minY;
    final yStep = _niceStep(yRange);

    final fixedMinY = (minY / yStep).floor() * yStep;
    final fixedMaxY = (maxY / yStep).ceil() * yStep;

    final maxX = data.isEmpty ? 1.0 : (spots.length - 1).toDouble();
    const xPadding = 0.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            "Динамика",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 280,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 28,
                child: _miniFilter(),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: fixedMinY,
                    maxY: fixedMaxY,
                    minX: 0 - xPadding,
                    maxX: maxX + xPadding,

                    clipData: const FlClipData.none(),

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: yStep,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0x20000000),
                          strokeWidth: 1,
                        );
                      },
                    ),

                    borderData: FlBorderData(show: false),

                    lineTouchData: LineTouchData(
                      enabled: false,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        tooltipMargin: 10,
                        tooltipRoundedRadius: 0,
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            return LineTooltipItem(
                              spot.y.toStringAsFixed(1),
                              const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF363636),
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    showingTooltipIndicators: spots.length < 2
                        ? []
                        : List.generate(
                      spots.length,
                          (i) => ShowingTooltipIndicators([
                        LineBarSpot(
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 3,
                            color: const Color(0xFF363636),
                            dotData: FlDotData(show: true),
                          ),
                          0,
                          spots[i],
                        ),
                      ]),
                    ),

                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: yStep,
                          getTitlesWidget: (value, meta) {
                            if (value < fixedMinY || value > fixedMaxY) {
                              return const SizedBox();
                            }

                            return Text(
                              value.round().toString(),
                              style: const TextStyle(fontSize: 11),
                            );
                          },
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: spots.length <= 1
                              ? 1
                              : (spots.length / 4).ceilToDouble(),
                          getTitlesWidget: (value, meta) {
                            final i = value.round();

                            if (i < 0 || i >= dates.length) {
                              return const SizedBox();
                            }

                            if (value > (dates.length - 1)) {
                              return const SizedBox();
                            }

                            if (value <= meta.min + 0.0001) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                dates[i],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),

                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: const Color(0xFF363636),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(range);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.metric.name,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// Контент
            Expanded(
              child: entries.isEmpty
                  ? Center(
                child: Text(
                  "Нет измерений",
                  style: GoogleFonts.inter(),
                ),
              )
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _chart(filtered),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsetsGeometry.only(left: 15),

                    child: Text(
                      "История",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),


                  const SizedBox(height: 12),

                  ...filtered.reversed.map(
                        (e) => Dismissible(
                      key: Key(e.id.toString()),
                      direction: DismissDirection.endToStart,

                      background: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),

                      onDismissed: (_) async {
                        setState(() {
                          entries.removeWhere(
                                  (item) => item.id == e.id);
                        });

                        await (db.delete(db.bodyMetricEntries)
                          ..where((tbl) =>
                              tbl.id.equals(e.id)))
                            .go();

                        _load();
                      },

                      child: Container(
                        margin:
                        const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('dd.MM.yyyy')
                                    .format(e.date),
                                style: GoogleFonts.inter(),
                              ),
                            ),
                            Text(
                              e.value
                                  .toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// КНОПКА (как у тебя в тренировках)
            Center(
              child: SizedBox(
                width: 317,
                height: 60,
                child: ElevatedButton(
                  onPressed: _addEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Color(0xFF363636),
                      ),
                    ),
                  ),
                  child: Text(
                    "Добавить измерение",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF363636),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}