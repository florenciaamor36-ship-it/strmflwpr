import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformModel {
  final String id;
  final String name;
  final String iconEmoji;
  final String color; // hex string e.g. '#FF0000'
  final int defaultProfileCount;
  final bool isCustom;
  final DateTime createdAt;

  PlatformModel({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.color,
    required this.defaultProfileCount,
    required this.isCustom,
    required this.createdAt,
  });

  factory PlatformModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlatformModel(
      id: doc.id,
      name: data['name'] ?? '',
      iconEmoji: data['iconEmoji'] ?? '📺',
      color: data['color'] ?? '#6750A4',
      defaultProfileCount: data['defaultProfileCount'] ?? 5,
      isCustom: data['isCustom'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconEmoji': iconEmoji,
      'color': color,
      'defaultProfileCount': defaultProfileCount,
      'isCustom': isCustom,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PlatformModel copyWith({
    String? id,
    String? name,
    String? iconEmoji,
    String? color,
    int? defaultProfileCount,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return PlatformModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      color: color ?? this.color,
      defaultProfileCount: defaultProfileCount ?? this.defaultProfileCount,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Static list of default platforms
  static List<PlatformModel> get defaultPlatforms => [
        PlatformModel(
          id: 'netflix',
          name: 'Netflix',
          iconEmoji: '🎬',
          color: '#E50914',
          defaultProfileCount: 5,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'disney_plus',
          name: 'Disney+',
          iconEmoji: '🏰',
          color: '#113CCF',
          defaultProfileCount: 4,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'hbo_max',
          name: 'HBO Max',
          iconEmoji: '👑',
          color: '#5822B4',
          defaultProfileCount: 5,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'amazon_prime',
          name: 'Amazon Prime',
          iconEmoji: '📦',
          color: '#00A8E1',
          defaultProfileCount: 3,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'spotify',
          name: 'Spotify',
          iconEmoji: '🎵',
          color: '#1DB954',
          defaultProfileCount: 6,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'youtube_premium',
          name: 'YouTube Premium',
          iconEmoji: '▶️',
          color: '#FF0000',
          defaultProfileCount: 6,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'paramount_plus',
          name: 'Paramount+',
          iconEmoji: '⭐',
          color: '#0064FF',
          defaultProfileCount: 3,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'apple_tv_plus',
          name: 'Apple TV+',
          iconEmoji: '🍎',
          color: '#1C1C1E',
          defaultProfileCount: 6,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'star_plus',
          name: 'Star+',
          iconEmoji: '⭐',
          color: '#FF6B00',
          defaultProfileCount: 4,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'crunchyroll',
          name: 'Crunchyroll',
          iconEmoji: '🎌',
          color: '#F47521',
          defaultProfileCount: 4,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'canva_pro',
          name: 'Canva Pro',
          iconEmoji: '🎨',
          color: '#7D2AE8',
          defaultProfileCount: 5,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        PlatformModel(
          id: 'microsoft_365',
          name: 'Microsoft 365',
          iconEmoji: '💼',
          color: '#0078D4',
          defaultProfileCount: 5,
          isCustom: false,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
}
