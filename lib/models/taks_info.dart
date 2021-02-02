import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:meta/meta.dart';

class TaskInfo {
  final String name;
  final String courseName;
  final String link;
  final int courseId;
  final int contentId;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  TaskInfo({@required this.name, @required this.courseName, this.link, @required this.courseId, @required this.contentId});
}