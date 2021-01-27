import 'package:devlog_microblog_client/extensions.dart';
import 'package:devlog_microblog_client/models/posts.dart';
import 'package:devlog_microblog_client/models/userprefs.dart';
import 'package:devlog_microblog_client/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final postListProvider = StateNotifierProvider((ref) => PostListModel());

final settingsProvider = FutureProvider<UserSettingsModel>((ref) async {
  return await UserSettingsModel.load();
});

Widget postListWidget(List<MicroblogEntryItem> entries) {
  final postListModel = PostListModel();
  final _loggedIn = postListModel.tryLogin();
  return FutureBuilder(
    future: _loggedIn,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data) {
          return ListView.builder(
            padding: EdgeInsets.all(8),
            reverse: true,
            itemBuilder: (_, int index) => entries[index],
            itemCount: entries.length,
          );
        }
        return LoginScreen();
      }
      return Center(
        child: CircularProgressIndicator(),
      );
    },
  );
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class MicroblogEntryItem extends StatelessWidget {
  final String title;
  final String text;
  final DateTime date;
  MicroblogEntryItem({this.date, this.title, this.text});

  @override
  Widget build(BuildContext context) {
    final dayStr = date.day.toString().padLeft(2, '0');
    final mthStr = date.month.toString().padLeft(2, '0');
    final dateFormatted = '$dayStr.$mthStr';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dateFormatted,
                  style: Theme.of(context).textTheme.headline5,
                ),
                Text(
                  date.year.toString(),
                  style: Theme.of(context).textTheme.headline6,
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(text.truncateTo(30)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  final List<MicroblogEntryItem> _entries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showPostEntryScreen,
      ),
      appBar: AppBar(
        title: Text('Devlog Microblog Client'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: postListWidget(_entries),
    );
  }

  void _openSettings() {
    Navigator.of(context).pushNamed('/settings');
  }

  void _showPostEntryScreen() {
    Navigator.of(context).pushNamed('/post');
  }
}
