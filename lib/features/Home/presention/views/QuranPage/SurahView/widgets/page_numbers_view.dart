import 'package:flutter/material.dart';
import 'package:easy_container/easy_container.dart';
import 'package:quran/quran.dart';

class PageNumbersView extends StatelessWidget {
  final List pageNumbers;

  const PageNumbersView({super.key, required this.pageNumbers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      reverse: true,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pageNumbers.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey.withOpacity(.5)),
      itemBuilder: (ctx, index) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: EasyContainer(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pageNumbers[index].toString()),
                  Text(
                    getSurahName(getPageData(pageNumbers[index])[0]["surah"]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
