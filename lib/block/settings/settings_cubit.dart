import '../../../storage/storage.dart';
import 'settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(SettingsState initialState) : super(initialState);

  void changeLanguage(String lang) async {
    // Mevcut durumu güncelle

    final newState = SettingsState(
      language: lang,
      darkMode: state.darkMode,
      userInfo: state.userInfo,
      userLoggedIn: state.userLoggedIn,
    );

    emit(newState);

    // Yeni dil bilgisini depolamaya yaz

    final storage = AppStorage();

    await storage.writeAppSettings(
      darkMode: state.darkMode,
      language: lang,
    );
  }

  void changeDarkMode(bool darkMode) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: darkMode,
      userInfo: state.userInfo,
      userLoggedIn: state.userLoggedIn,
    );

    emit(newState);

    // Yeni tema modunu depolamaya yaz

    final storage = AppStorage();

    await storage.writeAppSettings(
      darkMode: darkMode,
      language: state.language,
    );
  }

  void userLogin(List<String> userInfo) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userInfo: userInfo,
      userLoggedIn: true,
    );

    emit(newState);

    // Kullanıcı bilgilerini depolamaya yaz

    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: true, userInfo: userInfo);
  }

  void userLogout() async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userInfo: [],
      userLoggedIn: false,
    );

    emit(newState);

    // Kullanıcı bilgilerini depolamaya yaz

    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: false, userInfo: []);
  }

  void userUpdate(List<String> userInfo) async {
    final newState = SettingsState(
      language: state.language,
      darkMode: state.darkMode,
      userInfo: userInfo,
      userLoggedIn: true,
    );

    emit(newState);

    // Kullanıcı bilgilerini depolamaya yaz

    final storage = AppStorage();

    await storage.writeUserData(isLoggedIn: true, userInfo: userInfo);
  }
}
