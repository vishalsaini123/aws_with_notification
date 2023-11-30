import 'dart:async';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:simple_s3/simple_s3.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class AmplifyUpload
{


  int notiID=0;
  final SimpleS3 _simpleS3 = SimpleS3();
  late final StreamSubscription<dynamic> _subscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Map<String, dynamic> result = {
    'title': null,
    'body' : '',
    'filePath': null,
    'error': null,
  };

  AmplifyUpload(){

    final Stream<dynamic> stream = _simpleS3.getUploadPercentage;
    _subscription = stream.listen((data) {

     /* result['title'] = "Educate";
      result['body'] = "Uploading file...";
      showUploadNotification(data,notiID,result);
      if(data==100)
      {

        result['body'] = "Uploaded Successfully...";
        showUploadNotification(data,notiID,result);

      }*/

    });

   /* StreamController<dynamic>(
        stream: _simpleS3.getUploadPercentage,
        builder: (context, snapshot) {

          if(snapshot.hasData)
          {
            print(snapshot.data);
            result['title'] = "Educate";
            result['body'] = "Uploading file...";
            NotificationService.emptyConstructor().showUploadNotification(snapshot.data,notiID,result);
            if(snapshot.data==100)
            {
              result['body'] = "Uploaded Successfully...";
              NotificationService.emptyConstructor().showUploadNotification(snapshot.data,notiID,result);

            }
          }
           return Container();

        });*/
  }

  void dispose(){
    _subscription.cancel();
  }
/*
  void upload() async{

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      _upload(file,result.files.single.name).then((value) => print(value!));
      print(file.path);
    } else {
      // User canceled the picker
    }
  }
*/


  Future<void> uploadImage() async {

    notiID++;
    Map<String, dynamic> mapdata = {
      'title': null,
      'body' : '',
      'filePath': null,
      'error': null,
    };
    // Select a file from the device
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: false,
      // Ensure to get file stream for better performance
      withReadStream: true,
      allowedExtensions: ['jpg', 'png', 'gif', 'mp3', 'pdf'],
    );

    if (result == null) {
      safePrint('No file selected');
      return;
    }

    // Upload file with its filename as the key
    final platformFile = result.files.single;
    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          platformFile.readStream!,
          size: platformFile.size,
        ),
        key: platformFile.name,
        onProgress: (progress) {
          mapdata['title'] = "Educate";
          mapdata['body'] = "Uploading file...";
          int bytetransferred = progress.transferredBytes;
          int totalbyteexpected = progress.totalBytes;
          int percentage = ((bytetransferred / totalbyteexpected) * 100).toInt();
          safePrint(percentage);
          showUploadNotification(percentage,notiID,mapdata);
          if(percentage==100)
          {

            mapdata['body'] = "Uploaded Successfully...";
            showUploadNotification(percentage,notiID,mapdata);

          }

        },
      ).result;
      safePrint('Successfully uploaded file: ${result.uploadedItem.key}');
    } on StorageException catch (e) {
      safePrint('Error uploading file: $e');
      rethrow;
    }
  }
 /* Future<String?> _upload(PlatformFile? platformFile,String name) async {
    String? result;
       notiID++;
    if (result == null) {

      try {
        final result = await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromStream(
            platformFile.readStream,
            size: platformFile.size,
          ),
          key: platformFile.name,
          onProgress: (progress) {
            safePrint('Fraction completed: ${progress.fractionCompleted}');
          },
        ).result;
        safePrint('Successfully uploaded file: ${result.uploadedItem.key}');
      } on StorageException catch (e) {
        safePrint('Error uploading file: $e');
        rethrow;
      }


        *//*result = await _simpleS3.uploadFile(
          file!,
          "image-pdf-picker",
          "ap-south-1:72356ffe-b886-4563-a617-be64d259eb2f",
          AWSRegions.apSouth1,
          debugLog: true,
          s3FolderPath: "upload",
          accessControl: S3AccessControl.bucketOwnerFullControl,
        );*//*


    }
    return result;


  }*/

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