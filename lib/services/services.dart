import 'package:flayout/repositories/models/models.dart';
import 'package:flayout/repositories/repositories.dart';

class Project {
  Project({required this.path, required this.model});

  final String path;

  final ProjectModel model;
}

class ProjectService {
  Project readProject(String path) {
    final ProjectModel model = projectRepository.read(path);
    return Project(path: path, model: model);
  }

  void saveProject(Project project) {
    projectRepository.write(project.path, project.model);
  }

  void saveAsProject(Project project, String path) {
    projectRepository.write(path, project.model);
  }
}

final ProjectService projectService = ProjectService();
