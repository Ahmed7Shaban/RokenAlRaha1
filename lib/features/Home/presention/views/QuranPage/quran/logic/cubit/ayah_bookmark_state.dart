import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/ayah_bookmark_model.dart';

abstract class AyahBookmarkState extends Equatable {
  const AyahBookmarkState();

  @override
  List<Object?> get props => [];
}

class AyahBookmarkInitial extends AyahBookmarkState {}

class AyahBookmarkLoading extends AyahBookmarkState {}

class AyahBookmarkLoaded extends AyahBookmarkState {
  final List<AyahBookmarkModel> bookmarks;
  // Map for O(1) lookup during rendering: "surah_verse" -> ColorInt
  final Map<String, int> bookmarkColors;

  const AyahBookmarkLoaded(this.bookmarks, this.bookmarkColors);

  @override
  List<Object?> get props => [bookmarks, bookmarkColors];

  Color? getColor(int surah, int verse) {
    final key = "${surah}_$verse";
    final colorVal = bookmarkColors[key];
    if (colorVal == null) return null;
    return Color(colorVal);
  }

  bool isBookmarked(int surah, int verse) {
    return bookmarkColors.containsKey("${surah}_$verse");
  }
}

class AyahBookmarkError extends AyahBookmarkState {
  final String message;

  const AyahBookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}
