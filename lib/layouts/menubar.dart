import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:blueprint_master/editors/editors.dart';
import 'package:flutter/material.dart';

import '../editors/state_machines/state_machines.dart';

class Menubar extends StatefulWidget {
  const Menubar({super.key});

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  @override
  Widget build(BuildContext context) {
    // final DrawCubit drawCubit = context.watch<DrawCubit>();

    final recent = [
      "/Users/liuyang/Desktop/project_test/project1.bm",
      "/Users/liuyang/Desktop/project_test/project2.bm",
      "/Users/liuyang/Desktop/project_test/project3.bm",
    ];

    return MenuBar(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
      ),
      children: [
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              child: Text("New"),
              onPressed: () {},
            ),
            SubmenuButton(
              menuChildren: recent
                  .map(
                    (e) => MenuItemButton(
                      child: Text(e),
                      onPressed: () {},
                    ),
                  )
                  .toList(growable: false),
              child: Text("Open Recent"),
            ),
            MenuItemButton(
              child: Text("Exit"),
              onPressed: () {
                exit(exitCode);
              },
            ),
          ],
          child: Center(child: Text("File")),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              child: Text("Setting"),
              onPressed: () {
                showAboutDialog(context: context);
              },
            ),
          ],
          child: Center(child: Text("Setting")),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              child: Text("About"),
              onPressed: () {},
            ),
            MenuItemButton(child: Text("Feedback"), onPressed: () {}),
            MenuItemButton(child: Text("Document"), onPressed: () {}),
          ],
          child: Center(child: Text("Help")),
        ),
      ],
    );
  }
}
