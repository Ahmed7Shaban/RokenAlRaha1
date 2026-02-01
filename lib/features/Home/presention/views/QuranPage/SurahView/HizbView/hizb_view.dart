import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../quran/hizb/data/hizb_repository.dart';
import '../../quran/hizb/logic/cubit/hizb_cubit.dart';
import '../../quran/hizb/logic/cubit/hizb_state.dart';
import '../../quran/hizb/presentation/widgets/hizb_card.dart';
import '../../quran/hizb/presentation/widgets/hizb_shimmer_loading.dart';
import '../../last_read/logic/cubit/last_read_cubit.dart';
import '../../last_read/logic/cubit/last_read_state.dart';
import '../../quran_view_page.dart';

class HizbView extends StatelessWidget {
  const HizbView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HizbCubit(HizbRepository()),
      child: const HizbViewBody(),
    );
  }
}

class HizbViewBody extends StatefulWidget {
  const HizbViewBody({super.key});

  @override
  State<HizbViewBody> createState() => _HizbViewBodyState();
}

class _HizbViewBodyState extends State<HizbViewBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkLastRead();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<HizbCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _checkLastRead() {
    final state = context.read<LastReadCubit>().state;
    if (state is LastReadLoaded) {
      context.read<HizbCubit>().updateProgress(state.lastRead);
    }
  }

  void _navigateToPage(int page, int surahNum, int ayahNum) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScreenUtilInit(
          designSize: const Size(392.7, 800.7),
          child: QuranViewPage(
            pageNumber: page,
            jsonData: const [],
            shouldHighlightText: true,
            highlightVerse: " $surahNum$ayahNum",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LastReadCubit, LastReadState>(
      listener: (context, state) {
        if (state is LastReadLoaded) {
          context.read<HizbCubit>().updateProgress(state.lastRead);
        }
      },
      child: BlocBuilder<HizbCubit, HizbState>(
        builder: (context, state) {
          if (state is HizbLoading) {
            return const HizbShimmerLoading();
          } else if (state is HizbLoaded) {
            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 100.h),
              physics: const BouncingScrollPhysics(),
              itemCount: state.hasReachedMax
                  ? state.hizbList.length
                  : state.hizbList.length + 1,
              itemBuilder: (context, index) {
                if (index < state.hizbList.length) {
                  final model = state.hizbList[index];
                  return HizbCard(model: model, onNavigate: _navigateToPage);
                } else {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          } else if (state is HizbError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
