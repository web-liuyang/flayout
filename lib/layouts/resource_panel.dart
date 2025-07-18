import 'package:blueprint_master/editors/editors.dart';
import 'package:blueprint_master/editors/graphics/graphics.dart';
import 'package:flutter/material.dart';

class RootGraphicInfo {
  final String title;

  final RootGraphic graphic;

  RootGraphicInfo({required this.title, required this.graphic});
}

final List<RootGraphicInfo> infos = [
  RootGraphicInfo(
    title: "Cell_1",
    graphic: RootGraphic(
      children: [
        PolygonGraphic(vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50), Offset(-50, -50)]),
      ],
    ),
  ),
  RootGraphicInfo(
    title: "Cell_2",
    graphic: RootGraphic(
      children: [
        PolygonGraphic(vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50), Offset(-50, -50)]),
        CircleGraphic(position: Offset(0, 0), radius: 50),
      ],
    ),
  ),
];

class ResourcePanel extends StatefulWidget {
  const ResourcePanel({super.key});

  @override
  State<ResourcePanel> createState() => _ResourcePanelState();
}

class _ResourcePanelState extends State<ResourcePanel> {
  final TextEditingController controller = TextEditingController();
  String get searchValue => controller.text;

  @override
  Widget build(BuildContext context) {
    final List<RootGraphicInfo> filteredInfos = infos.where((info) => info.title.contains(searchValue)).toList(growable: false);

    // TextField;

    return Column(
      children: [
        Container(height: 32, padding: EdgeInsets.only(left: 8), child: Row(children: [Text("Resources")])),
        Divider(height: 1),
        TextField(
          // constraints: ,
          decoration: const InputDecoration(hintText: "Search", prefixIcon: Icon(Icons.search), suffixIcon: Icon(Icons.clear, size: 12)),
          controller: controller,
          // placeholder: "Search",
          // shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          // padding: WidgetStateProperty.all(EdgeInsets.zero),
          scrollPadding: EdgeInsets.zero,
          // leading: Icon(Icons.search),
          // trailing: [
          //   IconButton(
          //     onPressed: () {
          //       setState(() {
          //         controller.text = "";
          //       });
          //     },
          //     icon: Icon(Icons.clear),
          //   ),
          // ],
          onSubmitted: (value) {
            setState(() {
              controller.text = value;
            });

            print(value);
          },
        ),
        Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              final title = filteredInfos[index].title;
              return ListTile(
                title: Text(title),
                onTap: () {
                  editorManager.createEditor(EditorConfig(title: title));
                },
              );
            },
            itemCount: filteredInfos.length,
          ),
        ),
      ],
    );
  }
}
