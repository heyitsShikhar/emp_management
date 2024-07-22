enum AccessPermission {
  viewAllEmployees,
  viewAttendance,
  addNewEmployees,
  checkInCheckOut,
  manageAccess,
}

extension AccessPermissionExtension on AccessPermission {
  String get name {
    switch (this) {
      case AccessPermission.viewAllEmployees:
        return 'View all employees';
      case AccessPermission.viewAttendance:
        return 'View attendance';
      case AccessPermission.addNewEmployees:
        return 'Add new employees';
      case AccessPermission.checkInCheckOut:
        return 'Check-in/Check-out';
      case AccessPermission.manageAccess:
        return 'Manage Access';
    }
  }
  
  static AccessPermission? fromName(String name) {
    switch (name) {
      case 'View all employees':
        return AccessPermission.viewAllEmployees;
      case 'View attendance':
        return AccessPermission.viewAttendance;
      case 'Add new employees':
        return AccessPermission.addNewEmployees;
      case 'Check-in/Check-out':
        return AccessPermission.checkInCheckOut;
      case 'Manage Access':
        return AccessPermission.manageAccess;
      default:
        return null;
    }
  }
}
