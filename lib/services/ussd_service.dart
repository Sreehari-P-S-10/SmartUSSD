import 'package:url_launcher/url_launcher.dart';

class UssdService {
  /// Launches a USSD code via the tel: URI scheme
  Future<void> launchUSSD(String code) async {
    final encoded = Uri.encodeComponent(code);
    final uri = Uri.parse('tel:$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Cannot launch USSD: $code');
    }
  }

  /// Builds the *99# send money USSD string
  String buildSendMoneyCode(String phone, String amount) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    return '*99*1*1*$cleanPhone*$amount#';
  }

  /// Builds the balance check USSD code
  String buildBalanceCode({String bank = 'Universal'}) {
    const codes = {
      'SBI': '*99*41#',
      'HDFC': '*99*42#',
      'ICICI': '*99*43#',
      'Axis': '*99*44#',
      'Universal': '*99#',
    };
    return codes[bank] ?? '*99#';
  }

  /// Builds the mini statement USSD code
  String buildStatementCode({String bank = 'Universal'}) {
    const codes = {
      'SBI': '*99*42#',
      'HDFC': '*99*43#',
      'ICICI': '*99*44#',
      'Axis': '*99*45#',
      'Universal': '*99#',
    };
    return codes[bank] ?? '*99#';
  }
}
