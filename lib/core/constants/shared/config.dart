// lib/config.dart

import 'dart:developer';

import '../../../services/sharedPreference.dart';

class Config {
  //static const String prodUrl = "https://sphere.comunikcrm.info";
  static const String prodUrl = "https://sphere-back.comunikcrm.info";
  static const String devUrl = "https://spherebackdev.cmk.biz";

  static const Map<String, String> apiProdUrls = {
    "kanban": "$prodUrl:4543/index.php/api/mobile/kanban-by-stage",
    "tasksKpi": "$prodUrl:4543/index.php/api/mobile/tasks/kpi",
    "login":
        "https://authentificationbackback.comunikcrm.info:4543/index.php/api/mobile/login",
    "overview": "$prodUrl:4543/index.php/api/mobile/log-family-elements",
    "updateStageFamily":
        "$prodUrl:4543/index.php/api/mobile/update-stage-family",
    "otpGenerate": "$prodUrl:4543/index.php/api/mobile/generate-otp",
    "loginOtp": "$prodUrl:4543/index.php/api/mobile/login-otp",
    "logout":
        "https://authentificationbackback.comunikcrm.info:4543/index.php/api/mobile/logout",
    "kpiFamily": "$prodUrl:4543/index.php/api/mobile/kpi-family",
    "profile":
        "https://sphere-back.comunikcrm.info:4543/index.php/api/mobile/profile",
    "modifyProfile": "$prodUrl:4543/index.php/api/mobile/edit-profile",
    "pipelines": "$prodUrl:4543/index.php/api/mobile/pipelines-by-family",
    "jwt": "https://sphere-chat-back.comunikcrm.info:4543/api/user",
    "generateOtp":
        "$prodUrl:4543/index.php/api/mobile/generate-otp", // Added for ApiOtpGenrate
    "loginOtpUrl":
        "$prodUrl:4543/index.php/api/mobile/login-otp", // Added for ApiOtpGenrate
    "logoutUrl":
        "https://sphereauthbackdev.cmk.biz:4543/index.php/api/logout", // Added for ApiLogout
    "kpiFamilyUrl":
        "$prodUrl:4543/index.php/api/mobile/kpi-family", // Added for ApiKpiFamily
    "profileUrl":
        "$prodUrl:4543/index.php/api/mobile/profile", // Added for ApiProfil
    "editProfileUrl":
        "$prodUrl:4543/index.php/api/mobile/edit-profile", // Added for ApiProfil
    "pipelinesUrl":
        "$prodUrl:4543/index.php/api/mobile/pipelines-by-family", // Added for GetPipelineApi
    "jwtUrl":
        "https://sphere-chat-back.comunikcrm.info:4543/api/user", // Added for ApiGetJwt
    "createElementUrl":
        "$prodUrl:4543/index.php/api/mobile/create-element", // Added for ApiFieldPost
    "updateElementUrl":
        "$prodUrl:4543/index.php/api/mobile/update-element", // Added for ApiFieldPost
    "groupFieldsUrl":
        "$prodUrl:4543/index.php/api/mobile/get-group-fields-by-family",
    "fieldsByGroupUrl":
        "$prodUrl:4543/index.php/api/mobile/get-fields-by-group",
    "fieldsByGroupUpdateUrl":
        "$prodUrl:4543/index.php/api/mobile/get-fields-by-group",
    "familyModuleData": "$prodUrl:4543/index.php/api/mobile/get-family-module",
    "countries":
        "https://sphere-back.comunikcrm.info:4543/index.php/api/mobile/get-countries",
    "currencies":
        "https://sphere-back.comunikcrm.info:4543/index.php/api/mobile/get-currencies",
    "getDetail": "$prodUrl:4543/index.php/api/mobile/get-element-by-id",
    "deleteElement": "$prodUrl:4543/index.php/api/mobile/delete-elements",
    "changePassword": "$prodUrl:4543/index.php/api/change-password",
    "getTasks360": "$prodUrl:4543/index.php/api/mobile/get-tasks-360",
    "getElementsByFamily":
        "$prodUrl:4543/index.php/api/mobile/get-elements-by-family",
    "getDirectory": "$prodUrl:4543/index.php/api/mobile/get-directory",
    "getElementDetails":
        "$prodUrl:4543/index.php/api/mobile/get-element-details",
    "getTasksCalendar": "$prodUrl:4543/api/mobile/tasks/get/calendar",
    "addChatRoomToTask": "$prodUrl:4543/api/mobile/tasks/{taskId}/update/room",
    "updateChatRoomForTask":
        "$prodUrl:4543/api/mobile/update-task/room/{taskId}",
    "createTask": "$prodUrl:4543/api/mobile/tasks/create",
    "deleteTasks": "$prodUrl:4543/api/mobile/tasks/delete",
    "fetchFamilies": "$prodUrl:4543/api/mobile/get-families",
    "fetchRelatedModules":
        "$prodUrl:4543/api/mobile/get-label-elements-by-family",
    "getPipelines": "$prodUrl:4543/api/mobile/pipelines-by-module-system",
    "fetchStages": "$prodUrl:4543/api/mobile/pipelines-by-module-system/task",
    "fetchTaskLogs": "$prodUrl:4543/api/mobile/tasks/log",
    "markAsRead": "$prodUrl:4543/api/mobile/tasks/make-log-read",
    "markAllAsRead": "$prodUrl:4543/api/mobile/tasks/make-all-logs-read",
    "notificationNumber": "$prodUrl:4543/api/mobile/tasks/notification-number",
    "dashboardData": "$prodUrl:4543/api/mobile/tasks/dashboard",
    "updateStageFamilyTask": "$prodUrl:4543/api/mobile/tasks/update/stage",
    "updateTask": "$prodUrl:4543/api/mobile/tasks",
    "getTaskDetails": "$prodUrl:4543/api/mobile/tasks",
    "fetchTasks": "$prodUrl:4543/api/mobile/tasks",
    "fetchUsers": "$prodUrl:4543/api/mobile",
    "fetchGuests": "$prodUrl:4543/api/mobile",
    "kanbanTask": "$prodUrl:4543/index.php/api/mobile",
    "tasksConfig": "$prodUrl:4543/api/mobile/tasks/config",
    "updatePriority": "$prodUrl:4543/api/mobile",
    "mercure": "https://mercurecmk.comunikcrm.info:4443/.well-known/mercure",
    "notifTopic": "/notification/dev/user/",
    "chatTopic": "/chat/dev/user/232",
    "urlImage": "https://sphere-back.comunikcrm.info:4543/storage/uploads/",
    "taskNotif": "$prodUrl:4543/api/mobile/tasks/",
    "pipeline": "$prodUrl:4543/index.php/api/mobile/get-element-by-id/",
    "StageKanban": "$prodUrl:4543/index.php/api/mobile/stages/",

    // Added for ApiFieldGroup
  };

