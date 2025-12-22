class Category {
  final String name;
  final String emoji;

  Category({required this.name, required this.emoji});

  Map<String, dynamic> toJson() => {
    'name': name,
    'emoji': emoji,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '📁',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class MemoryItem {
  String id;
  String content;
  DateTime timestamp;
  String category;
  DateTime? deadline; // New field

  MemoryItem({
    required this.id,
    required this.content,
    required this.timestamp,
    this.category = 'Custom',
    this.deadline,
  });

  // Convert a MemoryItem to a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'deadline': deadline?.toIso8601String(), // Serialize deadline
    };
  }

  // Create a MemoryItem from a Map (for JSON deserialization)
  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      category: json['category'] ?? 'Custom',
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null, // Deserialize deadline
    );
  }
}
