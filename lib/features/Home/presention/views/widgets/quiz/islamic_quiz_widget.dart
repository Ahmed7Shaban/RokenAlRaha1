import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/quiz_cubit.dart';
import 'widgets/quiz_main_card.dart';

class IslamicQuizWidget extends StatelessWidget {
  const IslamicQuizWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCubit()..loadQuestions(),
      child: QuizMainCard(),
    );
  }
}
