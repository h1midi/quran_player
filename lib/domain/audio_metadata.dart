class AudioMetadata {
  final String title;
  final String artwork;

  AudioMetadata({required this.title, required this.artwork});
}

class QuranSurah {
  final int id;
  final String name;

  QuranSurah({required this.id, required this.name});

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      id: json['id'],
      name: json['name'],
    );
  }
}
