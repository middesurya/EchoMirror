import 'package:hive/hive.dart';

part 'echo_response.g.dart';

@HiveType(typeId: 3)
class EchoResponse extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reflectionId;

  @HiveField(2)
  final String genre;

  @HiveField(3)
  final String story;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? localImagePath;

  @HiveField(6)
  final String? audioPath;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final NarrativeElements narrativeElements;

  EchoResponse({
    required this.id,
    required this.reflectionId,
    required this.genre,
    required this.story,
    this.imageUrl,
    this.localImagePath,
    this.audioPath,
    required this.createdAt,
    required this.narrativeElements,
  });

  EchoResponse copyWith({
    String? id,
    String? reflectionId,
    String? genre,
    String? story,
    String? imageUrl,
    String? localImagePath,
    String? audioPath,
    DateTime? createdAt,
    NarrativeElements? narrativeElements,
  }) {
    return EchoResponse(
      id: id ?? this.id,
      reflectionId: reflectionId ?? this.reflectionId,
      genre: genre ?? this.genre,
      story: story ?? this.story,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      narrativeElements: narrativeElements ?? this.narrativeElements,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reflectionId': reflectionId,
        'genre': genre,
        'story': story,
        'imageUrl': imageUrl,
        'localImagePath': localImagePath,
        'audioPath': audioPath,
        'createdAt': createdAt.toIso8601String(),
        'narrativeElements': narrativeElements.toJson(),
      };

  factory EchoResponse.fromJson(Map<String, dynamic> json) => EchoResponse(
        id: json['id'] as String,
        reflectionId: json['reflectionId'] as String,
        genre: json['genre'] as String,
        story: json['story'] as String,
        imageUrl: json['imageUrl'] as String?,
        localImagePath: json['localImagePath'] as String?,
        audioPath: json['audioPath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        narrativeElements: NarrativeElements.fromJson(
          json['narrativeElements'] as Map<String, dynamic>,
        ),
      );
}

@HiveType(typeId: 4)
class NarrativeElements {
  @HiveField(0)
  final String archetype;

  @HiveField(1)
  final String setting;

  @HiveField(2)
  final String power;

  @HiveField(3)
  final String conflict;

  @HiveField(4)
  final String resolution;

  NarrativeElements({
    required this.archetype,
    required this.setting,
    required this.power,
    required this.conflict,
    required this.resolution,
  });

  Map<String, dynamic> toJson() => {
        'archetype': archetype,
        'setting': setting,
        'power': power,
        'conflict': conflict,
        'resolution': resolution,
      };

  factory NarrativeElements.fromJson(Map<String, dynamic> json) =>
      NarrativeElements(
        archetype: json['archetype'] as String,
        setting: json['setting'] as String,
        power: json['power'] as String,
        conflict: json['conflict'] as String,
        resolution: json['resolution'] as String,
      );
}
