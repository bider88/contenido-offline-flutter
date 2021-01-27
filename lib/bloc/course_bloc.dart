import 'package:content_offline/managers/course_manager.dart';
import 'package:content_offline/models/course_detail.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:content_offline/bloc/course_event.dart';
import 'package:content_offline/bloc/course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseManager courseManager;

  CourseBloc({CourseState initialState, @required this.courseManager})
      : assert(courseManager != null),
        super(initialState);

  @override
  Stream<CourseState> mapEventToState(CourseEvent event) async* {
    if (event is CourseInitial) {
      yield CourseLoading();
      try {

        Course course = await courseManager.getCourse(event.idCurso, event.idAsociado);

        yield CourseFetched(
          course: course,
        );
      } catch (error) {
        yield CourseFetchFailure(error: error.toString());
      }
    }
  }
}