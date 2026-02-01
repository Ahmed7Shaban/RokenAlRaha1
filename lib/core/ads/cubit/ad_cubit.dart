import 'package:flutter_bloc/flutter_bloc.dart';

part 'ad_state.dart';

class AdCubit extends Cubit<AdState> {
  AdCubit() : super(AdInitial());

  void triggerInterstitial() {
    emit(AdShowInterstitial());
  }
}
