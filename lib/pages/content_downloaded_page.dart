import 'package:content_offline/helpers/database_helper.dart';
import 'package:content_offline/models/item_holder.dart';
import 'package:content_offline/models/taks_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class ContentDownloadedPage extends StatefulWidget {
  final Map<String, dynamic> item;
  
  const ContentDownloadedPage({Key key, this.item}) : super(key: key);

  @override
  _ContentDownloadedPageState createState() => _ContentDownloadedPageState();
}

class _ContentDownloadedPageState extends State<ContentDownloadedPage> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _courses = [];
  bool _loading = true;
  List<TaskInfo> _tasks = [];
  List<ItemHolder> _items = [];

  @override
  void initState() { 
    super.initState();
    _getContents();
  }

  void _getContents() async {
    _courses = await dbHelper.queryAllContentGroupedByCourseId(
      this.widget.item[DatabaseHelper.columnCourseId]
    );
    print('CONTENTS::::::::: $_courses');
    _prepare();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(this.widget.item != null ? this.widget.item[DatabaseHelper.columnCourseName] : 'Contenido offline' ),
      ),
      // body: null
      body: ListView(
        children: _createItems(_items, context)
      )
    );
  }

  List<Widget>_createItems(List<ItemHolder> _items, BuildContext context) {

    return _items != null ? _items.map((item) => Column(
      children: [
        ListTile(
          title: Text(item.name),
          trailing: Icon(Icons.keyboard_arrow_right, color: Colors.blue),
          onTap: () {
            _openDownloadedFile(item.task).then((success) {
              if (!success) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Cannot open this file')));
              }
            });
          },
        ),
        Divider()
      ],
    )).toList() : [];
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    _tasks = [];
    _items = [];

    _courses.forEach((contenido) {
      
      _tasks.add(
          new TaskInfo(
            name: contenido[DatabaseHelper.columnName],
            courseName: contenido[DatabaseHelper.columnCourseName],
            link: contenido[DatabaseHelper.columnLink],
            contentId: contenido[DatabaseHelper.columnContentId],
            courseId: contenido[DatabaseHelper.columnCourseId],
          )
        );
    });

    for (int i = 0; i < _tasks.length; i++) {
      _items.add(ItemHolder(name: _tasks[i].name, task: _tasks[i]));
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

    setState(() {
      _loading = false;
    });
  }

  Future<bool> _openDownloadedFile(TaskInfo task) {
    return FlutterDownloader.open(taskId: task.taskId);
  }

}