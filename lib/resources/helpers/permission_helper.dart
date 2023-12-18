
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  requestLocation()async {
    await Permission.location.request();
  }
}