  static const Map<String, String> apiDevUrls = {
    "kanban": "$devUrl:4543/index.php/api/mobile/kanban-by-stage",
    "tasksKpi": "$devUrl:4543/index.php/api/mobile/tasks/kpi",
    "login":
        "https://sphereauthbackdev.cmk.biz:4543/index.php/api/mobile/login",
    "overview": "$devUrl:4543/index.php/api/mobile/log-family-elements",
    "updateStageFamily":
        "$devUrl:4543/index.php/api/mobile/update-stage-family",
    "otpGenerate": "$devUrl:4543/index.php/api/mobile/generate-otp",
    "loginOtp": "$devUrl:4543/index.php/api/mobile/login-otp",
    "logout": "https://sphereauthbackdev.cmk.biz:4543/index.php/api/logout",
    "kpiFamily": "$devUrl:4543/index.php/api/mobile/kpi-family",
    "profile": "$devUrl:4543/index.php/api/mobile/profile",
    "modifyProfile": "$devUrl:4543/index.php/api/mobile/edit-profile",
    "pipelines": "$devUrl:4543/index.php/api/mobile/pipelines-by-family",
    "jwt": "https://spherechatbackdev.cmk.biz:4543/index.php/api/user",
    "generateOtp":
        "$devUrl:4543/index.php/api/mobile/generate-otp", // Added for ApiOtpGenrate
    "loginOtpUrl":
        "$devUrl:4543/index.php/api/mobile/login-otp", // Added for ApiOtpGenrate
    "logoutUrl":
        "https://sphereauthbackdev.cmk.biz:4543/index.php/api/logout", // Added for ApiLogout
    "kpiFamilyUrl":
        "$devUrl:4543/index.php/api/mobile/kpi-family", // Added for ApiKpiFamily
    "profileUrl":
        "$devUrl:4543/index.php/api/mobile/profile", // Added for ApiProfil
    "editProfileUrl":
        "$devUrl:4543/index.php/api/mobile/edit-profile", // Added for ApiProfil
    "pipelinesUrl":
        "$devUrl:4543/index.php/api/mobile/pipelines-by-family", // Added for GetPipelineApi
    "jwtUrl":
        "https://spherechatbackdev.cmk.biz:4543/index.php/api/user", // Added for ApiGetJwt
    "createElementUrl":
        "$devUrl:4543/index.php/api/mobile/create-element", // Added for ApiFieldPost
    "updateElementUrl":
        "$devUrl:4543/index.php/api/mobile/update-element", // Added for ApiFieldPost
    "groupFieldsUrl":
        "$devUrl:4543/index.php/api/mobile/get-group-fields-by-family", // Added for ApiFieldGroup
    "fieldsByGroupUrl": "$devUrl:4543/index.php/api/mobile/get-fields-by-group",
    "fieldsByGroupUpdateUrl":
        "$devUrl:4543/index.php/api/mobile/get-fields-by-group",
    "familyModuleData": "$devUrl:4543/index.php/api/mobile/get-family-module",
    "countries": "$devUrl:4543/index.php/api/mobile/get-countries",
    "currencies": "$devUrl:4543/index.php/api/mobile/get-currencies",
    "getDetail": "$devUrl:4543/index.php/api/mobile/get-element-by-id",
    "deleteElement":
        "$devUrl:4543/index.php/api/mobile/delete-elements", // Ajouté ici
    "changePassword": "$devUrl:4543/index.php/api/change-password",
    "getTasks360": "$devUrl:4543/index.php/api/mobile/get-tasks-360",
    "getElementsByFamily":
        "$devUrl:4543/index.php/api/mobile/get-elements-by-family",
    "getDirectory": "$devUrl:4543/index.php/api/mobile/get-directory",
    "getElementDetails":
        "$devUrl:4543/index.php/api/mobile/get-element-details",
    "getTasksCalendar": "$devUrl:4543/api/mobile/tasks/get/calendar",
    "createTask": "$devUrl:4543/api/mobile/tasks/create",
    "deleteTasks": "$devUrl:4543/api/mobile/tasks/delete",
    "fetchFamilies": "$devUrl:4543/api/mobile/get-families",
    "fetchRelatedModules":
        "$devUrl:4543/api/mobile/get-label-elements-by-family",
    "getPipelines": "$devUrl:4543/api/mobile/pipelines-by-module-system",
    "fetchStages": "$devUrl:4543/api/mobile/pipelines-by-module-system/task",
    "fetchTaskLogs": "$devUrl:4543/api/mobile/tasks/log",
    "markAsRead": "$devUrl:4543/api/mobile/tasks/make-log-read",
    "markAllAsRead": "$devUrl:4543/api/mobile/tasks/make-all-logs-read",
    "notificationNumber": "$devUrl:4543/api/mobile/tasks/notification-number",
    "dashboardData": "$devUrl:4543/api/mobile/tasks/dashboard",
    "updateStageFamilyTask": "$devUrl:4543/api/mobile/tasks/update/stage",
    "updateTask": "$devUrl:4543/api/mobile/tasks",
    "getTaskDetails": "$devUrl:4543/api/mobile/tasks",
    "fetchTasks": "$devUrl:4543/api/mobile/tasks",
    "fetchUsers": "$devUrl:4543/api/mobile",
    "fetchGuests": "$devUrl:4543/api/mobile",
    "kanbanTask": "$devUrl:4543/index.php/api/mobile",
    "tasksConfig": "$devUrl:4543/api/mobile/tasks/config",
    "updatePriority": "$devUrl:4543/api/mobile",
    "mercure": "https://spheremercuredev.cmk.biz:4443/.well-known/mercure",
    "notifTopic": "/notification/dev/user/",
    "chatTopic": "/chat/dev/user/232",
    "urlImage": "$devUrl:4543/storage/uploads/",
    "taskNotif": "$devUrl:4543/api/mobile/tasks/",
    "pipeline": "$devUrl:4543/index.php/api/mobile/get-element-by-id/",
    "StageKanban": "$devUrl:4543/index.php/api/mobile/stages/"
  };

  static Future<String> getApiUrl(String apiName) async {
    final isProd = await SharedPrefernce.getIsProd();
    log("isProd //////////////////////////////////////= $isProd");
    if (isProd!) {
      return apiProdUrls[apiName] ?? "";
    } else {
      return apiDevUrls[apiName] ?? "";
    }
  }
}
