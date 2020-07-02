# rich_input

这是一个高性能的富媒体输入框，通过原生的 textfield 扩展实现，具有较小的破坏性，同时具有较强的扩展性，实现了@某人，#话题，表情等功能，支持自定义高亮

文档语言: [English](README.md) | [中文简体](README-ZH.md)

## 特色功能

-   用较少的代码，尽量使用原生的 textfield 能力，减少破坏性及后续兼容性
-   支持@某人 #话题 插入表情等
-   支持自定义高亮效果，及自定义样式
-   支持自定义 data 字段，增强富文本的能力

![Demo](demo.png)

## 开始入门

核心代码

```dart
RichInputController controller = RichInputController(text: "Text");

const block = RichBlock(
  text: " @abc ",
  data: " @123456 ",
  style: TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  ),
);
controller.addBlock(block);
// Get custom data
print(controller.data);
// Get text
print(controller.text);

// RichInput(controller: controller);
```

详细示例

```dart
import 'package:flutter/material.dart';
import 'package:rich_input/rich_input.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RichInputController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    _controller = RichInputController(text: "Text");

    // Refresh text display, not required
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichInput(
                focusNode: _focusNode,
                controller: _controller,
              ),
              Wrap(
                spacing: 10,
                children: [
                  RaisedButton(
                    onPressed: () {
                      _controller.text += "Text";
                    },
                    child: const Text("Add Text"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _controller.text += "😁";
                    },
                    child: const Text("Add 😁"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _controller.text += "👍";
                    },
                    child: const Text("Add 👍"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      const block = RichBlock(
                        text: " @abc ",
                        data: " @123456 ",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                      _controller.addBlock(block);
                    },
                    child: const Text("Add @    "),
                  ),
                  RaisedButton(
                    onPressed: () {
                      const block = RichBlock(
                        text: " #subject ",
                        data: " #888999 ",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                      _controller.addBlock(block);
                    },
                    child: const Text("Add #"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      _focusNode.unfocus();
                    },
                    child: const Text("unfocus"),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text("Text:${_controller.text}"),
              const SizedBox(height: 10),
              Text("Data:${_controller.data}"),
            ],
          ),
        ),
      ),
    );
  }
}
```

> [详细示例，请查看](example/lib/main.dart)
