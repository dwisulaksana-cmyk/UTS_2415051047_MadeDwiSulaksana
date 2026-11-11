class Ormawa {
  final int? id;
  final String name;
  final String category;
  final String level;
  final String description;
  final String? logoUrl;
  final String? instagram;
  final String? contact;

  const Ormawa({
    this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.description,
    this.logoUrl,
    this.instagram,
    this.contact,
  });

  factory Ormawa.fromJson(Map<String, dynamic> json) {
    return Ormawa(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      description: json['description'] as String,
      logoUrl: json['logo_url'] as String?,
      instagram: json['instagram'] as String?,
      contact: json['contact'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'level': level,
      'description': description,
      'logo_url': logoUrl,
      'instagram': instagram,
      'contact': contact,
    };
  }
}