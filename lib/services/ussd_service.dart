import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/carrier_config.dart';

class UssdService {
  /// Returns the user's stored carrier key (e.g. 'jio', 'airtel').
  Future<String> getCarrier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_carrier') ?? 'other';
  }

  /// Returns true if the user is on Jio (IVR-based payments).
  Future<bool> isJioUser() async => (await getCarrier()) == 'jio';

  /// Returns the CarrierConfig for the registered carrier.
  Future<CarrierConfig> getCarrierConfig() async {
    final key = await getCarrier();
    return getCarrierByKey(key);
  }

  // ─── IVR (Jio 123PAY) ────────────────────────────────────────────────────

  /// Launches an IVR call to NPCI 123PAY for Jio users.
  Future<void> launchIVR() async {
    const ivrNumber = '08045163666';
    final uri = Uri.parse('tel:$ivrNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Cannot launch call to $ivrNumber');
    }
  }

  // ─── USSD (Non-Jio) ──────────────────────────────────────────────────────

  /// Launches a USSD code via the tel: URI scheme (non-Jio carriers).
  Future<void> launchUSSD(String code) async {
    final encoded = Uri.encodeComponent(code);
    final uri = Uri.parse('tel:$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Cannot launch USSD: $code');
    }
  }

  /// Unified launcher: auto-detects carrier and routes to IVR or USSD.
  /// Returns true if IVR was used (Jio), false if USSD was used.
  Future<bool> launchPayment(String ussdCode) async {
    if (await isJioUser()) {
      await launchIVR();
      return true;
    } else {
      await launchUSSD(ussdCode);
      return false;
    }
  }

  // ─── USSD Code Builders ──────────────────────────────────────────────────

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
