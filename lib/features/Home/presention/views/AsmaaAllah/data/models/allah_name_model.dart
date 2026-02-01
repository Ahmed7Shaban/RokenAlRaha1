class AllahNameModel {
  final String name;

  AllahNameModel({required this.name});

  factory AllahNameModel.fromJson(Map<String, dynamic> json) {
    return AllahNameModel(name: json['name'] as String);
  }
}
