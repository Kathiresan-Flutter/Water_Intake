import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WaterIntakeApp());
}

class WaterIntakeApp extends StatelessWidget {
  const WaterIntakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Water Intake App",
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WaterIntakeHomePage(),
    );
  }
}

class WaterIntakeHomePage extends StatefulWidget {
  const WaterIntakeHomePage({super.key});

  @override
  State<WaterIntakeHomePage> createState() => _WaterIntakeHomePageState();
}

class _WaterIntakeHomePageState extends State<WaterIntakeHomePage> {
  int _waterIntake = 0;
  int _dailyGoal = 8;
  final List<int> _dailyGoalOptions = [8, 10, 12, 15];

  Future<void> _loadPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = pref.getInt('waterIntake') ?? 0;
      _dailyGoal = pref.getInt('dailyGoal') ?? 8;
    });
  }

  @override
  void initState() {
    _loadPreferences();
    super.initState();
  }

  Future<void> _incrementWaterIntake() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (_waterIntake < _dailyGoal) {
    setState(() {
      _waterIntake++;
      pref.setInt('waterIntake', _waterIntake);
      if (_waterIntake >= _dailyGoal) {
        showGoalReachedDialog();
      }
    });
  }
}

  Future<void> _resetWaterIntake() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = 0;
      pref.setInt('waterIntake', _waterIntake);
    });
  }

  Future<void> _setDailyGoal(int newGoal) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = newGoal;
      pref.setInt('dailyGoal', newGoal);
    });
  }

  Future<void> showGoalReachedDialog() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Congratulations!!!"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                      "You have reached your daily goal of $_dailyGoal glasses of water"),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"))
            ],
          );
        });
  }

  Future<void> _resetConfirmationDialgo() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Reset WaterIntake"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: [
                  Text("Are you sure want to reset your WaterIntake?"),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _resetWaterIntake();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Reset")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _waterIntake / _dailyGoal;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Intake"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(
                Icons.water_drop,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "You have consumed :",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "$_waterIntake glasss of water",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 10,
              ),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                minHeight: 20,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Daily Goal",
                style: TextStyle(fontSize: 18),
              ),
              DropdownButton(
                  value: _dailyGoal,
                  items: _dailyGoalOptions.map((int value) {
                    return DropdownMenuItem(
                        value: value, child: Text("$value glasses"));
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      _setDailyGoal(newValue);
                    }
                  }),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: _waterIntake < _dailyGoal ? _incrementWaterIntake : null,
                  child: const Text("Add a glass of water")),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: _resetConfirmationDialgo,
                  child: const Text("Reset"))
            ],
          ),
        ),
      ),
    );
  }
}
