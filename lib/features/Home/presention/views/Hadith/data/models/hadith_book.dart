class HadithBook {
  final String id;
  final String name;
  final int? totalHadiths;
  final String? url;
  final String? localPath;
  bool isDownloaded;
  int readCount;

  HadithBook({
    required this.id,
    required this.name,
    this.totalHadiths,
    this.url,
    this.localPath,
    this.isDownloaded = false,
    this.readCount = 0,
  });

  bool get isLocal => localPath != null;
}
