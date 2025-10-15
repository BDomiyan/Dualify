/// Predefined trade options matching the HTML design
class TradeOptions {
  static const List<String> trades = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Welder',
  ];

  static bool isValidTrade(String trade) {
    return trades.contains(trade);
  }
}
