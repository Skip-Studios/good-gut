class BenefitsService {
  static final Map<String, List<String>> _benefitsByCategory = {
    'fruit': [
      'antioxidants and vitamin C for immune health',
      'natural fiber for digestive health',
      'heart-healthy compounds',
    ],
    'vegetable': [
      'essential minerals and vitamins',
      'prebiotic fiber for gut bacteria',
      'anti-inflammatory compounds',
    ],
    'herb': [
      'antimicrobial properties',
      'digestive support compounds',
      'natural anti-inflammatory effects',
    ],
    'mushroom': [
      'beta-glucans for immune support',
      'prebiotic compounds for gut health',
      'vitamin D and minerals',
    ],
    'nut': [
      'healthy fats and protein',
      'fiber for gut health',
      'minerals for brain function',
    ],
    'grain': [
      'complex carbohydrates for sustained energy',
      'fiber for digestive health',
      'essential B vitamins and minerals',
    ],
  };

  static final Map<String, String> _specialCombinations = {
    'mushroom,vegetable':
        'The combination of mushrooms and vegetables provides a powerful prebiotic boost that helps beneficial gut bacteria thrive.',
    'herb,vegetable':
        'Herbs enhance the nutritional absorption of vegetables while adding antimicrobial benefits.',
    'fruit,nut':
        'This pairing provides a perfect balance of fiber, healthy fats, and antioxidants for sustained energy and gut health.',
    'grain,vegetable':
        'Whole grains combined with vegetables provide a complete spectrum of fiber types, supporting diverse gut bacteria.',
    'grain,nut':
        'This combination delivers sustained energy while providing both soluble and insoluble fiber for optimal digestion.',
  };

  static String generateBenefitsSummary(List<String> categories) {
    if (categories.isEmpty) return '';

    // Check for special combinations first
    for (var combo in _specialCombinations.keys) {
      var comboCategories = combo.split(',');
      if (categories.toSet().containsAll(comboCategories.toSet())) {
        return _specialCombinations[combo]!;
      }
    }

    // If no special combination, generate a general benefit
    var uniqueCategories = categories.toSet();
    if (uniqueCategories.length == 1) {
      var category = uniqueCategories.first;
      var benefits = _benefitsByCategory[category];
      return 'Your $category choices provide ${benefits?.first ?? "nutritional benefits"}.';
    }

    return 'This diverse combination provides multiple health benefits, including '
        'improved gut health and enhanced nutrient absorption.';
  }
}
