import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:content_offline/helpers/database_helper.dart';
import 'package:content_offline/models/course_detail.dart';
import 'package:content_offline/models/item_holder.dart';
import 'package:content_offline/models/taks_info.dart';
import 'package:content_offline/widgets/download_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloaderPage extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;
  final Course course;

  DownloaderPage({Key key, this.platform, this.course}) : super(key: key);


  @override
  _DownloaderPageState createState() => new _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  final dbHelper = DatabaseHelper.instance;
  
  Course _course;
  List<TaskInfo> _tasks;
  List<ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _course = widget.course;
    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (_tasks != null && _tasks.isNotEmpty) {
        final task = _tasks.firstWhere((task) => task.taskId == id);
        if (task != null) {
          setState(() {
            task.status = status;
            task.progress = progress;
          });
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoading ?
      Center(
        child: CircularProgressIndicator(),
      ) :
      _permissionReady ? _buildDownloadList() : _buildNoPermissionWarning());
  }

  Widget _buildDownloadList() => Container(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: _items
              .map((item) => item.task == null
                  ? _buildListSection(item.name)
                  : DownloadItemWidgetWidget(
                      data: item,
                      onItemClick: (task) {
                        _openDownloadedFile(task).then((success) {
                          if (!success) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Cannot open this file')));
                          }
                        });
                      },
                      onActionClick: (task) {
                        if (task.status == DownloadTaskStatus.undefined) {
                          _requestDownload(task);
                        } else if (task.status == DownloadTaskStatus.running) {
                          _pauseDownload(task);
                        } else if (task.status == DownloadTaskStatus.paused) {
                          _resumeDownload(task);
                        } else if (task.status == DownloadTaskStatus.complete) {
                          _delete(task);
                          _deleteContent(task);
                        } else if (task.status == DownloadTaskStatus.failed) {
                          _retryDownload(task);
                        } else if (task.status == DownloadTaskStatus.canceled) {
                          _deleteContent(task);
                          _requestDownload(task);
                        }
                      },
                      onCancelClick: (task) {
                        if (task.status == DownloadTaskStatus.running) {
                          _cancelDownload(task);
                        }
                      },
                      deleteContentInDb: _deleteContent,
                    ))
              .toList(),
        ),
      );

  Widget _buildListSection(String title) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
        ),
      );

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Please grant accessing storage permission to continue -_-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              FlatButton(
                  onPressed: () {
                    _checkPermission().then((hasGranted) {
                      setState(() {
                        _permissionReady = hasGranted;
                      });
                    });
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ))
            ],
          ),
        ),
      );

  void _requestDownload(TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
    await _saveContent(task);
  }

  void _cancelDownload(TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
    await _deleteContent(task);
  }

  void _pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(TaskInfo task) async {
    await _deleteContent(task);
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
    await _saveContent(task);
  }

  Future<bool> _openDownloadedFile(TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

  void _delete(TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
    await _deleteContent(task);
  }

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];

    _items.add(ItemHolder(name: _course.nombre));

    _course.contenidos.forEach((contenido) {
      if (
        contenido.tipo == 'Video' ||
        contenido.tipo == 'Pdf' ||
        contenido.tipo == 'Imágen'
      ) {
        _tasks.add(
          new TaskInfo(
            name: contenido.nombre,
            courseName: widget.course.nombre,
            link: contenido.getContentUrl(),
            contentId: contenido.id,
            courseId: widget.course.id
          )
        );
      }
    });

    for (int i = count; i < _tasks.length; i++) {
      _items.add(ItemHolder(name: _tasks[i].name, task: _tasks[i]));
      count++;
    }

    tasks?.forEach((task) {
      for (TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // DB queries

  Future<void> _saveContent(TaskInfo task) async {

    List<Map<String, dynamic>> content = 
      await dbHelper.queryFindByContentId(task.contentId);
    
    List<Map<String, dynamic>> listCourses = 
      await dbHelper.queryAllRows();

    print(listCourses);
    if (content.length == 0) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnName           : task.name,
        DatabaseHelper.columnCourseName     : task.courseName,
        DatabaseHelper.columnContentId      : task.contentId,
        DatabaseHelper.columnLink           : task.link,
        DatabaseHelper.columnCourseId       : task.courseId,
      };
      final id = await dbHelper.insert(row);
      print('inserted row id: $id');
    }
  }
  
  Future<void> _deleteContent(TaskInfo task) async {

    int deletedRows = 
      await dbHelper.deleteByContentId(task.contentId);

    print('deleted rows $deletedRows::::::::::::::::::::::::: content id: ${task.contentId} ');
  }

}
