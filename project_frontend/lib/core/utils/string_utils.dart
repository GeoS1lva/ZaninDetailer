class StringUtils {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatCurrency(double amount) {
    return "R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}";
  }
}
