class BenefitsService {
  static final Map<String, List<String>> _benefitsByCategory = {
    'fruit': [
      'antioxidants and vitamin C for immune health',
      'natural fiber for digestive health',
      'heart-healthy compounds',
      'polyphenols for cellular protection',
      'natural sugars for quick energy',
      'hydration support through water content',
      'potassium for blood pressure regulation',
      'flavonoids for brain health',
      'carotenoids for eye health',
    ],
    'vegetable': [
      'essential minerals and vitamins',
      'prebiotic fiber for gut bacteria',
      'anti-inflammatory compounds',
      'chlorophyll for detoxification',
      'folate for cell repair',
      'potassium for muscle function',
      'antioxidants for cellular health',
      'nitrates for blood flow improvement',
      'phytonutrients for disease prevention',
    ],
    'herb': [
      'antimicrobial properties',
      'digestive support compounds',
      'natural anti-inflammatory effects',
      'essential oils for gut health',
      'polyphenols for cellular protection',
      'antioxidant compounds',
      'natural mood enhancement',
      'respiratory system support',
      'metabolic health promotion',
    ],
    'mushroom': [
      'beta-glucans for immune support',
      'prebiotic compounds for gut health',
      'vitamin D and minerals',
      'adaptogenic stress support',
      'cognitive function enhancement',
      'natural immune modulators',
      'anti-aging compounds',
      'liver health support',
      'energy metabolism boost',
    ],
    'nut': [
      'healthy fats and protein',
      'fiber for gut health',
      'minerals for brain function',
      'vitamin E for skin health',
      'L-arginine for heart health',
      'zinc for immune function',
      'magnesium for nerve function',
      'plant sterols for cholesterol management',
      'antioxidants for cellular protection',
    ],
    'grain': [
      'complex carbohydrates for sustained energy',
      'fiber for digestive health',
      'essential B vitamins and minerals',
      'protein for muscle maintenance',
      'selenium for thyroid function',
      'iron for oxygen transport',
      'zinc for immune support',
      'magnesium for bone health',
      'lignans for hormone balance',
    ],
  };

  static final Map<String, String> _specialCombinations = {
    // Two-ingredient combinations
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
    'fruit,herb':
        'The antioxidants in fruits are enhanced by herbs\' active compounds, creating a powerful anti-inflammatory effect.',
    'mushroom,herb':
        'This synergistic pair combines adaptogenic properties with antimicrobial benefits for enhanced immune function.',
    'fruit,grain':
        'Quick-release fruit sugars are balanced by slow-digesting grains, providing sustained energy and blood sugar control.',

    // Three-ingredient combinations
    'mushroom,herb,vegetable':
        'This powerful trio combines immune-boosting mushrooms, anti-inflammatory herbs, and nutrient-rich vegetables for optimal gut health and immune system support.',
    'fruit,nut,grain':
        'A perfect balance of quick and sustained energy sources, combining fruit\'s natural sugars with nuts\' healthy fats and grain\'s complex carbohydrates, while providing a full spectrum of fiber types.',
    'vegetable,herb,nut':
        'This combination maximizes nutrient absorption, combining the minerals from vegetables with the healthy fats from nuts and the digestive support from herbs for optimal gut health.',
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
