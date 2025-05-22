import 'package:cion_app/main_menu.dart';
import 'package:cion_app/pages/favorites_page.dart';
import 'package:cion_app/services/favorites_maneger.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/crypto_coin.dart';

class CoinDetailPage extends StatelessWidget {
  final CryptoCoin coin;

  const CoinDetailPage({Key? key, required this.coin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      '${coin.name} (${coin.symbol.toUpperCase()})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      bool isFav = FavoritesManager.isFavorite(coin);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          isFav
                              ? FavoritesManager.removeFavorite(coin)
                              : FavoritesManager.addFavorite(coin);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A41),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Histórico de preços',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${coin.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '24h ${coin.percentage >= 0 ? '+' : ''}${coin.percentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: coin.percentage >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: coin.priceHistory != null
                                ? List.generate(
                                    coin.priceHistory!.length,
                                    (index) => FlSpot(
                                      index.toDouble(),
                                      coin.priceHistory![index],
                                    ),
                                  )
                                : [],
                            isCurved: true,
                            color: Colors.lightBlueAccent,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.lightBlueAccent.withOpacity(0.2),
                            ),
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('00:00', style: TextStyle(color: Colors.white38)),
                      Text('06:00', style: TextStyle(color: Colors.white38)),
                      Text('12:00', style: TextStyle(color: Colors.white38)),
                      Text('18:00', style: TextStyle(color: Colors.white38)),
                      Text('23:00', style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Principais impulsionadores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatTile(Icons.local_fire_department, 'Valor total de mercado', '\$1.2T', '+3.1%'),
            const SizedBox(height: 16),
            _buildStatTile(Icons.bar_chart, 'Volume de negociação de 24 h', '\$100B', '+2.5%'),
            const SizedBox(height: 16),
            _buildStatTile(Icons.pie_chart, 'Dominância (ETH)', '18%', '-1.2%'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF182B3A),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF7C93B2),
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainMenu()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FavoritesPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite,), label: 'Favoritos'),
        ],
      ),
    );
  }

  Widget _buildStatTile(IconData icon, String title, String value, String percentage) {
    bool isPositive = percentage.contains('+');
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2233),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A3146),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  percentage,
                  style: TextStyle(color: isPositive ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
