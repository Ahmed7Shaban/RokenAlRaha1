import 'package:equatable/equatable.dart';
import '../data/admin_config_model.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  final AdminStatus status;
  final AdminConfigModel config;
  final String? errorMessage;
  final bool isSaving;

  const AdminState({
    this.status = AdminStatus.initial,
    this.config = const AdminConfigModel(
      isEnabled: false,
      devUrl: 'https://',
      tiktokUrl: 'https://',
    ),
    this.errorMessage,
    this.isSaving = false,
  });

  AdminState copyWith({
    AdminStatus? status,
    AdminConfigModel? config,
    String? errorMessage,
    bool? isSaving,
  }) {
    return AdminState(
      status: status ?? this.status,
      config: config ?? this.config,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [status, config, errorMessage, isSaving];
}
