class AzkarItemModel {
  final String text;
  final int count;
  final String? audioUrl;
  final String? reference;

  AzkarItemModel({
    required this.text,
    this.count = 1,
    this.audioUrl,
    this.reference,
  });
}
