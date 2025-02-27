import 'package:flutter/material.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import '../models/produce_item.dart';

class AddProduceDialog extends StatefulWidget {
  const AddProduceDialog({super.key});

  @override
  State<AddProduceDialog> createState() => _AddProduceDialogState();
}

class _AddProduceDialogState extends State<AddProduceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Expanded produce lists
  static const List<String> _vegetables = [
    'Artichoke',
    'Arugula',
    'Asparagus',
    'Bamboo Shoots',
    'Bell Pepper',
    'Bitter Gourd',
    'Bok Choy',
    'Broccoli',
    'Brussels Sprouts',
    'Cabbage',
    'Carrot',
    'Cauliflower',
    'Celery',
    'Chicory',
    'Chinese Cabbage',
    'Collard Greens',
    'Corn',
    'Cucumber',
    'Daikon',
    'Eggplant',
    'Endive',
    'Fennel',
    'Fiddleheads',
    'Garlic',
    'Green Beans',
    'Green Onion',
    'Horseradish',
    'Jicama',
    'Kale',
    'Kohlrabi',
    'Leek',
    'Lettuce',
    'Mushroom',
    'Mustard Greens',
    'Okra',
    'Onion',
    'Parsnip',
    'Peas',
    'Potato',
    'Pumpkin',
    'Radicchio',
    'Radish',
    'Rutabaga',
    'Shallot',
    'Spinach',
    'Sweet Potato',
    'Swiss Chard',
    'Taro',
    'Tomato',
    'Turnip',
    'Water Chestnut',
    'Watercress',
    'Yam',
    'Zucchini'
  ];

  static const List<String> _fruits = [
    'Acai',
    'Apple',
    'Apricot',
    'Avocado',
    'Banana',
    'Blackberry',
    'Blueberry',
    'Boysenberry',
    'Breadfruit',
    'Cantaloupe',
    'Cherry',
    'Coconut',
    'Cranberry',
    'Custard Apple',
    'Date',
    'Dragon Fruit',
    'Durian',
    'Fig',
    'Gooseberry',
    'Grape',
    'Grapefruit',
    'Guava',
    'Jackfruit',
    'Kiwi',
    'Kumquat',
    'Lemon',
    'Lime',
    'Lychee',
    'Mandarin',
    'Mango',
    'Mangosteen',
    'Mulberry',
    'Nectarine',
    'Orange',
    'Papaya',
    'Passion Fruit',
    'Peach',
    'Pear',
    'Persimmon',
    'Pineapple',
    'Plum',
    'Pomegranate',
    'Pomelo',
    'Quince',
    'Rambutan',
    'Raspberry',
    'Soursop',
    'Starfruit',
    'Strawberry',
    'Tamarind',
    'Tangerine',
    'Watermelon'
  ];

  static const List<String> _herbs = [
    'Basil',
    'Bay Leaf',
    'Chives',
    'Cilantro',
    'Dill',
    'Epazote',
    'Fennel',
    'Holy Basil (Tulsi)',
    'Lavender',
    'Lemon Balm',
    'Lemongrass',
    'Marjoram',
    'Mint',
    'Oregano',
    'Parsley',
    'Rosemary',
    'Sage',
    'Shiso',
    'Tarragon',
    'Thyme',
    'Vietnamese Coriander',
    'Winter Savory',
  ];

  static const List<String> _mushrooms = [
    'Black Trumpet',
    'Button Mushroom',
    'Chanterelle',
    'Cordyceps',
    'Enoki',
    'King Oyster',
    'Lion\'s Mane',
    'Maitake',
    'Morel',
    'Oyster Mushroom',
    'Porcini',
    'Portobello',
    'Reishi',
    'Shiitake',
    'Turkey Tail',
    'Wood Ear',
  ];

  static const List<String> _nuts = [
    'Almond',
    'Brazil Nut',
    'Cashew',
    'Chestnut',
    'Hazelnut',
    'Macadamia',
    'Pecan',
    'Pine Nut',
    'Pistachio',
    'Walnut',
  ];

  static const List<String> _grains = [
    'Amaranth',
    'Barley',
    'Black Rice',
    'Buckwheat',
    'Bulgur',
    'Einkorn',
    'Emmer',
    'Farro',
    'Freekeh',
    'Kamut',
    'Khorasan',
    'Millet',
    'Purple Rice',
    'Quinoa',
    'Red Rice',
    'Rye',
    'Sorghum',
    'Spelt',
    'Teff',
    'Triticale',
    'Wild Rice',
  ];

  String _getCategory(String name) {
    name = name.toLowerCase();
    if (_vegetables.map((e) => e.toLowerCase()).contains(name)) {
      return 'vegetable';
    }
    if (_fruits.map((e) => e.toLowerCase()).contains(name)) return 'fruit';
    if (_herbs.map((e) => e.toLowerCase()).contains(name)) return 'herb';
    if (_mushrooms.map((e) => e.toLowerCase()).contains(name)) {
      return 'mushroom';
    }
    if (_nuts.map((e) => e.toLowerCase()).contains(name)) return 'nut';
    if (_grains.map((e) => e.toLowerCase()).contains(name)) return 'grain';
    return 'vegetable';
  }

  List<String> _getSuggestions(String query) {
    query = query.toLowerCase();
    return [
      ..._vegetables,
      ..._fruits,
      ..._herbs,
      ..._mushrooms,
      ..._nuts,
      ..._grains,
    ].where((item) => item.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Produce'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EasyAutocomplete(
              controller: _nameController,
              suggestions: _getSuggestions(''),
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a produce name';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Produce Name',
                hintText: 'Enter produce name',
              ),
            ),
            const SizedBox(height: 16),
            // Show the category that will be assigned
            if (_nameController.text.isNotEmpty)
              Text(
                'Category: ${_getCategory(_nameController.text)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final produce = ProduceItem(
                name: _nameController.text,
                dateAdded: DateTime.now(),
                category: _getCategory(_nameController.text),
              );
              Navigator.of(context).pop(produce);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
