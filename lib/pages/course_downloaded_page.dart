import 'package:content_offline/helpers/database_helper.dart';
import 'package:content_offline/pages/content_downloaded_page.dart';
import 'package:flutter/material.dart';


class CourseDownloadedPage extends StatefulWidget {

  final String title;

  const CourseDownloadedPage({Key key, this.title}) : super(key: key);

  @override
  _CourseDownloadedPageState createState() => _CourseDownloadedPageState();
}

class _CourseDownloadedPageState extends State<CourseDownloadedPage> {
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() { 
    super.initState();
    _getCourses();
  }

  void _getCourses() async {
    _items = await dbHelper.queryAllCoursesGrouped();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title != null ? widget.title : 'Contenido offline' ),
      ),
      body: _loading ? 
      Center(
        child: CircularProgressIndicator(),
      ) :
      _getMainWidget(_items, context)
    );
  }

  Widget _getMainWidget(List<Map<String, dynamic>> items, BuildContext context) {
    return _items.length > 0 ? 
    ListView(
      children: _createItems(_items, context)
    ) : 
    Center(
      child: Text('No hay cursos descargados aún'),
    );
  }

  List<Widget>_createItems(List<Map<String, dynamic>> items, BuildContext context) {

    return items.map((content) => Column(
      children: [
        ListTile(
          title: Text(content[DatabaseHelper.columnCourseName]),
          trailing: Icon(Icons.keyboard_arrow_right, color: Colors.blue),
          onTap: () {
            final route = MaterialPageRoute(
              builder: (context) => ContentDownloadedPage(
                item: content
              )
            );
            Navigator.push(context, route);
          },
        ),
        Divider()
      ],
    )).toList();
  }
}
