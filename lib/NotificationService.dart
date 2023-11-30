
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:math';
import 'dart:io' as io;

class NotificationService  extends ChangeNotifier{


  late String notifyName;
  late String stateClassName;

  NotificationService({required this.notifyName,required this.stateClassName});

  NotificationService.emptyConstructor();

  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  late int version;
  int progress =0;
  int notiId =0;
  String? url;
  String? title;
  bool isIosNotificationShow = false;


  Future<int?> getAndroidVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    throw UnsupportedError("Platform is not Android");
  }

  Map<String, dynamic> result = {
    'title': null,
    'body' : '',
    'filePath': null,
    'error': null,
  };

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {


    final json = jsonEncode(downloadStatus);
    final title = downloadStatus['title'];
    final body = downloadStatus['body'];
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('progress channel', 'progress channel',
        channelDescription: 'progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: 100,
        progress: progress );
    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notiId, // notification id
        title,
        body,
        notificationDetails,
        payload: json);

  }

  Future<String?> getDownloadPath() async {

    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        //directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }



  Future<void> _startDownload(String url,String savePath) async {
    try {
      final response = await _dio.download(
          url,
          savePath,
          onReceiveProgress: (received,total){
            if (total != -1) {


              progress =  ((received / total) * 100).toInt();

              Map map = {};
              map["progress"] = progress;
              Observable.instance.notifyObservers([
                stateClassName,
              ], notifyName : notifyName,map: map);

              if(Platform.isAndroid)
                {


                  if(progress ==1 ){
                    result['title'] = title;
                    result['body'] = "Downloading...";
                    //   _showNotification(result);
                    // notifyListeners();

                  }

                  result['title'] = title;
                  result['body'] = "Downloading...";
                  _showNotification(result);
                  notifyListeners();
                }
              else if(Platform.isIOS)
                {
                  if(!isIosNotificationShow){
                    result['title'] = title;
                    result['body'] = "Downloading...";
                    _showNotification(result);
                    notifyListeners();
                  }

                    isIosNotificationShow = true;

                }
            }
          }
      );

      if(response.statusCode == 200)
      {
        print('comes here1');
        result['title'] = "Downloaded Completed";
        result['body'] = "File downloaded $savePath";
        result['filePath'] = savePath;
        _showNotification(result);
        OpenFile.open(savePath);

      }else
      {
        result['title'] = "Downloaded Error";
        result['body'] = "File Error!!";
      }


    } catch (ex) {
      print('comes ex here');
      print(ex);
      result['error'] = ex.toString();
    } finally {
      result['title'] = "Downloaded Completed";
      result['body'] = "File downloaded $savePath";
      result['filePath'] = savePath;
    }
  }

   download(String title , String url) async {

    this.url = url;
    this.title = title;
    result['title'] = title;
    notiId =  Random().nextInt(10000);

     getAndroidVersion().then((value) {
       version = value!;
       print(value);
     });
    try{
      final dir = await getDownloadPath();
      var permission = await Permission.storage.request();

      String fileName = url.split('/').last;

      if (await File("$dir/$fileName").exists()) {
        print("File exists");
      } else {
        print("File don't exists");
      }
      if(!io.File("$dir/$fileName").existsSync())
        {
          Map map = {};
          map["isAlreadyDownloaded"] = false;
          map["filePath"] = "$dir/$fileName";
          Observable.instance.notifyObservers([
            stateClassName,
          ], notifyName : notifyName,map: map);
          if(Platform.isAndroid)
          {
            if(version<33)
            {
              if (permission.isGranted) {
                final savePath = path.join(dir!, fileName);
                await _startDownload(url,savePath);
              }else{

              }
            }
            else
            {
              final savePath = path.join(dir!, fileName);
              await _startDownload(url,savePath);
            }
          }
          else
          {
            final savePath = path.join(dir!, fileName);
            await _startDownload(url,savePath);
          }
        }
      else
        {
          Map map = {};
          map["isAlreadyDownloaded"] = true;
          map["filePath"] = "$dir/$fileName";
          Observable.instance.notifyObservers([
            stateClassName,
          ], notifyName : notifyName,map: map);
        }


    }catch(ex){
      print(ex);
    }

  }


    showUploadNotification(int progres,int notificationID, Map<String, dynamic> downloadStatus) async {


    final json = jsonEncode(downloadStatus);
    final title = downloadStatus['title'];
    final body = downloadStatus['body'];
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('progress channel', 'progress channel',
        channelDescription: 'progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: 100,
        progress: progres );
    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notificationID, // notification id
        title,
        body,
        notificationDetails,
        payload: json);

  }



}