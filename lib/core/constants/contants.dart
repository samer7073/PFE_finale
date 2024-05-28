class ConstantesPage {
  //final String Dns = 'sphereauthbackdev.cmk.biz';
  final int Port = int.parse("4543");
  final String Login = 'login';
  late Uri baseUrl;

  ConstantesPage(String url) {
    baseUrl = Uri(
      scheme: 'https',
      port: Port,
      host: url,
      path: '/index.php/api/mobile/$Login',
    );
  }
}
