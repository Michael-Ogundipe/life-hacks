// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class PackagePreivewScrollNotifier extends StateNotifier<ScrollState> {
//   final ScrollController scrollController;
//
//   PackagePreivewScrollNotifier(this.scrollController) : super(ScrollState()) {
//     scrollController.addListener(_scrollListener);
//   }
//
//   void _scrollListener() {
//     final newState = state.copyWith(
//       showLeftButton: scrollController.offset > 0,
//       showRightButton:
//           scrollController.offset < scrollController.position.maxScrollExtent,
//     );
//     state = newState;
//   }
//
//   void scrollLeft() {
//     scrollController.animateTo(
//       scrollController.offset - 207.w,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   void scrollRight() {
//     scrollController.animateTo(
//       scrollController.offset + 207.w,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   void dispose() {
//     scrollController.dispose();
//     super.dispose();
//   }
// }
//
// class ScrollState {
//   final bool showLeftButton;
//   final bool showRightButton;
//
//   ScrollState({this.showLeftButton = false, this.showRightButton = true});
//
//   ScrollState copyWith({bool? showLeftButton, bool? showRightButton}) {
//     return ScrollState(
//       showLeftButton: showLeftButton ?? this.showLeftButton,
//       showRightButton: showRightButton ?? this.showRightButton,
//     );
//   }
// }
//
// final scrollNotifierProvider = StateNotifierProvider.family<
//     PackagePreivewScrollNotifier,
//     ScrollState,
//     ScrollController>((ref, scrollController) {
//   return PackagePreivewScrollNotifier(scrollController);
// });
