import 'dart:async';
import 'dart:io';

import 'package:devlog_microblog_client/models/userprefs.dart';
import 'package:devlog_microblog_client/utils/web.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final serverStatusProvider = Provider<ServerStatus>((ref) {
  return ref.watch(serverStatusServiceProvider).state.status;
});

final serverStatusServiceProvider =
    StateProvider<ServerStatusService>((ref) => ServerStatusService());

enum ServerStatus {
  OFFLINE,
  ERROR,
  ONLINE,
}

class ServerStatusService {
  static ServerStatusService _instance;
  Uri _url;

  UserSettingsModel _settings;
  http.Client _http;

  final Duration _interval = Duration(seconds: 15);
  Timer _timer;
  ServerStatus status = ServerStatus.OFFLINE;

  ServerStatusService() {
    _http = http.Client();
  }

  void startWhenReady(Future<UserSettingsModel> future) async {
    _settings = await future;
    start();
  }

  void start() {
    _url = buildServerUrl(_settings.host, '/api/v1/login',
        secure: !_settings.unsecuredTransport);
    _timer = Timer.periodic(_interval, (timer) async {
      await _checkStatus();
    });
  }

  void stop() {
    _timer.cancel();
  }

  Future<void> _checkStatus() async {
    if (!_settings.isConfigured()) {
      return;
    }
    try {
      final resp = await _http.head(_url);
      if (resp.statusCode == 200) {
        status = ServerStatus.ONLINE;
      } else {
        status = ServerStatus.ERROR;
      }
    } on SocketException {
      status = ServerStatus.OFFLINE;
    }
  }

  static ServerStatusService getInstance() {
    if (_instance == null) {
      _instance = ServerStatusService();
    }
    return _instance;
  }
}