import 'package:flutter/material.dart';
import '../models/crypto_coin.dart';
import '../services/favorites_maneger.dart';
import 'coin_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final List<CryptoCoin> favorites = FavoritesManager.favorites;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Favoritas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma moeda favoritada ainda.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final coin = favorites[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2A41),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(coin.image),
                    ),
                    title: Text(
                      '${coin.name} (${coin.symbol.toUpperCase()})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.white54),
                      onPressed: () {
                        setState(() {
                          FavoritesManager.removeFavorite(coin);
                        });
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CoinDetailPage(coin: coin),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
    );
  }
}
