import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/allah_name_model.dart';
import 'asmaa_allah_state.dart';

class AsmaaAllahCubit extends Cubit<AsmaaAllahState> {
  AsmaaAllahCubit() : super(AsmaaAllahInitial());

  Future<void> loadNames() async {
    emit(AsmaaAllahLoading());
    try {
      final String response = await rootBundle.loadString(
        'assets/json/names_of_allah.json',
      );
      final data = await json.decode(response);
      List<dynamic> list = data['data'];
      List<AllahNameModel> names = list
          .map((e) => AllahNameModel.fromJson(e))
          .toList();
      emit(AsmaaAllahLoaded(names: names));
    } catch (e) {
      emit(AsmaaAllahError(message: "حدث خطأ أثناء تحميل الأسماء: $e"));
    }
  }
}
