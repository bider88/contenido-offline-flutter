import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object> get props => [];
}

class CourseInitial extends CourseEvent {
  final int idCurso;
  final int idAsociado;

  const CourseInitial({@required this.idCurso, @required this.idAsociado});

  @override
  List<Object> get props => [idCurso, idAsociado];
}