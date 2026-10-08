import 'package:flutter_riverpod/flutter_riverpod.dart';

// Yeh provider Bottom Navigation Bar ka current tab (index) yaad rakhta hai
final dashboardControllerProvider = StateNotifierProvider<DashboardController, int>((ref) {
  return DashboardController();
});

class DashboardController extends StateNotifier<int> {
  // App open hone pe default index 1 hoga (yani 'Today' screen sabse pehle khulegi)
  DashboardController() : super(1);

  void setIndex(int index) {
    state = index;
  }
}