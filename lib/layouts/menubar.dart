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

    return MenuBar(
      // style: MenuStyle(alignment: Alignment.centerLeft),
      children: [
        SubmenuButton(
          onClose: () {},
          onOpen: () {},
          onFocusChange: (value) {},
          onHover: (value) {},
          menuChildren: [
            MenuItemButton(
              child: Text("About"),
              onPressed: () {
                showAboutDialog(context: context);
              },
            ),
            MenuItemButton(child: Text("Feedback"), onPressed: () {}),
          ],
          child: Container(child: Text("Help")),
        ),

        // SubmenuButton(menuChildren: [MenuItemButton(child: Text("Setting"))], child: MenuItemButton(child: Text("Help"))),
      ],
    );
  }
}
