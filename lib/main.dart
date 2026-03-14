import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drink Water Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

// ------------------- MODEL -------------------
class WaterLog {
  final int id;
  final String time;
  final int amount;
  final String note;

  WaterLog({
    required this.id,
    required this.time,
    required this.amount,
    required this.note,
  });

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'],
      time: json['time'],
      amount: json['amount'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'time': time, 'amount': amount, 'note': note};
  }
}

// ------------------- GLOBAL STATE -------------------
int dailyGoal = 2500;
int totalDrank = 0;
List<WaterLog> logs = [];

final List<Map<String, dynamic>> quickAmounts = [
  {'label': 'Küçük Bardak', 'amount': 150, 'icon': Icons.local_drink},
  {'label': 'Büyük Bardak', 'amount': 250, 'icon': Icons.local_drink},
  {'label': 'Şişe (500ml)', 'amount': 500, 'icon': Icons.water_drop},
  {'label': 'Şişe (1L)', 'amount': 1000, 'icon': Icons.water},
];

// ------------------- ANA SAYFA -------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void drinkWater(int amount, String label) {
    setState(() {
      totalDrank += amount;
      logs.insert(
        0,
        WaterLog(
          id: logs.length + 1,
          time: TimeOfDay.now().format(context),
          amount: amount,
          note: label,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$amount ml içildi! 💧'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void resetDay() {
    setState(() {
      totalDrank = 0;
      logs.clear();
    });
  }

  double get progress => (totalDrank / dailyGoal).clamp(0.0, 1.0);
  bool get goalReached => totalDrank >= dailyGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💧 Su Takipçim'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(
              context,
              '/history',
            ).then((_) => setState(() {})),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(
              context,
              '/settings',
              arguments: {'currentGoal': dailyGoal},
            ).then((_) => setState(() {})),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HEDEF KARTI
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: goalReached ? Colors.green[50] : Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      goalReached ? '🎉 Hedefe Ulaştın!' : '💧 Günlük Hedef',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: goalReached ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goalReached ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$totalDrank',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ml / $dailyGoal ml',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        goalReached ? Colors.green : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goalReached
                          ? 'Tebrikler! Günlük hedefe ulaştın.'
                          : 'Kalan: ${(dailyGoal - totalDrank).clamp(0, dailyGoal)} ml',
                      style: TextStyle(
                        color: goalReached ? Colors.green : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // HIZLI EKLE BAŞLIĞI
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hızlı Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // GRIDVIEW
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: quickAmounts.length,
              itemBuilder: (context, index) {
                final item = quickAmounts[index];
                return GestureDetector(
                  onTap: () => drinkWater(item['amount'], item['label']),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'], color: Colors.blue, size: 32),
                        const SizedBox(height: 6),
                        Text(
                          item['label'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${item['amount']} ml',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // SON İÇİLENLER
            if (logs.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Son İçilenler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length > 3 ? 3 : logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.water_drop, color: Colors.blue),
                      title: Text('${log.amount} ml'),
                      subtitle: Text(log.note),
                      trailing: Text(
                        log.time,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 16),

            // SIFIRLA BUTONU
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: resetDay,
                icon: const Icon(Icons.refresh, color: Colors.red),
                label: const Text(
                  'Günü Sıfırla',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- GEÇMİŞ SAYFASI -------------------
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text(
                'Henüz kayıt yok.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.water_drop, color: Colors.blue),
                    ),
                    title: Text('${log.amount} ml - ${log.note}'),
                    subtitle: Text('Saat: ${log.time}'),
                    trailing: Text(
                      '#${log.id}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ------------------- AYARLAR SAYFASI -------------------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int selectedGoal;

  final List<int> goalOptions = [1500, 2000, 2500, 3000, 3500];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    selectedGoal = args?['currentGoal'] ?? dailyGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Günlük Su Hedefi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Günlük içmek istediğin su miktarını seç:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: goalOptions.length,
              itemBuilder: (context, index) {
                final goal = goalOptions[index];
                final isSelected = goal == selectedGoal;
                return Card(
                  color: isSelected ? Colors.blue[50] : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.water_drop,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    title: Text(
                      '$goal ml',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.blue : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedGoal = goal;
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  dailyGoal = selectedGoal;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hedef $dailyGoal ml olarak ayarlandı!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
