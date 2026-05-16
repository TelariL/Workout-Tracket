import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:intl/intl.dart';

import '../database/app_database.dart';
import '../repository/training_repository.dart';

class ChartPoint {
  final DateTime date;
  final double value;

  ChartPoint(this.date, this.value);
}

class ExerciseStatsScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseStatsScreen({super.key, required this.exercise});

  @override
  State<ExerciseStatsScreen> createState() => _ExerciseStatsScreenState();
}

class _ExerciseStatsScreenState extends State<ExerciseStatsScreen> {
  late TrainingRepository repo;

  List<Map<String, dynamic>> stats = [];

  String volumeRange = "all";
  String weightRange = "all";

  @override
  void initState() {
    super.initState();
    repo = TrainingRepository(AppDatabase());
    _load();
  }

  Future<void> _load() async {
    final data = await repo.getExerciseStats(widget.exercise.id);
    setState(() => stats = data);
  }

  List<ChartPoint> _aggregate(
      List<Map<String, dynamic>> data,
      String key,
      String range,
      ) {
    if (data.isEmpty) return [];

    Map<DateTime, List<double>> buckets = {};

    DateTime bucketKey;

    for (final e in data) {
      final date = e['date'] as DateTime;
      final value = (e[key] as num?)?.toDouble() ?? 0;

      switch (range) {

      /// день
        case "week":
        case "month":
          bucketKey = DateTime(
            date.year,
            date.month,
            date.day,
          );
          break;

      /// неделя
        case "3m":
        case "6m":
          final weekStart =
          date.subtract(Duration(days: date.weekday - 1));

          bucketKey = DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day,
          );
          break;

      /// месяц
        case "year":
        case "all":
          bucketKey = DateTime(
            date.year,
            date.month,
          );
          break;

        default:
          bucketKey = DateTime(
            date.year,
            date.month,
            date.day,
          );
      }

      buckets.putIfAbsent(bucketKey, () => []);
      buckets[bucketKey]!.add(value);
    }

    final result = buckets.entries.map((entry) {
      final values = entry.value;

      final avg =
          values.reduce((a, b) => a + b) / values.length;

      return ChartPoint(entry.key, avg);
    }).toList();

    result.sort((a, b) => a.date.compareTo(b.date));

    /// максимум 9 точек
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

  List<FlSpot> _spotsFromPoints(List<ChartPoint> data) {
    return List.generate(data.length, (i) {
      return FlSpot(
        i.toDouble(),
        data[i].value,
      );
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

  List<Map<String, dynamic>> _filter(String range) {
    if (range == "all") return stats;

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
        return stats;
    }

    return stats.where((e) {
      final date = e['date'] as DateTime;
      final diff = now.difference(date);
      return diff.inDays >= 0 && diff <= d;
    }).toList();
  }

  List<FlSpot> _spots(List<Map<String, dynamic>> data, String key) {
    return List.generate(data.length, (i) {
      return FlSpot(
        i.toDouble(),
        (data[i][key] as num?)?.toDouble() ?? 0,
      );
    });
  }

  List<String> _dates(List<Map<String, dynamic>> data) {
    final formatter = DateFormat("d MMM", "ru");

    return data.map((e) {
      final d = e['date'] as DateTime;
      return formatter.format(d);
    }).toList();
  }

  Widget _miniFilter(String selected, Function(String) onSelect) {
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
        final isSelected = selected == key;

        return GestureDetector(
          onTap: () => onSelect(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF363636) : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              labels[key]!,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  double _niceStep(double range) {
    if (range <= 0) return 1;

    const steps = [
      1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 5000, 10000
    ];

    final target = range / 4;

    for (final s in steps) {
      if (target <= s) return s.toDouble();
    }

    return target.ceilToDouble();
  }

  Widget _chart({
    required String title,
    required List<FlSpot> spots,
    required List<String> dates,
    required String range,
    required Function(String) onRangeChanged,
  }) {

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

    final maxX = spots.isEmpty ? 1.0 : (spots.length - 1).toDouble();
    const xPadding = 0.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(left: 14),
          child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )
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
                child: _miniFilter(range, onRangeChanged),
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
                      horizontalInterval: yStep, // или fixed
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Color(0x20000000), // чуть темнее = видно нормально
                          strokeWidth: 1,
                        );
                      },
                    ),

                    borderData: FlBorderData(show: false),

                    lineTouchData: LineTouchData(
                      enabled: false,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.transparent, // 🔥 убираем фон полностью
                        tooltipPadding: EdgeInsets.zero,
                        tooltipMargin: 10,
                        tooltipRoundedRadius: 0,

                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            return LineTooltipItem(
                              spot.y.toStringAsFixed(0),
                              const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF363636), // цвет как у линии
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),

                    showingTooltipIndicators: List.generate(
                      spots.length,
                          (i) => ShowingTooltipIndicators([
                        LineBarSpot(
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 3,
                            color: const Color(0xFF363636),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: const Color(0xFF363636),
                                );
                              },
                            ),
                            isStrokeCapRound: true,
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
                          interval: spots.length <= 1 ? 1 : (spots.length / 4).ceilToDouble(),
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
                        spots: spots.isEmpty ? [FlSpot(0, 0)] : spots,
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

  Widget _bestStats() {
    double maxWeight = 0;
    double maxVolume = 0;

    for (final s in stats) {
      final v = (s['volume'] as num?)?.toDouble() ?? 0;
      final w = (s['avgWeight'] as num?)?.toDouble() ?? 0;

      if (w > maxWeight) maxWeight = w;
      if (v > maxVolume) maxVolume = v;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(left: 14),
          child:Text(
            "Лучшие показатели",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity, // 🔥 ВОТ ЭТО ДЕЛАЕТ НА ВСЮ ШИРИНУ
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Макс. вес: ${maxWeight.toStringAsFixed(1)} кг",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Макс. объём: ${maxVolume.toStringAsFixed(1)}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final volumeData = _filter(volumeRange);
    final weightData = _filter(weightRange);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.exercise.name,
          style: GoogleFonts.inter(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: stats.isEmpty
          ? const Center(child: Text("Нет данных"))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _chart(
            title: "Динамика объема",
            spots: _spotsFromPoints(
              _aggregate(
                volumeData,
                "volume",
                volumeRange,
              ),
            ),

            dates: _datesFromPoints(
              _aggregate(
                volumeData,
                "volume",
                volumeRange,
              ),
              volumeRange,
            ),
            range: volumeRange,
            onRangeChanged: (v) =>
                setState(() => volumeRange = v),
          ),
          const SizedBox(height: 20),
          _chart(
            title: "Динамика среднего веса",
            spots: _spotsFromPoints(
              _aggregate(
                weightData,
                "avgWeight",
                weightRange,
              ),
            ),

            dates: _datesFromPoints(
              _aggregate(
                weightData,
                "avgWeight",
                weightRange,
              ),
              weightRange,
            ),
            range: weightRange,
            onRangeChanged: (v) =>
                setState(() => weightRange = v),
          ),
          const SizedBox(height: 20),
          _bestStats(),
        ],
      ),
    );
  }
}