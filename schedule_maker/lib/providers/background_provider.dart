import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackgroundState {
  final String? savedImagePath;
  final String? pendingImagePath;

  BackgroundState({
    this.savedImagePath,
    this.pendingImagePath,
  });

  BackgroundState copyWith({
    String? savedImagePath,
    String? pendingImagePath,
    bool clearPending = false,
  }) {
    return BackgroundState(
      savedImagePath: savedImagePath ?? this.savedImagePath,
      pendingImagePath: clearPending ? null : (pendingImagePath ?? this.pendingImagePath),
    );
  }
}

class BackgroundNotifier extends Notifier<BackgroundState> {
  @override
  BackgroundState build() {
    // Default background URL
    return BackgroundState(
      savedImagePath: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
    );
  }

  void setPendingImage(String path) {
    state = state.copyWith(pendingImagePath: path);
  }

  void saveChanges() {
    if (state.pendingImagePath != null) {
      state = state.copyWith(
        savedImagePath: state.pendingImagePath,
        clearPending: true,
      );
    }
  }

  void cancelChanges() {
    state = state.copyWith(clearPending: true);
  }
}

final backgroundProvider =
    NotifierProvider<BackgroundNotifier, BackgroundState>(BackgroundNotifier.new);
