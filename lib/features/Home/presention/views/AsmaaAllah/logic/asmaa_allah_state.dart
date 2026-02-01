import '../data/models/allah_name_model.dart';
import 'package:equatable/equatable.dart';

abstract class AsmaaAllahState extends Equatable {
  const AsmaaAllahState();

  @override
  List<Object> get props => [];
}

class AsmaaAllahInitial extends AsmaaAllahState {}

class AsmaaAllahLoading extends AsmaaAllahState {}

class AsmaaAllahLoaded extends AsmaaAllahState {
  final List<AllahNameModel> names;

  const AsmaaAllahLoaded({required this.names});

  @override
  List<Object> get props => [names];
}

class AsmaaAllahError extends AsmaaAllahState {
  final String message;

  const AsmaaAllahError({required this.message});

  @override
  List<Object> get props => [message];
}
