import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Add tips list
  static const List<String> _tips = [
    'Try adding leafy greens to your morning smoothie 🥬',
    'Keep pre-cut vegetables in your fridge for easy snacking 🥕',
    'Add mushrooms to your pasta for an immune system boost 🍄',
    'Sprinkle nuts on your breakfast for healthy fats 🥜',
    'Fresh herbs can transform any dish while adding health benefits 🌿',
    'Challenge yourself to try one new vegetable each week 🥦',
    'Add fruit to your water for natural flavor 🍎',
    'Keep frozen vegetables for convenient meal prep 🧊',
    'Start your day with a piece of fruit 🍌',
    'Add vegetables to your favorite sandwich 🥪',
  ];

  late String _currentTip;

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _randomizeTip();
  }

  void _randomizeTip() {
    setState(() {
      _currentTip = _tips[DateTime.now().millisecondsSinceEpoch % _tips.length];
    });
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
    await prefs.setInt(key, value);
    await _loadGoals();
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('$value $description'),
          ],
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
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _randomizeTip,
                  tooltip: 'Show another tip',
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
