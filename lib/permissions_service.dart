import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Request SMS permission
  Future<bool> requestSmsPermission() async {
    var status = await Permission.sms.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.sms.request();
      return status.isGranted;
    }
    return false;
  }

  // Check if SMS permission is granted
  Future<bool> isSmsPermissionGranted() async {
    var status = await Permission.sms.status;
    return status.isGranted;
  }
}
