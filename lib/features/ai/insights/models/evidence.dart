class Evidence {
  final String source;
  final String description;
  final double weight;

  const Evidence({
    required this.source,
    required this.description,
    required this.weight,
  });

  Evidence copyWith({String? source, String? description, double? weight}) {
    return Evidence(
      source: source ?? this.source,
      description: description ?? this.description,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() => {
    'source': source,
    'description': description,
    'weight': weight,
  };

  factory Evidence.fromJson(Map<String, dynamic> json) => Evidence(
    source: json['source'] as String? ?? '',
    description: json['description'] as String? ?? '',
    weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
  );
}
