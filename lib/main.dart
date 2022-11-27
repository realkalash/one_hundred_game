import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const Scaffold(
        body: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final numberController = TextEditingController();
  final numerFieldFocus = FocusNode();
  final List<int> numbers = [];

  final magicNumbers = [
    12,
    23,
    34,
    45,
    56,
    67,
    78,
    89,
  ];

  var currentSum = 0;
  bool isGoodNumber = false;
  int countLooses = 0;
  int countWins = 0;
  double chanceToLoose = 0;
  int countChancesViewPressed = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newGame();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isEndGame = currentSum >= 100;
    final isWin = isEndGame && _isUserTurn() && isGoodNumber;
    final winLooseTextColor = isEndGame == false
        ? null
        : isWin
            ? Colors.green
            : Colors.red;
    _calculateChancesBot();
    return Column(
      children: [
        Wrap(
          spacing: 10,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor)),
              child: Text(
                'Losses: $countLooses',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 30,
                ),
              ),
            ),
            GestureDetector(
              onLongPress: _enableViewChances,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor)),
                child: Text(
                  'Wins: $countWins',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Current sum: ${currentSum > 100 ? '100+' : currentSum}',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(color: winLooseTextColor),
                  ),
                  Visibility(
                    visible: countChancesViewPressed > 4,
                    child: Text(
                      'Chances to loose: ${chanceToLoose.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headline5?.copyWith(
                          color: Colors.red.withOpacity(chanceToLoose / 100)),
                    ),
                  ),
                  if (isEndGame)
                    Text(
                      isWin ? 'You win!' : 'You lose!',
                      style: Theme.of(context).textTheme.headline3?.copyWith(
                            color: winLooseTextColor,
                          ),
                    ),
                  const Divider(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      numbers.length,
                      (index) {
                        final sumNumbers = numbers
                            .sublist(0, index + 1)
                            .reduce((a, b) => a + b);
                        if (_currentIndexIsUserTurn(index)) {
                          return Text(
                              'You entered number: ${numbers[index]}. (Sum: $sumNumbers)');
                        } else {
                          return Text(
                            'Bot entered number: ${numbers[index]}. Your turn. (Sum: $sumNumbers)',
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(height: 8),
                  TextField(
                    controller: numberController,
                    focusNode: numerFieldFocus,
                    keyboardType: TextInputType.number,
                    enabled: isEndGame == false,
                    onSubmitted: !isEndGame ? _submitNumber : null,
                    onChanged: _verifyNumber,
                    decoration: InputDecoration(
                      hintText: 'Enter a number and press Enter or button',
                      label: const Text('Number'),
                      errorText: isGoodNumber
                          ? null
                          : 'Write a number between 1 and 10',
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          for (var i = 1; i <= 10; i++)
                            ActionChip(
                              label: Text('$i'),
                              onPressed: isEndGame
                                  ? null
                                  : () {
                                      numberController.text = '$i';
                                      _submitNumber('$i');
                                    },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: !isEndGame
                              ? () => _submitNumber(numberController.text)
                              : null,
                          child: const Text('Enter'),
                        ),
                        ElevatedButton(
                          onPressed: () => _removeLastNumber(),
                          child: const Text('Remove last'),
                        ),
                        ElevatedButton(
                          onPressed: _newGame,
                          child: const Text('New Game'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _currentIndexIsUserTurn(int value) {
    return value % 2 == 1;
  }

  bool _isUserTurn() {
    final result = numbers.length % 2 == 0;
    return result;
  }

  void _verifyNumber(String number) {
    if (number.isEmpty) {
      setState(() {
        isGoodNumber = false;
      });
      return;
    }
    final numberInt = int.tryParse(number) ?? 0;
    if (numberInt < 1 || numberInt > 10) {
      setState(() {
        isGoodNumber = false;
      });
      return;
    }
    setState(() {
      isGoodNumber = true;
    });
  }

  void _submitNumber(String value) {
    _verifyNumber(value);
    if (!isGoodNumber) {
      return;
    }
    final number = int.parse(value);
    setState(() {
      isGoodNumber = true;
      numbers.add(number);
      currentSum += number;
    });
    if (currentSum >= 100) {
      return;
    }
    _submitNumberFromBot(number);
    numerFieldFocus.requestFocus();

    /// select value field
    numberController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: numberController.text.length,
    );
  }

  Future<void> _newGame() async {
    setState(() {
      if (currentSum >= 100) {
        if (_isUserTurn()) {
          countWins++;
        } else {
          countLooses++;
        }
      }
      numbers.clear();
      isGoodNumber = false;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      numbers.add(Random().nextInt(1) + 1);
      currentSum = numbers.first;
    });

    numerFieldFocus.requestFocus();
  }

  void _submitNumberFromBot(int number) {
    int botResult = 0;
    if (currentSum <= 70) {
      /// To mess up the user. The user will think that the bot enters random numbers.
      botResult = Random().nextInt(10) + 1;
    } else {
      if (currentSum == 70) {
        botResult = 8;
      } else if (currentSum == 71) {
        botResult = 7;
      } else if (currentSum == 72) {
        botResult = 6;
      } else if (currentSum == 73) {
        botResult = 5;
      } else if (currentSum == 74) {
        botResult = 4;
      } else if (currentSum == 75) {
        botResult = 3;
      } else if (currentSum == 76) {
        botResult = 2;
      } else if (currentSum == 77) {
        botResult = 1;
      } else if (currentSum == 78) {
        botResult = 1;
      } else if (currentSum == 79) {
        botResult = 10;
      } else if (currentSum == 80) {
        botResult = 9;
      } else if (currentSum == 81) {
        botResult = 8;
      } else if (currentSum == 82) {
        botResult = 7;
      } else if (currentSum == 83) {
        botResult = 6;
      } else if (currentSum == 84) {
        botResult = 5;
      } else if (currentSum == 85) {
        botResult = 4;
      } else if (currentSum == 86) {
        botResult = 3;
      } else if (currentSum == 87) {
        botResult = 2;
      } else if (currentSum == 88) {
        botResult = 1;
      } else if (currentSum == 89) {
        botResult = 1;
      } else if (currentSum == 90) {
        botResult = 10;
      } else if (currentSum == 91) {
        botResult = 9;
      } else if (currentSum == 92) {
        botResult = 8;
      } else if (currentSum == 93) {
        botResult = 7;
      } else if (currentSum == 94) {
        botResult = 6;
      } else if (currentSum == 95) {
        botResult = 5;
      } else if (currentSum == 96) {
        botResult = 4;
      } else {
        botResult = 1;
      }
    }
    setState(() {
      numbers.add(botResult);
      currentSum += botResult;
    });
  }

  void _removeLastNumber() {
    if (_isUserTurn()) {
      setState(() {
        currentSum -= numbers.removeLast();
      });
    } else {
      setState(() {
        currentSum -= numbers.removeLast();
        currentSum -= numbers.removeLast();
      });
    }
  }

  void _calculateChancesBot() {
    double result = 0;
    if (magicNumbers.contains(currentSum)) {
      final index = magicNumbers.indexOf(currentSum);
      result = 1 / (magicNumbers.length - index + 2);
    }
    if (currentSum >= 12 && currentSum <= 23) {
      result = 1 / 7;
    } else if (currentSum >= 23 && currentSum <= 34) {
      result = 1 / 6;
    } else if (currentSum >= 34 && currentSum <= 45) {
      result = 1 / 5;
    } else if (currentSum >= 45 && currentSum <= 56) {
      result = 1 / 4;
    } else if (currentSum >= 56 && currentSum <= 67) {
      result = 1 / 3;
    } else if (currentSum >= 67 && currentSum <= 78) {
      result = 1 / 2;
    } else if (currentSum >= 78 && currentSum <= 89) {
      result = 1 / 1;
    }
    chanceToLoose = result * 100;
  }

  void _enableViewChances() {
    setState(() {
      countChancesViewPressed += 1;
    });
  }
}
