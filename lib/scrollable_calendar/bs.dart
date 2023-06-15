/*  openBS(
                  paddingBS: 0,
                  context: context,
                  height: screenSize.height,
                  heightBS: screenSize.height * 0.9,
                  width: screenSize.width,
                  child: CalendarRangePickerDialog(
                    firstDate: minDate,
                    lastDate: DateTime.now(),
                    onEndDateChanged: (DateTime? date) {
                      setState(() => endDay = date);
                    },
                    onStartDateChanged: (DateTime? date) {
                      setState(() => startDay = date);
                    },
                    confirmText: '',
                    currentDate: null,
                    helpText: '',
                    onCancel: () {},
                    onConfirm: () {},
                    selectedEndDate: endDay,
                    selectedStartDate: startDay,
                    size: MediaQuery.of(context).size,
                  )).whenComplete(() async {
                await BlocProvider.of<MainCubit>(context)
                    .getTransaction(filterDate: true);
                setState(() {});
              }); */



import 'package:flutter/material.dart';

Future openBS({
  required BuildContext context,
  required double? height,
  required double? heightBS,
  required double width,
  required Widget child,
  double? paddingBS,
}) async {
  return showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent /* black.withOpacity(0.5) */,
    context: context,
    builder: (BuildContext ctx) {
      return Column(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox.expand(),
            ),
          ),
          Container(
            height: 5,
            width: 60,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              width: width,
              height: heightBS,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              padding: EdgeInsets.all(paddingBS ?? 30),
              child: child),
        ],
      );
    },
  );
}
