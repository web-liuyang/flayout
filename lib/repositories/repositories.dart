import 'dart:convert';
import 'dart:io';

import 'models/models.dart';

abstract class Repository<T> {
  T read(String path);

  void write(String path, T model);
}

class ProjectRepository extends Repository<ProjectModel> {
  @override
  ProjectModel read(String path) {
    final String jsonString = File(path).readAsStringSync();
    final Map<String, dynamic> map = json.decode(jsonString);
    return ProjectModel();
  }

  @override
  void write(String path, ProjectModel model) {}
}

final ProjectRepository projectRepository = ProjectRepository();
