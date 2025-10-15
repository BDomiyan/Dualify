import '../../../../core/constants/app_strings.dart';

/// Predefined trade options matching the HTML design
/// This class now references the centralized AppStrings.tradeOptions
class TradeOptions {
  static List<String> get trades => AppStrings.tradeOptions;

  static bool isValidTrade(String trade) {
    return AppStrings.tradeOptions.contains(trade);
  }
}
