import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/produce_item.dart';
import '../widgets/add_produce_dialog.dart';
import '../services/database_helper.dart';
import '../services/benefits_service.dart';
import '../services/analytics_service.dart';

class DailyTrackingPage extends StatefulWidget {
  const DailyTrackingPage({super.key});

  @override
  State<DailyTrackingPage> createState() => _DailyTrackingPageState();
}

class _DailyTrackingPageState extends State<DailyTrackingPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _analytics = AnalyticsService();
  List<ProduceItem> _produceItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodaysProduce();
    _analytics.logScreenView(screenName: 'daily_tracking_page');
  }

  Future<void> _loadTodaysProduce() async {
    final items = await _dbHelper.getProduceForDate(DateTime.now());
    setState(() {
      _produceItems = items;
    });
  }

  Future<void> _addProduce() async {
    final ProduceItem? newProduce = await showDialog<ProduceItem>(
      context: context,
      builder: (context) => const AddProduceDialog(),
    );

    if (newProduce != null) {
      await _dbHelper.insertProduce(newProduce);
      await _loadTodaysProduce();

      // Track produce addition
      _analytics.logAddProduce(
        produceName: newProduce.name,
        category: newProduce.category,
      );
    }
  }

  Future<void> _deleteProduce(ProduceItem item) async {
    await _dbHelper.deleteProduce(item);
    await _loadTodaysProduce();

    // Track produce deletion
    _analytics.logFeatureUse(
      featureName: 'delete_produce',
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'fruit':
        return Icons.apple;
      case 'vegetable':
        return Icons.eco;
      case 'herb':
        return Icons.grass;
      case 'mushroom':
        return Icons.forest;
      case 'nut':
        return FontAwesomeIcons.seedling;
      case 'grain':
        return Icons.grain;
      default:
        return Icons.eco;
    }
  }

  String _getBenefitsSummary() {
    final categories = _produceItems.map((item) => item.category).toList();
    return BenefitsService.generateBenefitsSummary(categories);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = size.shortestSide;
    final aspectRatio = size.width / size.height;
    final isPhone = aspectRatio > 1.5 && aspectRatio < 2.5;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final padding = isPhone ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Produce'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (!isPhone && isPortrait) {
                      return Column(
                        children: [
                          _buildProgressCard(),
                          if (_produceItems.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildBenefitsCard(),
                          ],
                        ],
                      );
                    } else if (!isPhone && !isPortrait) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildProgressCard(),
                          ),
                          const SizedBox(width: 24),
                          if (_produceItems.isNotEmpty)
                            Expanded(
                              child: _buildBenefitsCard(),
                            ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildProgressCard(),
                        if (_produceItems.isNotEmpty &&
                            diagonal > 700 &&
                            isPortrait) ...[
                          const SizedBox(height: 16),
                          _buildBenefitsCard(),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildProduceList(!isPhone),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduce,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_produceItems.length} items',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Health Benefits',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getBenefitsSummary(),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProduceList(bool isTablet) {
    if (_produceItems.isEmpty) {
      return const Center(
        child: Text('No produce added today'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      itemCount: _produceItems.length,
      itemBuilder: (context, index) {
        final item = _produceItems[index];
        return Card(
          child: ListTile(
            leading: Icon(
              _getCategoryIcon(item.category),
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              item.name,
              style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
            ),
            subtitle: Text(item.category),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteProduce(item),
            ),
          ),
        );
      },
    );
  }
}
