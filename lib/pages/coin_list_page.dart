import 'package:cion_app/pages/coin_detail_page.dart';
import 'package:flutter/material.dart';
import '../models/crypto_coin.dart';
import '../services/api_service.dart';
import '../services/coin_service.dart';

class CoinListPage extends StatefulWidget {
  @override
  _CoinListPageState createState() => _CoinListPageState();
}

class _CoinListPageState extends State<CoinListPage> {
  late Future<List<CryptoCoin>> _futureCoins;
  List<CryptoCoin> _allCoins = [];
  List<CryptoCoin> _filteredCoins = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _futureCoins = ApiService.fetchCoins();
    _futureCoins.then((coins) {
      setState(() {
        _allCoins = coins;
        _filteredCoins = coins;
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCoins = _allCoins.where((coin) {
        return coin.name.toLowerCase().contains(query) ||
            coin.symbol.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredCoins = _allCoins;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF0F1E2D),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar moeda...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            )
          : Text('Criptomoedas', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFF0D1B2A),
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Painel criptográfico',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Criptomoedas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar moeda...',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<CryptoCoin>>(
              future: _futureCoins,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhuma moeda encontrada', style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredCoins.length,
                  itemBuilder: (context, index) {
                    final coin = _filteredCoins[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B2A41),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Image.network(coin.image, width: 40, height: 40),
                        title: Text(
                          '${coin.name} (${coin.symbol.toUpperCase()})',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '\$${coin.price.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          '${coin.percentage.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: coin.percentage >= 0 ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FutureBuilder(
                                future: fetchPriceHistory(coin.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Scaffold(
                                      body: Center(child: CircularProgressIndicator()),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Scaffold(
                                      body: Center(child: Text('Erro: ${snapshot.error}')),
                                    );
                                  }

                                  final coinWithHistory = CryptoCoin(
                                    name: coin.name,
                                    symbol: coin.symbol,
                                    image: coin.image,
                                    price: coin.price,
                                    percentage: coin.percentage,
                                    priceHistory: snapshot.data!,
                                    id: coin.id,
                                  );

                                  return CoinDetailPage(coin: coinWithHistory);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
