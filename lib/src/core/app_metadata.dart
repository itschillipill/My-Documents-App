class AppMetadata {
  final String version;
  final String buildNumber;
  final String appName;
  final String packageId;
  
  const AppMetadata({
    required this.version,
    required this.buildNumber,
    required this.appName,
    required this.packageId,
  });
  
  factory AppMetadata.fromPlatform({
    required String version,
    required String buildNumber,
  }) {
    return AppMetadata(
      version: '1.0.0',
      buildNumber: '123',
      appName: 'My Documents',
      packageId: 'com.itschillipill.my_documents',
    );
  }
  
  String get userAgent => '$appName/$version (build $buildNumber)';
}