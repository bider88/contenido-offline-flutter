import 'package:content_offline/models/course_detail.dart';
import 'package:content_offline/repositories/course_repository.dart';

class CourseManager {
  Future<Course> getCourse(int idCurso, int idAsociado) async {
    CourseRepository repository = CourseRepository();
    Course course = await repository.getCourse(
        courseId: idCurso, userId: idAsociado);
    return course;
  }
}
