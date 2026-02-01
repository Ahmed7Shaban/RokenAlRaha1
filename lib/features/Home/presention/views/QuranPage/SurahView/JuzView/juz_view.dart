import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/juz/logic/cubit/juz_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/juz/logic/cubit/juz_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/quran/juz/presentation/widgets/juz_card.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_cubit.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/logic/cubit/last_read_state.dart';
import 'package:roken_al_raha/features/Home/presention/views/QuranPage/last_read/data/models/last_read_model.dart';

import '../../quran/juz/data/juz_repository.dart';

class JuzView extends StatelessWidget {
  const JuzView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JuzCubit(JuzRepository()),
      child: const JuzViewBody(),
    );
  }
}

class JuzViewBody extends StatefulWidget {
  const JuzViewBody({super.key});

  @override
  State<JuzViewBody> createState() => _JuzViewBodyState();
}

class _JuzViewBodyState extends State<JuzViewBody> {
  @override
  void initState() {
    super.initState();
    // Verify LastRead status on init
    _updateProgressFromContext();
  }

  void _updateProgressFromContext() {
    final lastReadState = context.read<LastReadCubit>().state;
    if (lastReadState is LastReadLoaded && lastReadState.lastRead != null) {
      context.read<JuzCubit>().updateProgress(
        lastReadState.lastRead!.pageNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LastReadCubit, LastReadState>(
      listener: (context, state) {
        if (state is LastReadLoaded && state.lastRead != null) {
          context.read<JuzCubit>().updateProgress(state.lastRead!.pageNumber);
        }
      },
      child: BlocBuilder<JuzCubit, JuzState>(
        builder: (context, state) {
          if (state is JuzLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is JuzLoaded) {
            // Get last read page for navigation
            LastReadModel? lastReadModel;
            final lastReadState = context.read<LastReadCubit>().state;
            if (lastReadState is LastReadLoaded) {
              lastReadModel = lastReadState.lastRead;
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // Space for bottom elements
              physics: const BouncingScrollPhysics(),
              itemCount: state.juzList.length,
              itemBuilder: (context, index) {
                final model = state.juzList[index];
                return JuzCard(model: model, lastRead: lastReadModel);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
