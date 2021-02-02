import 'package:content_offline/models/item_holder.dart';
import 'package:flutter/material.dart';

class ContentDownloadedPage extends StatelessWidget {
  final String title;
  final List<ItemHolder> courses;
  
  const ContentDownloadedPage({Key key, this.title, this.courses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(title != null ? title : 'Contenido offline' ),
      ),
      body: null
      // body: ListView(
      //   children: _createItems(courses, context)
      // )
    );
  }

  List<Widget>_createItems(List<ItemHolder> courses, BuildContext context) {

    return courses.map((course) => Column(
      children: [
        ListTile(
          title: Text(course.name),
          trailing: Icon(Icons.keyboard_arrow_right, color: Colors.blue),
          onTap: () {
            // final route = MaterialPageRoute(
            //   builder: (ontext) => AlertPage()
            // );
            // Navigator.push(context, route);
          },
        ),
        Divider()
      ],
    )).toList();
  }
}