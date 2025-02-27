class ProduceItem {
  final String name;
  final DateTime dateAdded;
  final String category; // e.g., 'fruit', 'vegetable'

  ProduceItem({
    required this.name,
    required this.dateAdded,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateAdded': dateAdded.toIso8601String(),
      'category': category,
    };
  }

  factory ProduceItem.fromMap(Map<String, dynamic> map) {
    return ProduceItem(
      name: map['name'],
      dateAdded: DateTime.parse(map['dateAdded']),
      category: map['category'],
    );
  }
}
