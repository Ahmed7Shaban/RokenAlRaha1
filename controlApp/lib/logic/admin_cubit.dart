import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/admin_config_model.dart';
import '../data/config_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final ConfigRepository _repository;
  StreamSubscription<AdminConfigModel>? _configSubscription;

  AdminCubit({required ConfigRepository repository})
    : _repository = repository,
      super(const AdminState()) {
    _subscribeToConfig();
  }

  void _subscribeToConfig() {
    emit(state.copyWith(status: AdminStatus.loading));

    // Add a timeout to avoid infinite loading if Firebase isn't configured correctly
    final stream = _repository.getConfigStream().timeout(
      const Duration(seconds: 5),
      onTimeout: (sink) {
        sink.addError(
          'Connection timed out. Check your internet or Firebase config (google-services.json).',
        );
      },
    );

    _configSubscription = stream.listen(
      (config) {
        emit(state.copyWith(status: AdminStatus.success, config: config));
      },
      onError: (error) {
        emit(
          state.copyWith(
            status: AdminStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  void updateIsEnabled(bool value) {
    emit(state.copyWith(config: state.config.copyWith(isEnabled: value)));
  }

  void updateDevUrl(String value) {
    emit(state.copyWith(config: state.config.copyWith(devUrl: value)));
  }

  void updateTiktokUrl(String value) {
    emit(state.copyWith(config: state.config.copyWith(tiktokUrl: value)));
  }

  Future<bool> saveChanges() async {
    if (!_validateUrls()) {
      emit(
        state.copyWith(
          errorMessage:
              'Please enter valid URLs (starting with http:// or https://)',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(isSaving: true, errorMessage: null),
    ); // Clear previous errors

    try {
      await _repository.updateConfig(state.config);
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save changes: ${e.toString()}',
        ),
      );
      return false;
    }
  }

  bool _validateUrls() {
    final devUrlValid =
        Uri.tryParse(state.config.devUrl)?.hasAbsolutePath ?? false;
    final tiktokUrlValid =
        Uri.tryParse(state.config.tiktokUrl)?.hasAbsolutePath ?? false;

    return devUrlValid && tiktokUrlValid;
  }

  @override
  Future<void> close() {
    _configSubscription?.cancel();
    return super.close();
  }
}
