import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/app_database.dart';
import 'body_metric_stats_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  final db = AppDatabase.instance;

  List<BodyMetric> metrics = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    metrics = await db.select(db.bodyMetrics).get();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Измерения тела",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: metrics.isEmpty
                  ? Center(
                child: Text(
                  "Нет данных",
                  style: GoogleFonts.inter(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                itemCount: metrics.length,
                itemBuilder: (context, index) {
                  final metric = metrics[index];

                  return Container(
                    margin:
                    const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialWithModalsPageRoute(
                            builder: (_) => BodyMetricStatsScreen(
                              metric: metric,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                metric.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}