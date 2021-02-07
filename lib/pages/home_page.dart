import 'package:content_offline/bloc/course_bloc.dart';
import 'package:content_offline/bloc/course_event.dart';
import 'package:content_offline/bloc/course_state.dart';
import 'package:content_offline/managers/course_manager.dart';
import 'package:content_offline/models/course_detail.dart';
import 'package:content_offline/pages/course_downloaded_page.dart';
import 'package:content_offline/pages/downloader_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CourseBloc>(
      create: (context) {
        return CourseBloc(
          courseManager: CourseManager()
        );
      },
      child: HomePageWindow(
        title: title,
      ),
    );
  }
}


class HomePageWindow extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;
  final String title;

  HomePageWindow({Key key, this.title, this.platform}) : super(key: key);


  @override
  _MyHomePageStateWindow createState() => new _MyHomePageStateWindow();
}


class _MyHomePageStateWindow extends State<HomePageWindow> {

  bool _courseFetched = false;
  Course _course;
  bool _isLoading;

  @override
  void initState() {
    super.initState();

    _isLoading = true;
    _course = Course(contenidos: []);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final platform = Theme.of(context).platform;

    Widget body = Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.cloud_download
        ),
        onPressed: () {
          Route route = MaterialPageRoute(
            builder: (_) => CourseDownloadedPage(
              title: 'Contenido offline',
            ),
          );
          Navigator.push(context, route);
        },
      ),
      body: Builder(
        builder: (context) => _isLoading ? new Center(
            child: new CircularProgressIndicator(),
          )
        : DownloaderPage(
          platform: platform,
          course: _course,
        ),
      ),
    );

    if (!_courseFetched) {
      BlocProvider.of<CourseBloc>(context).add(CourseInitial(
        idCurso: 11196,
        idAsociado: 10041
      ));
      _courseFetched = true;
    }

    return BlocListener<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseFetched) {
          setState(() {
            _course = state.course;
            _isLoading = false;
          });
        }

        if (state is CourseLoading) {
          _isLoading = true;
          setState(() {});
        }
      },
      child: body,
    );
  }

}

