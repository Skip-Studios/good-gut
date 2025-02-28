import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../services/analytics_service.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  static const String _weeklyGoalKey = 'weekly_goal';
  static const String _dailyGoalKey = 'daily_goal';
  static const int _minWeeklyGoal = 10;
  static const int _minDailyGoal = 1;

  int _weeklyGoal = 30;
  int _dailyGoal = 5;
  final _analytics = AnalyticsService();

  // Add tips list
  static const List<String> _tips = [
    'Try adding leafy greens to your smoothie - because drinking your salad is way more fun! 🥬',
    'Keep pre-cut veggies in your fridge. Your future hungry self will thank you! 🥕',
    'Add mushrooms to your pasta - they\'re the fun-guys of the food world! 🍄',
    'Sprinkle nuts on your breakfast. They\'re not just for squirrels! 🥜',
    'Fresh herbs are like nature\'s flavor confetti - sprinkle them everywhere! 🌿',
    'Challenge yourself to try one new veggie each week. Who knows, you might find your soulmate in a sweet potato! 🥔',
    'Add fruit to your water - because plain water is so 2023! 🍎',
    'Keep frozen veggies handy. They\'re like your emergency backup dancers! 🧊',
    'Start your day with fruit - it\'s nature\'s candy, but your dentist approves! 🍌',
    'Add veggies to your sandwich. It\'s like giving your lunch a vitamin hug! 🥪',
    'Mix herbs into your eggs - because plain eggs are eggs-tremely boring! 🍳',
    'Sneak spinach into your smoothies - ninja nutrition at its finest! 🥤',
    'Roast your nuts for extra flavor - they\'re like tiny flavor bombs! 💥',
    'Try grain bowls - they\'re like a warm hug for your gut! 🌾',
    'Make mushroom "bacon" - because fungi can be fun, guys! 🥓',
    'Add berries to your breakfast - they\'re like tiny antioxidant superheroes! 🦸‍♂️',
    'Experiment with different herbs - it\'s like a flavor adventure in your kitchen! 🌺',
    'Mix different colored veggies - eat the rainbow, taste the rainbow! 🌈',
    'Try overnight oats - because future you deserves a delicious breakfast! 🥣',
    'Make veggie noodles - they\'re like regular noodles but wearing a cape! 🦸‍♀️',
  ];

  late List<String> _dailyTips;
  late String _currentTip;

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _initializeDailyTips();
    _analytics.logScreenView(screenName: 'goals_page');
  }

  void _initializeDailyTips() {
    // Get today's date as a seed
    final today = DateTime.now().day;

    // Create a repeatable random number generator for today
    final random = Random(today);

    // Shuffle the tips using today's seed and take first 3
    final shuffled = List<String>.from(_tips)..shuffle(random);
    _dailyTips = shuffled.take(3).toList();

    // Set initial tip
    _currentTip = _dailyTips[0];
  }

  void _randomizeTip() {
    setState(() {
      // Cycle through today's 3 tips
      final currentIndex = _dailyTips.indexOf(_currentTip);
      final nextIndex = (currentIndex + 1) % _dailyTips.length;
      _currentTip = _dailyTips[nextIndex];
    });

    // Track tip interaction
    _analytics.logFeatureUse(featureName: 'view_tip');
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weeklyGoal = prefs.getInt(_weeklyGoalKey) ?? 30;
      _dailyGoal = prefs.getInt(_dailyGoalKey) ?? 5;
    });
  }

  Future<void> _updateGoal(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    final oldValue = key == _weeklyGoalKey ? _weeklyGoal : _dailyGoal;
    await prefs.setInt(key, value);
    await _loadGoals();

    // Track goal updates
    _analytics.logGoalUpdate(
      goalType: key == _weeklyGoalKey ? 'weekly' : 'daily',
      oldValue: oldValue,
      newValue: value,
    );
  }

  Future<void> _showGoalDialog(BuildContext context, String title, String key,
      int currentValue, int minValue) async {
    final controller = TextEditingController(text: currentValue.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            errorText: null,
            helperText: 'Minimum value: $minValue',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newValue = int.tryParse(controller.text) ?? currentValue;
              if (newValue >= minValue) {
                _updateGoal(key, newValue);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required int value,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('$value $description'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    final isPhone = aspectRatio > 1.5 && aspectRatio < 2.5;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final padding = isPhone ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: LayoutBuilder(builder: (context, constraints) {
          if (!isPhone && !isPortrait) {
            // Landscape tablet layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTipCard()),
                SizedBox(width: padding),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _buildGoalCard(
                          title: 'Daily Goal',
                          value: _dailyGoal,
                          description: 'servings of fruits and vegetables',
                          onTap: () => _showGoalDialog(
                            context,
                            'Daily Goal',
                            _dailyGoalKey,
                            _dailyGoal,
                            _minDailyGoal,
                          ),
                        ),
                      ),
                      SizedBox(height: padding),
                      SizedBox(
                        width: double.infinity,
                        child: _buildGoalCard(
                          title: 'Weekly Goal',
                          value: _weeklyGoal,
                          description: 'different plants per week',
                          onTap: () => _showGoalDialog(
                            context,
                            'Weekly Goal',
                            _weeklyGoalKey,
                            _weeklyGoal,
                            _minWeeklyGoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          // Portrait tablet and phone layout
          return ListView(
            children: [
              _buildTipCard(),
              SizedBox(height: padding),
              _buildGoalCard(
                title: 'Daily Goal',
                value: _dailyGoal,
                description: 'servings of fruits and vegetables',
                onTap: () => _showGoalDialog(
                  context,
                  'Daily Goal',
                  _dailyGoalKey,
                  _dailyGoal,
                  _minDailyGoal,
                ),
              ),
              SizedBox(height: padding),
              _buildGoalCard(
                title: 'Weekly Goal',
                value: _weeklyGoal,
                description: 'different plants per week',
                onTap: () => _showGoalDialog(
                  context,
                  'Weekly Goal',
                  _weeklyGoalKey,
                  _weeklyGoal,
                  _minWeeklyGoal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTipCard() {
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
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tip of the Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Show another tip (3 available per day)',
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _randomizeTip,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentTip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
}
