class CrisisResource {
  final String name;
  final String number;
  final String description;
  final bool isAvailable247;

  const CrisisResource({
    required this.name,
    required this.number,
    required this.description,
    this.isAvailable247 = true,
  });

  factory CrisisResource.fromJson(Map<String, dynamic> json) => CrisisResource(
        name: json['name'] ?? '',
        number: json['number'] ?? '',
        description: json['description'] ?? '',
        isAvailable247: json['isAvailable247'] ?? true,
      );
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;
  final bool isProfessional;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
    this.isProfessional = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'isProfessional': isProfessional
      };
}

class SafetyPlan {
  List<String> warningSigns;
  List<String> copingStrategies;
  List<EmergencyContact> socialSupports;
  List<EmergencyContact> professionalContacts;
  List<String> safeEnvironments;

  SafetyPlan({
    this.warningSigns = const [],
    this.copingStrategies = const [],
    this.socialSupports = const [],
    this.professionalContacts = const [],
    this.safeEnvironments = const [],
  });

  Map<String, dynamic> toJson() => {
        'warningSigns': warningSigns,
        'copingStrategies': copingStrategies,
        'socialSupports': socialSupports.map((e) => e.toJson()).toList(),
        'professionalContacts':
            professionalContacts.map((e) => e.toJson()).toList(),
        'safeEnvironments': safeEnvironments,
      };

  factory SafetyPlan.fromJson(Map<String, dynamic> json) => SafetyPlan(
        warningSigns: List<String>.from(json['warningSigns'] ?? []),
        copingStrategies: List<String>.from(json['copingStrategies'] ?? []),
        socialSupports: (json['socialSupports'] as List?)
                ?.map((e) => EmergencyContact(
                    name: e['name'] ?? '',
                    phone: e['phone'] ?? '',
                    relationship: e['relationship'] ?? ''))
                .toList() ??
            [],
        professionalContacts: (json['professionalContacts'] as List?)
                ?.map((e) => EmergencyContact(
                    name: e['name'] ?? '',
                    phone: e['phone'] ?? '',
                    relationship: e['role'] ?? e['relationship'] ?? '',
                    isProfessional: true))
                .toList() ??
            [],
        safeEnvironments: List<String>.from(json['safeEnvironments'] ?? []),
      );
}
