import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReportsAndStatisticsPage(),
    );
  }
}

class ReportsAndStatisticsPage extends StatefulWidget {
  @override
  _ReportsAndStatisticsPageState createState() =>
      _ReportsAndStatisticsPageState();
}

class _ReportsAndStatisticsPageState extends State<ReportsAndStatisticsPage> {
  SharedPreferences? prefs;
  SharedPreferences? pref;
  SharedPreferences? pre;

  int s = 0;
  List<String> c = [];
  List<FlSpot> spots = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    pref = await SharedPreferences.getInstance();
    pre = await SharedPreferences.getInstance();

    setState(() {
      s = (prefs!.getInt('cree') ?? 0) +
          (prefs!.getInt('stock') ?? 0) +
          (prefs!.getInt('expedie') ?? 0) +
          (prefs!.getInt('recu') ?? 0);
      print(s);

      c = pref!.getStringList('c') ?? [];
      print(c);

      spots = [];
      for (int i = 1; i < c.length; i += 2) {
        double x = i.toDouble();
        double y = double.tryParse(c[i]) ?? 0;
        spots.add(FlSpot(x, y));
      }
      print(spots);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapports et Statistiques'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Répartition des êtres humains',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    String text;
                                    switch (value.toInt()) {
                                      case 1:
                                        text = 'Client';
                                        break;
                                      case 2:
                                        text = 'Ouner';
                                        break;
                                      case 3:
                                        text = 'Transporteur';
                                        break;
                                      case 4:
                                        text = 'Fournisseur';
                                        break;
                                      default:
                                        text = '';
                                    }
                                    return Text(text,
                                        style: TextStyle(fontSize: 12));
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                      toY: (pref!.getInt('client') ?? 0)
                                          .toDouble(),
                                      color: Colors.blue),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                      toY: (pref!.getInt('ouner') ?? 0)
                                          .toDouble(),
                                      color: Colors.blue),
                                ],
                              ),
                              BarChartGroupData(
                                x: 3,
                                barRods: [
                                  BarChartRodData(
                                      toY: (pref!.getInt('Transporteur') ?? 0)
                                          .toDouble(),
                                      color: Colors.blue),
                                ],
                              ),
                              BarChartGroupData(
                                x: 4,
                                barRods: [
                                  BarChartRodData(
                                      toY: (pref!.getInt('Fournisseur') ?? 0)
                                          .toDouble(),
                                      color: Colors.blue),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Répartition des états de produits',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                        value: ((prefs!.getInt('cree') ??
                                                    0 * 100) /
                                                (s))
                                            .toDouble(),
                                        color: Colors.blue,
                                        title: 'Créé'),
                                    PieChartSectionData(
                                        value: ((prefs!.getInt('stock') ??
                                                    0 * 100) /
                                                (s))
                                            .toDouble(),
                                        color: Colors.green,
                                        title: 'Stock'),
                                    PieChartSectionData(
                                        value: ((prefs!.getInt('expedie') ??
                                                    0 * 100) /
                                                (s))
                                            .toDouble(),
                                        color: Colors.orange,
                                        title: 'Expédié'),
                                    PieChartSectionData(
                                        value: ((prefs!.getInt('recu') ??
                                                    1 * 100) /
                                                (s))
                                            .toDouble(),
                                        color: Colors.red,
                                        title: 'Reçu'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Répartition des commandes',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      color: Colors.blue,
                                      dotData: FlDotData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              flex: 1,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildKPI('Ventes', (pre!.getInt('p') ?? 0).toString(),
                          Colors.blue),
                      _buildKPI(
                          'Clients',
                          (pref!.getInt('client') ?? 0).toString(),
                          Colors.green),
                      _buildKPI('Revenus', (pre!.getInt('s') ?? 0).toString(),
                          Colors.orange),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPI(String title, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    );
  }
}
