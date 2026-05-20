/// Carrier configuration for USSD vs IVR routing.
///
/// JIO does not support *99# USSD — use NPCI 123PAY IVR instead.
/// All other carriers use standard USSD (*99#) via url_launcher.
///
/// TODO (Future): When Firebase Phone Auth is integrated, also verify carrier
/// at registration time by cross-referencing the phone number prefix ranges.

class CarrierConfig {
  final String key;
  final String displayName;
  final String emoji;
  final bool usesIvr;
  final String? ivrNumber;
  final String? ivrLabel;

  const CarrierConfig({
    required this.key,
    required this.displayName,
    required this.emoji,
    this.usesIvr = false,
    this.ivrNumber,
    this.ivrLabel,
  });
}

const List<CarrierConfig> supportedCarriers = [
  CarrierConfig(
    key: 'jio',
    displayName: 'Jio',
    emoji: '📱',
    usesIvr: true,
    ivrNumber: '08045163666',
    ivrLabel: '123PAY by NPCI',
  ),
  CarrierConfig(
    key: 'airtel',
    displayName: 'Airtel',
    emoji: '📡',
  ),
  CarrierConfig(
    key: 'vi',
    displayName: 'Vi (Vodafone Idea)',
    emoji: '📶',
  ),
  CarrierConfig(
    key: 'bsnl',
    displayName: 'BSNL',
    emoji: '🏛️',
  ),
  CarrierConfig(
    key: 'other',
    displayName: 'Other',
    emoji: '📲',
  ),
];

/// Get a CarrierConfig by its stored key string.
CarrierConfig getCarrierByKey(String key) {
  return supportedCarriers.firstWhere(
    (c) => c.key == key,
    orElse: () => supportedCarriers.last, // fallback to 'other'
  );
}
