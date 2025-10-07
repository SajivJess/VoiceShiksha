class ApiConfig {
  // Configuration for different environments
  
  // Local development (Wi-Fi)
  static const String localWifiUrl = 'http://172.16.73.88:5000';
  
  // Cloud deployment (Railway)
  static const String cloudUrl = 'https://voiceshiksha.up.railway.app';
  
  // Current active URL - change this to switch between local and cloud
  static const String baseUrl = cloudUrl;
  
  // Helper method to check if using cloud
  static bool get isCloudDeployment => baseUrl.startsWith('https://');
  
  // Helper method to get the environment name
  static String get environmentName => isCloudDeployment ? 'Cloud' : 'Local';
}