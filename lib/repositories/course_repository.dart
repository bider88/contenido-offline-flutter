import 'dart:io';

import 'package:content_offline/models/course_detail.dart';
import 'package:content_offline/repositories/base_repository.dart';
import 'package:content_offline/repositories/endpoint_exceptions.dart';
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

import 'dart:convert';

class CourseRepository extends BaseRepository {

  Future<Course> getCourse(
      {@required int courseId, @required int userId}) async {
    String url = formatEndpoint('/asociados/cursos/$courseId?idAsociado=$userId');
    print("Endpoint: $url");
    try {
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      Map<String, String> requestHeaders = {
        "Content-Type": "application/json; charset=utf-8"
      };

      final http = IOClient(ioc);
      var httpResponse = await http.get(url, headers: requestHeaders);
      String decoded = utf8.decode(httpResponse.bodyBytes);
      Course course = Course.fromJson(json.decode(decoded));
      return course;
    } on EndpointException {
      throw GetCourseFailure();
    } catch (error) {
      print(error);
      return null;
    }
  }

}
