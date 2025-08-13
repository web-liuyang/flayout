import 'package:flayout/project_manager.dart';
import 'package:flayout/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Menubar extends StatefulWidget {
  const Menubar({super.key});

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  void onCreateProject() {}

  void onOpenProject([String? path]) async {
    path ??= await openProjectSelector();
    if (path == null) return;
    projectManager.openProject(path);
  }

  void onSaveProject() {}

  void onSetting() {}

  void onAbout() {}

  void onFeedback() {}

  void onDocument() {}

  void onExit() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final recent = [
      "/Users/liuyang/Desktop/project_test/project1.bm",
      "/Users/liuyang/Desktop/project_test/project2.bm",
      "/Users/liuyang/Desktop/project_test/project3.bm",
    ];

    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: [
            MenuItemButton(onPressed: onCreateProject, child: Text("New")),
            MenuItemButton(onPressed: onOpenProject, child: Text("Open")),
            SubmenuButton(
              menuChildren: recent
                  .map(
                    (e) => MenuItemButton(
                      onPressed: () => onOpenProject(e),
                      child: Text(e),
                    ),
                  )
                  .toList(growable: false),
              child: Text("Open Recent"),
            ),
            MenuItemButton(onPressed: onSaveProject, child: Text("Save")),
            MenuItemButton(onPressed: onExit, child: Text("Exit")),
          ],
          child: Center(child: Text("File")),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(onPressed: onSetting, child: Text("Setting")),
          ],
          child: Center(child: Text("Setting")),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(onPressed: onDocument, child: Text("Document")),
            MenuItemButton(onPressed: onFeedback, child: Text("Feedback")),
            MenuItemButton(onPressed: onAbout, child: Text("About")),
          ],
          child: Center(child: Text("Help")),
        ),
      ],
    );
  }
}
