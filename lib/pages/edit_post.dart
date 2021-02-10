import 'package:devlog_microblog_client/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PostEditScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Post post = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Single post'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Markdown(
            data: post.text,
          ),
        ),
      ),
    );
  }
}
