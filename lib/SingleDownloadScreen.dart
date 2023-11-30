import 'package:educateapp/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


// Accessket AKIAXVQSDYNZMHAMUTRN
// SecretAccessKey  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

// pooli d ap-southeast-2:92bfb903-b3c3-479f-a98b-8562e75398cb

// access key  AKIAXVQSDYNZAUCWM545

// secret key  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


class SingleDownloadScreen extends StatefulWidget {
  SingleDownloadScreen({Key? key}) : super(key: key);
  String title = "";
  static const String routeName = '/';

  @override
  State<SingleDownloadScreen> createState() => _SingleDownloadScreenState();
}

class _SingleDownloadScreenState extends State<SingleDownloadScreen>
    with Observer {
  int mp3progress = 0;
  int pdfProgress = 0;
  int jpgProgress = 0;
  var isPlaying = false;
  var showPlaybutton = false;
  var showPDFPlaybutton = false;
  var showJPGPlaybutton = false;
  late String mp3path;
  late String pdfPath;
  late String jpgPath;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        NotificationService(
                                notifyName: 'JPG',
                                stateClassName: '_SingleDownloadScreenState')
                            .download("First title",
                                "https://www.gstatic.com/webp/gallery/1.jpg");
                      },
                      child: const Text("Download JPG")),
                  const SizedBox(width: 30, height: 60,),
                  CircularPercentIndicator(
                    percent: jpgProgress / 100,
                    radius: 22,
                    lineWidth: 7.0,
                  ),
                  const SizedBox(width: 30, height: 60,),
                  Visibility(
                    visible: showJPGPlaybutton,
                    child: Center(
                      child: IconButton(
                          icon : const Icon(
                            Icons.open_in_browser,
                            size: 40.0,
                          ),
                          onPressed: () {
                            setState(() {
                              OpenFile.open(jpgPath);
                            });
                          }),
                    ),
                  ),
                ],
              ),


              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // stateclassname should be the class the name
                        NotificationService(
                                notifyName: "Mp3",
                                stateClassName: '_SingleDownloadScreenState')
                            .download("Second title",
                                "https://www.kozco.com/tech/LRMonoPhase4.mp3");
                      },
                      child: const Text("Download mp3")),
                  const SizedBox(width: 30, height: 60,),
                  CircularPercentIndicator(
                    percent: mp3progress / 100,
                    radius: 22,
                    lineWidth: 7.0,
                  ),
                  const SizedBox(width: 30, height: 60,),
                  Visibility(
                    visible: showPlaybutton,
                    child: Center(
                      child: IconButton(
                          icon: isPlaying
                              ? const Icon(
                                  Icons.pause_circle_outline,
                                  size: 40.0,
                                )
                              : const Icon(Icons.play_circle_outline,
                                  size: 40.0),
                          onPressed: () {
                            setState(() {
                              isPlaying = !isPlaying;
                              OpenFile.open(mp3path);
                            });
                          }),
                    ),
                  ),
                ],
              ),
              Row(
                children: [

                  ElevatedButton(
                      onPressed: () {
                        // stateclassname should be the class the name
                        NotificationService(
                            notifyName: 'PDF',
                            stateClassName: '_SingleDownloadScreenState')
                            .download("Third title",
                            "https://ncert.nic.in/tamanna/pdfs/testBooklet.pdf");

                      },
                      child: const Text("Download PDF")),


                  const SizedBox(width: 30, height: 60,),

                  CircularPercentIndicator(
                    percent: pdfProgress / 100,
                    radius: 22,
                    lineWidth: 7.0,
                  ),
                  const SizedBox(width: 30, height: 60,),
                  Visibility(
                    visible: showPDFPlaybutton,
                    child: Center(
                      child: IconButton(
                           icon : const Icon(
                            Icons.open_in_browser,
                            size: 40.0,
                          ),
                          onPressed: () {
                            setState(() {
                             OpenFile.open(pdfPath);
                            });
                          }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void initState() {
    Observable.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  update(Observable observable, String? notifyName, Map? map) {
    switch (notifyName) {
      case 'Mp3':
        setState(() {
          if (map!['progress'] != null) {
            mp3progress = map!['progress'];
            if (mp3progress == 100) {
              showPlaybutton = true;
            }
          }
          if (map!['isAlreadyDownloaded'] != null) {
            if (map!['isAlreadyDownloaded']) {
              showPlaybutton = true;
              mp3path=map!['filePath'];
              print(map!['filePath']);
              Fluttertoast.showToast(msg: "File already downloaded");
            }
            else{
              mp3path=map!['filePath'];
            }
          }
        });
        break;

      case 'PDF':
        setState(() {
          if (map!['progress'] != null) {
            pdfProgress = map!['progress'];
            if (pdfProgress == 100) {
                showPDFPlaybutton = true;
            }
          }
          if (map!['isAlreadyDownloaded'] != null) {
            if (map!['isAlreadyDownloaded']) {
               pdfPath =map!['filePath'];
              print(map!['filePath']);
               showPDFPlaybutton = true;
              Fluttertoast.showToast(msg: "File already downloaded");
            }
            else{
              pdfPath =map!['filePath'];

            }
          }
        });
        break;

      case 'JPG':
        setState(() {
          if (map!['progress'] != null) {
            jpgProgress = map!['progress'];
            if (jpgProgress == 100) {
               showJPGPlaybutton = true;
            }
          }
          if (map!['isAlreadyDownloaded'] != null) {
            if (map!['isAlreadyDownloaded']) {
               jpgPath = map!['filePath'];
              print(map!['filePath']);
               showJPGPlaybutton = true;
              Fluttertoast.showToast(msg: "File already downloaded");
            }
            else
              {
                jpgPath = map!['filePath'];
              }
          }
        });
        break;
    }
  }
}
