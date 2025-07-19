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
        PolygonGraphic(vertices: [Offset(-150, -150), Offset(-100, -150), Offset(-100, -100), Offset(-150, -100), Offset(-150, -150)]),
      ],
    ),
  ),
  RootGraphicInfo(
    title: "Cell_2",
    graphic: RootGraphic(
      children: [
        PolygonGraphic(vertices: [Offset(-50, -50), Offset(50, -50), Offset(50, 50), Offset(-50, 50), Offset(-50, -50)]),
        CircleGraphic(center: Offset(0, 0), radius: 50),
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

    return Column(
      textBaseline: TextBaseline.alphabetic,
      children: [
        Container(height: 32, padding: EdgeInsets.only(left: 8), child: Row(children: [Text("Resources")])),
        Divider(height: 1),
        TextField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 10),
            hintText: "Search",
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(onPressed: () => setState(() => controller.text = ""), icon: Icon(Icons.clear)),
          ),
          controller: controller,
          scrollPadding: EdgeInsets.zero,
          onSubmitted: (value) => setState(() => controller.text = value),
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
