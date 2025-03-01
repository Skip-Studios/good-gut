import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/produce_item.dart';
import '../widgets/add_produce_dialog.dart';
import '../services/database_helper.dart';
import '../services/benefits_service.dart';
import '../services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyTrackingPage extends StatefulWidget {
  const DailyTrackingPage({super.key});

  @override
  State<DailyTrackingPage> createState() => _DailyTrackingPageState();
}

class _DailyTrackingPageState extends State<DailyTrackingPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _analytics = AnalyticsService();
  List<ProduceItem> _produceItems = [];
  int _uniqueDailyCount = 0;
  int _uniqueWeeklyCount = 0;
  int _dailyGoal = 5;
  int _weeklyGoal = 30;
  bool _isBenefitsExpanded = true;
  String _lastBenefitsSummary = '';
  String _randomBenefit = '';

  static const List<String> _motivationalMessages = [
    'Start your journey to better gut health today! 🌱',
    'Your gut microbiome is waiting for some plant-powered love! 💚',
    'Ready to boost your health with nature\'s goodness? 🌿',
    'Every plant you eat is a step towards better health! 🥬',
    'Time to nourish your gut with plant diversity! 🥕',
  ];

  @override
  void initState() {
    super.initState();
    _loadTodaysProduce();
    _loadGoals();
    _loadBenefitsState();
    _setRandomBenefit();
    _analytics.logScreenView(screenName: 'daily_tracking_page');
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('daily_goal') ?? 5;
      _weeklyGoal = prefs.getInt('weekly_goal') ?? 30;
    });
  }

  Future<void> _loadBenefitsState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBenefitsExpanded = prefs.getBool('benefits_expanded') ?? true;
    });
  }

  Future<void> _saveBenefitsState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('benefits_expanded', _isBenefitsExpanded);
  }

  void _setRandomBenefit() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final categories = [
      'fruit',
      'vegetable',
      'herb',
      'mushroom',
      'nut',
      'grain'
    ];
    final randomCategory = categories[random % categories.length];
    final benefits = BenefitsService.getBenefitsForCategory(randomCategory);
    if (benefits.isNotEmpty) {
      setState(() {
        _randomBenefit = benefits[random % benefits.length];
      });
    }
  }

  Future<void> _loadTodaysProduce() async {
    final items = await _dbHelper.getProduceForDate(DateTime.now());
    final uniqueDaily =
        await _dbHelper.getUniqueDailyProduceCount(DateTime.now());
    final uniqueWeekly =
        await _dbHelper.getUniqueWeeklyProduceCount(DateTime.now());

    final newBenefitsSummary = BenefitsService.generateBenefitsSummary(
      items.map((item) => item.category).toList(),
    );

    setState(() {
      _produceItems = items;
      _uniqueDailyCount = uniqueDaily;
      _uniqueWeeklyCount = uniqueWeekly;

      // Auto-expand if benefits have changed
      if (newBenefitsSummary != _lastBenefitsSummary &&
          newBenefitsSummary.isNotEmpty) {
        _isBenefitsExpanded = true;
        _saveBenefitsState();
      }
      _lastBenefitsSummary = newBenefitsSummary;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Unique Plants',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_uniqueDailyCount / $_dailyGoal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Weekly Unique Plants',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_uniqueWeeklyCount / $_weeklyGoal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_produceItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Total entries today: ${_produceItems.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    final bool hasProduceToday = _produceItems.isNotEmpty;
    final random = DateTime.now().day;
    final motivationalMessage =
        _motivationalMessages[random % _motivationalMessages.length];

    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _isBenefitsExpanded = !_isBenefitsExpanded;
            _saveBenefitsState();
            if (!hasProduceToday) {
              _setRandomBenefit();
            }
          });

          // Track benefits card interaction
          _analytics.logFeatureUse(
            featureName:
                _isBenefitsExpanded ? 'expand_benefits' : 'collapse_benefits',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasProduceToday ? Icons.tips_and_updates : Icons.eco,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasProduceToday ? 'Health Benefits' : 'Did you know?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isBenefitsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              if (_isBenefitsExpanded) ...[
                const SizedBox(height: 8),
                if (hasProduceToday)
                  Text(
                    _getBenefitsSummary(),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )
                else ...[
                  Text(
                    'Plants can provide $_randomBenefit. Add a plant now.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  /*const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          motivationalMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),*/
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProduceList(bool isTablet) {
    if (_produceItems.isEmpty) {
      final random = DateTime.now().day;
      final motivationalMessage =
          _motivationalMessages[random % _motivationalMessages.length];
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Plants can provide $_randomBenefit. Add a plant now.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              /*const SizedBox(height: 16),
              Text(
                motivationalMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),*/
            ],
          ),
        ),
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
