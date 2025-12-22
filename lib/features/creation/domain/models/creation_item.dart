import 'dart:convert';

enum CreationType { video, image }

enum CreationStatus { processing, success, failed }

class CreationItem {
  final String id;
  final String? taskId; // For polling Kie AI
  final String prompt;
  final CreationType type;
  final CreationStatus status;
  final String? url; // Final download URL
  final String? localPath; // Path to downloaded file
  final String? thumbnailUrl;
  final DateTime createdAt;
  final String? duration; // e.g. "10s" or "Square"
  final String? errorMessage;
  // Additional fields for admin dashboard
  final String? style; // Video or image style
  final String? aspectRatio; // e.g. "16:9", "9:16"
  final String?
      outputType; // "video" or "image" (duplicate of type for admin compatibility)
  final String? generationModel; // e.g. "sora2", "kling"

  CreationItem({
    required this.id,
    this.taskId,
    required this.prompt,
    required this.type,
    required this.status,
    this.url,
    this.localPath,
    this.thumbnailUrl,
    required this.createdAt,
    this.duration,
    this.errorMessage,
    this.style,
    this.aspectRatio,
    this.outputType,
    this.generationModel,
  });

  CreationItem copyWith({
    String? id,
    String? taskId,
    String? prompt,
    CreationType? type,
    CreationStatus? status,
    String? url,
    String? localPath,
    String? thumbnailUrl,
    DateTime? createdAt,
    String? duration,
    String? errorMessage,
    String? style,
    String? aspectRatio,
    String? outputType,
    String? generationModel,
  }) {
    return CreationItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      status: status ?? this.status,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      style: style ?? this.style,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      outputType: outputType ?? this.outputType,
      generationModel: generationModel ?? this.generationModel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'prompt': prompt,
      'type': type.name,
      'status': status.name,
      'url': url,
      'localPath': localPath,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'errorMessage': errorMessage,
      'style': style,
      'aspectRatio': aspectRatio,
      'outputType': outputType ?? type.name,
      'generationModel': generationModel,
    };
  }

  factory CreationItem.fromMap(Map<String, dynamic> map) {
    return CreationItem(
      id: map['id'],
      taskId: map['taskId'],
      prompt: map['prompt'],
      type: CreationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CreationType.video,
      ),
      status: CreationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CreationStatus.failed,
      ),
      url: map['url'],
      localPath: map['localPath'],
      thumbnailUrl: map['thumbnailUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      duration: map['duration'],
      errorMessage: map['errorMessage'],
      style: map['style'],
      aspectRatio: map['aspectRatio'],
      outputType: map['outputType'] ?? map['type'],
      generationModel: map['generationModel'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CreationItem.fromJson(String source) =>
      CreationItem.fromMap(json.decode(source));
}
