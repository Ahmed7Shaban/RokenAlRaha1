import 'package:equatable/equatable.dart';
import '../../data/models/last_read_model.dart';

abstract class LastReadState extends Equatable {
  const LastReadState();

  @override
  List<Object?> get props => [];
}

class LastReadInitial extends LastReadState {}

class LastReadLoading extends LastReadState {}

class LastReadLoaded extends LastReadState {
  final LastReadModel? lastRead;

  const LastReadLoaded(this.lastRead);

  @override
  List<Object?> get props => [lastRead];
}

class LastReadError extends LastReadState {
  final String message;

  const LastReadError(this.message);

  @override
  List<Object?> get props => [message];
}
