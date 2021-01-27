import 'package:meta/meta.dart';
import 'package:content_offline/models/course_detail.dart';
import 'package:equatable/equatable.dart';

abstract class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object> get props => [];
}

class CourseFetched extends CourseState {
  final Course course;

  const CourseFetched({@required this.course});

  @override
  List<Object> get props => [];
}

class CourseFetchFailure extends CourseState {
  final String error;

  const CourseFetchFailure({this.error});

  @override
  List<Object> get props => [error];
}

class CourseLoading extends CourseState {
  const CourseLoading();
}