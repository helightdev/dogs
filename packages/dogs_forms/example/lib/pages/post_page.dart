/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'package:example/form_print_wrapper.dart';
import 'package:example/models/address.dart';
import 'package:example/models/post.dart';
import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormPrintWrapper<Post>(
      exampleValue: Post(
        "Hello World",
        "This is a post",
        "John Doe",
        DateTime.now(),
        ["hello", "world"],
      ),
      modelCode: """
@serializable
class Post {
  final String? title;
  final String content;
  final String author;
  final DateTime date;
  final List<String> tags;

  Post(this.title, this.content, this.author, this.date, this.tags);
}
""".trim(),
    );
  }
}
