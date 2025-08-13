import 'package:flayout/services/services.dart';
import 'package:flutter/foundation.dart';

class ProjectManager {
  final ValueNotifier<Project?> projectNotifier = ValueNotifier<Project?>(null);

  Project? get project => projectNotifier.value;

  void createProject(String path) {}

  void openProject(String path) {
    projectNotifier.value = projectService.readProject(path);
  }

  void saveProject() {}

  void closeProject() {
    projectNotifier.value = null;
  }
}

final ProjectManager projectManager = ProjectManager();
