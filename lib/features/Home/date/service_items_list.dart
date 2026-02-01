import '../../../routes/routes.dart';
import '../../../source/app_images.dart';
import '../models/service_item.dart';

final List<ServiceItem> serviceItemsList = [
  // ServiceItem(
  //   iconPath: Assets.muhammad,
  //   label: " صلاة على النبي",
  //   route: Routes.SalatAlnabi,
  // ),

  // ServiceItem(
  //   iconPath: Assets.Ruqyah,
  //   label: "الرُقية الشرعية ",
  //   route: Routes.Ruqyah,
  // ),
  ServiceItem(
    iconPath: Assets.azkar,
    label: "الأذكار ",
    route: Routes.AllAzkar,
  ),
  ServiceItem(
    iconPath: Assets.imagesKaaba,
    label: "القبلة ",
    route: Routes.QiblahView,
  ),
];
