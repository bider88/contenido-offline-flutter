abstract class BaseRepository {

  String formatEndpoint(String endpoint) {
    return 'https://wd.brainb.mx:9092' + endpoint;
  }
}
