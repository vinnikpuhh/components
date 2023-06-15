import 'package:flutter/material.dart';
import 'package:components/components.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buttonWithBS(
                context,
                'Open bottomsheet switch',
                Center(
                  child: AppSwitch(
                    isActive: true,
                    onToggled: (bool active) {},
                  ),
                ),
              ),
              buttonWithBS(
                context,
                'Open bottomsheet pattern lock',
                PatternLock(width: 3, height: 3, onEntered: (_) {}),
              ),
              buttonWithBS(
                context,
                'Open bottomsheet scrolable calendar',
                CalendarRangePickerDialog(
                  firstDate: DateTime(
                    2020,
                    1,
                    1,
                  ),
                  lastDate: DateTime.now(),
                  onEndDateChanged: (DateTime? date) {
                    /*   setState(() => endDay = date); */
                  },
                  onStartDateChanged: (DateTime? date) {
                    /* setState(() => startDay = date); */
                  },
                  confirmText: '',
                  currentDate: null,
                  helpText: '',
                  onCancel: () {},
                  onConfirm: () {},
                  selectedEndDate: null,
                  selectedStartDate: null,
                  size: MediaQuery.of(context).size,
                  rangeDateTextStyle: const TextStyle(),
                  titleTextStyle: const TextStyle(),
                ),
              ),
              buttonWithBS(
                context,
                'Open bottomsheet loading buttons',
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoaderButton(
                        onPressed: () {},
                        type: ButtonType.elevated,
                        loading: true,
                        child: const Text("Loading"),
                      ),
                      LoaderButton(
                        onPressed: () {},
                        type: ButtonType.elevated,
                        loading: false,
                        child: const Text("No Loading"),
                      ),
                    ],
                  ),
                ),
              ),
              buttonWithBS(
                context,
                'Open bottomsheet square buttons',
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareButton.color(
                        borderRadius: 10.0,
                        color: Colors.green,
                        onPressed: () {},
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SquareButton.customDecoration(
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            border: Border.all(color: Colors.black)),
                        onPressed: () {},
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SquareButton.gradient(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.blue],
                        ),
                        onPressed: () {},
                        borderRadius: 8.0,
                        size: 40.0,
                        border: Border.all(color: Colors.purple),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonWithBS(BuildContext context, String title, Widget child) {
    return ElevatedButton(
      onPressed: () => openBS(
        paddingBS: 0,
        context: context,
        height: MediaQuery.of(context).size.height,
        heightBS: MediaQuery.of(context).size.height * 0.9,
        width: MediaQuery.of(context).size.width,
        child: child,
      ),
      child: Text(title),
    );
  }
}
