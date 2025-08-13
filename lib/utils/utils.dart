import 'package:file_selector/file_selector.dart';

Future<String?> openProjectSelector() async {
  const XTypeGroup typeGroup = XTypeGroup(
    label: 'flayout project',
    extensions: <String>['fdb'],
  );
  final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

  return file?.path;
}
