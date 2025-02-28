import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_helper.dart';
import '../services/benefits_service.dart';
import '../models/produce_item.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/analytics_service.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _selectedPeriod = 'Day';
  int _offset = 0;
  final _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView(screenName: 'history_page');
  }

  DateTime get _startDate {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Day':
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: _offset));
      case 'Week':
        // Get the start of the current week (Monday)
        final today = DateTime(now.year, now.month, now.day);
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return weekStart.subtract(Duration(days: 7 * _offset));
      case 'Month':
        return DateTime(now.year, now.month - _offset, 1);
      case 'Year':
        return DateTime(now.year - _offset, 1, 1);
      default:
        return now;
    }
  }

  DateTime get _endDate {
    final start = _startDate;
    switch (_selectedPeriod) {
      case 'Day':
        return start.add(const Duration(days: 1));
      case 'Week':
        return start.add(const Duration(days: 7));
      case 'Month':
        return DateTime(start.year, start.month + 1, 1);
      case 'Year':
        return DateTime(start.year + 1, 1, 1);
      default:
        return DateTime.now();
    }
  }

  String _formatDateRange(String period) {
    final dateFormat = DateFormat('MMM d, y');
    if (period == 'Day') {
      return dateFormat.format(_startDate);
    } else {
      return '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate.subtract(const Duration(days: 1)))}';
    }
  }

  void _navigateBack() {
    setState(() {
      _offset++;
    });
    _logHistoryView();
  }

  void _navigateForward() {
    if (_offset > 0) {
      setState(() {
        _offset--;
      });
      _logHistoryView();
    }
  }

  void _logHistoryView() {
    _analytics.logViewHistory(
      period: _selectedPeriod,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  int _roundUpToNearestMultipleOf5(int number) {
    return ((number + 4) ~/ 5) * 5;
  }

  Widget _buildBenefitsSummary(List<ProduceItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    final categories = items.map((item) => item.category).toList();
    final summary = BenefitsService.generateBenefitsSummary(categories);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Benefits This $_selectedPeriod',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total unique plants: ${items.map((e) => e.name).toSet().length}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                SizedBox(
                  width: isTablet ? 400 : double.infinity,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Day', label: Text('Day')),
                      ButtonSegment(value: 'Week', label: Text('Week')),
                      ButtonSegment(value: 'Month', label: Text('Month')),
                      ButtonSegment(value: 'Year', label: Text('Year')),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedPeriod = newSelection.first;
                        _offset = 0;
                      });
                      _logHistoryView();
                    },
                    showSelectedIcon: false,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _navigateBack,
                    ),
                    Expanded(
                      child: Text(
                        _formatDateRange(_selectedPeriod),
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _offset > 0 ? _navigateForward : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProduceItem>>(
              future: _dbHelper.getProduceForDateRange(_startDate, _endDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data for this period'));
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: padding / 2,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildChart(snapshot.data!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<ProduceItem> items) {
    if (_selectedPeriod == 'Day') {
      // Group items by category
      final Map<String, int> categoryCounts = {};
      for (var item in items) {
        categoryCounts[item.category] =
            (categoryCounts[item.category] ?? 0) + 1;
      }

      // Create a grid of category boxes
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryBox('fruit', categoryCounts['fruit'] ?? 0),
              _buildCategoryBox('vegetable', categoryCounts['vegetable'] ?? 0),
              _buildCategoryBox('herb', categoryCounts['herb'] ?? 0),
              _buildCategoryBox('mushroom', categoryCounts['mushroom'] ?? 0),
              _buildCategoryBox('nut', categoryCounts['nut'] ?? 0),
              _buildCategoryBox('grain', categoryCounts['grain'] ?? 0),
            ],
          ),
        ],
      );
    }

    // Group items by date and category
    final Map<DateTime, Map<String, int>> categoryCountsByDate = {};
    final categories = [
      'fruit',
      'vegetable',
      'herb',
      'mushroom',
      'nut',
      'grain'
    ];

    for (var item in items) {
      final date = DateTime(
        item.dateAdded.year,
        item.dateAdded.month,
        item.dateAdded.day,
      );
      categoryCountsByDate.putIfAbsent(date, () => {});
      categoryCountsByDate[date]!.putIfAbsent(item.category, () => 0);
      categoryCountsByDate[date]![item.category] =
          (categoryCountsByDate[date]![item.category] ?? 0) + 1;
    }

    // Sort dates
    final dates = categoryCountsByDate.keys.toList()..sort();

    // Prepare bar groups
    final barGroups = dates.asMap().entries.map((entry) {
      final date = entry.value;
      final categoryCounts = categoryCountsByDate[date] ?? {};

      final bars = categories.map((category) {
        return BarChartRodData(
          toY: categoryCounts[category]?.toDouble() ?? 0,
          color: _getCategoryColor(category),
          width: 16,
        );
      }).toList();

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: bars.fold(0, (sum, rod) => sum + rod.toY),
            // color: Colors.transparent,
            width: 16,
            rodStackItems: bars.map((bar) {
              return BarChartRodStackItem(
                0,
                bar.toY,
                bar.color ?? Colors.white,
              );
            }).toList(),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    int maxY = 0;
    for (var group in barGroups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxY) {
          maxY = rod.toY.toInt();
        }
      }
    }
    // Remove spots calculation and just keep bar groups
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: barGroups,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= dates.length) return const Text('');
                      final date = dates[value.toInt()];
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          DateFormat(_getDateFormat()).format(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: EdgeInsets.zero,
                  tooltipBgColor: Colors.transparent,
                  tooltipMargin: 0,
                  getTooltipItem: (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    return BarTooltipItem(
                      rod.toY.round().toString(),
                      const TextStyle(
                        color: Color.fromARGB(255, 45, 86, 47),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              maxY: _roundUpToNearestMultipleOf5(maxY).toDouble(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: categories.map((category) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(category.capitalize()),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'fruit':
        return Colors.red.shade300;
      case 'vegetable':
        return Colors.green.shade300;
      case 'herb':
        return Colors.teal.shade300;
      case 'mushroom':
        return Colors.brown.shade300;
      case 'nut':
        return Colors.orange.shade300;
      case 'grain':
        return Colors.amber.shade300;
      default:
        return Colors.grey;
    }
  }

  String _getDateFormat() {
    switch (_selectedPeriod) {
      case 'Week':
        return 'E';
      case 'Month':
        return 'MMM d';
      case 'Year':
        return 'MMM';
      default:
        return 'MMM d';
    }
  }

  Widget _buildCategoryBox(String category, int count) {
    final Map<String, IconData> categoryIcons = {
      'fruit': Icons.apple,
      'vegetable': Icons.eco,
      'herb': Icons.grass,
      'mushroom': Icons.forest,
      'nut': FontAwesomeIcons.seedling,
      'grain': Icons.grain,
    };

    final Map<String, Color> categoryColors = {
      'fruit': Colors.red.shade100,
      'vegetable': Colors.green.shade100,
      'herb': Colors.teal.shade100,
      'mushroom': Colors.brown.shade100,
      'nut': Colors.orange.shade100,
      'grain': Colors.amber.shade100,
    };

    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: categoryColors[category],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcons[category],
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            category.capitalize(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
