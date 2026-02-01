class ServiceItem {
  final String iconPath;
  final String label;
  final String route;
  final String? notificationKey;

  ServiceItem({
    required this.iconPath,
    required this.label,
    required this.route,
    this.notificationKey,
  });
}
