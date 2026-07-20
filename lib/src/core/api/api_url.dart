class ApiUrl {
  const ApiUrl._();

  // static const baseUrl = "http://192.168.1.13:8000/api/v1/"; // TEST
  static const baseUrl = "https://backend.inorotech.in/api/v1/"; // LIVE

  // static const privacy_url = "https://theperpetuity.com/privacy-policy";
  //
  // static const terms_condition_url = "https://theperpetuity.com/terms-and-conditions";
  //
  // static const refund_url = "https://theperpetuity.com/refund-policy";

  static const login = "technician/login";

  static const logout = "auth/logout";
  
  static const technicianForgotPassword = "auth/technician-forgot-password";
  
  static const appSettings = "technician/app-settings";
  
  static const fcmRegister = "auth/fcm-register";

  static const upcomingAmcVisits = "technician/dashboard/upcoming-amc-visits";

  static const technicianAmcs = "technician/amcs";

  static const amcVisitReports = "technician/amcs/visit/";

  static const customerAmcVisits = "technician/amcs/report/visits/";

  static const profileDetails = "technician/profile";

  static const technicianDeleteAccount = "technician/delete-account/";

  static const customerDropdown = "technician/dropdowns/customers";

  static const siteDropdown = "technician/dropdowns/sites";

  static const technicians = "technician/dropdowns/technicians";

  static const activeTechniciansServiceCalls = "technician/service-calls/technicians/dropdown";

  static const commissioningWork = "technician/commissioning-works";

  static const commissioningWorkCreate = "technician/commissioning-work/create";

  static const commissioningWorkUpdate = "technician/commissioning-works";

  static const commissioningWorkDelete = "technician/commissioning-works";

  static const serviceCallsAssigned = "technician/service-calls/assign-technicians";

  static const  assignTechnicianServiceCalls = 'technician/service-calls/assign-technicians';

  static const  closeOverCall = 'technician/service-calls/close-over-call';

  static const  serviceWorkReportStep1 = 'technician/service-work-report-step1';

  static const  serviceWorkReportStep2 = 'technician/service-work-report-step2';

  static const  serviceWorkReportStep2AutoFill = 'technician/service-work-report-step2/';

  static const  serviceWorkReportStep3 = 'technician/service-work-report-step3';

  static const  serviceWorkReportStep3AutoFill = 'technician/service-work-report-step3/';

  static const  serviceWorkReportStep4 = 'technician/service-work-report-step4';

  static const  serviceWorkReportStep4AutoFill = 'technician/service-work-report-step4/';

  static const  serviceWorkReportStep1AutoFill = 'technician/service-work-report-step1/';

  static const  serviceWorkReportTechnicians = 'technician/service-work-report/';

  static const  deleteServiceWorkReport = 'technician/service-work-report/';

  static const  serviceCallReportStep1 = 'technician/service-call-report-step1';

  static const  serviceCallReportStep1AutoFill = 'technician/service-call-report-step1/';

  static const  serviceCallReportStep2 = 'technician/service-call-report-step2';

  static const  serviceCallReportStep2AutoFill = 'technician/service-call-report-step2/';

  static const  serviceCallReportStep3 = 'technician/service-call-report-step2';

  static const  serviceCallReportStep3AutoFill = 'technician/service-call-report-step2/';

  static const  serviceCallReportStep4 = 'technician/service-call-report-step3';

  static const  serviceCallReportStep4AutoFill = 'technician/service-call-report-step3/';

  static const  serviceCallReportStep5 = 'technician/service-call-report-step4';

  static const  serviceCallReportStep5AutoFill = 'technician/service-call-report-step4/';

  static const  serviceCallReportStep6 = 'technician/service-call-report-step5';

  static const  serviceCallReportStep6AutoFill = 'technician/service-call-report-step5/';

  static const  assignedServiceCallTechnicians = 'technician/service-call-report/';

  static const  amcReportStep1 = 'technician/amc-report/step1';

  static const  amcReportStep1AutoFill = 'technician/amc-report/step1/';

  static const  amcReportStep2 = 'technician/amc-report/step2';

  static const  amcReportStep2AutoFill = 'technician/amc-report/step2/';

  static const  amcReportStep3 = 'technician/amc-report/step3';

  static const  amcReportAssignedTechnicians = 'technician/amc-report/';

  static const  amcReportsHistory = 'technician/amc-reports/history';

  static const  amcTechnicians = 'amcs/technicians';

  static const  amcReportDetails = 'technician/amc-report';

  static const  serviceCallsPending = "/api/v1/technician/service-calls/pending";

  static const  createNewCustomer = "dealer/customers/";

  static const  technicianCreateCustomer = "technician/customers";

  static const  commissioningWorkReportStep1AutoFill = "technician/commissioning-report/step1";

  static const  commissioningWorkReportStep2AutoFill = "technician/commissioning-report/step2";

  static const  commissioningWorkReportStep3AutoFill = "technician/commissioning-report/step2";

  static const  commissioningWorkReportStep4AutoFill = "technician/commissioning-report/step3";

  static const  commissioningWorkReportStep5AutoFill = "technician/commissioning-report/step4";

  static const  commissioningWorkReportStep6AutoFill = "technician/commissioning-report/step5";

  static const  commissioningWorkReportStep1 = "technician/commissioning-report/step1";

  static const  commissioningWorkReportStep2 = "technician/commissioning-report/step2";

  static const  commissioningWorkReportStep3 = "technician/commissioning-report/step2";

  static const  commissioningWorkReportStep4 = "technician/commissioning-report/step3";

  static const  commissioningWorkReportStep5 = "technician/commissioning-report/step4";

  static const  commissioningWorkReportStep6 = "technician/commissioning-report/step5";

  static const  commissioningWorkReportTechnicians = "technician/commissioning-report";

  static const  commissioningReportHistory = "technician/commissioning-reports/history";

  static const  commissioningReportDetails = "technician/commissioning-report";

  static const  serviceCallCheckFeedback = "technician/service-call-report";

  static const  serviceCallReport = "technician/service-call-report";

  static const  serviceCallReportHistory = "technician/service-call-reports/history";

  static const  serviceCallDetails = "technician/service-calls/";

  static const  serviceCallComplaintPdf = "technician/service-calls";

  static const notifications = "notifications";

  static const markAllNotificationsRead = "notifications/mark-all-read";

  static const unreadNotificationCount = "notifications/unread-count";
}

