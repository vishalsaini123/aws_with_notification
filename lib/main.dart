import 'dart:async';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:educateapp/NotificationInitialisation.dart';
import 'package:educateapp/SingleDownloadScreen.dart';
import 'package:educateapp/UploadScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'amplifyconfiguration.dart';
Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    await Amplify.addPlugins([auth, storage]);

    // call Amplify.configure to use the initialized categories in your app
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  String initialRoute = HomePage.routeName;
  NotificationInitialisation().initialisePlatformNotification();
  runApp(
    MaterialApp(
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        HomePage.routeName: (_) => const HomePage(),
      },
    ),
  );
}

class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage(
   {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
   NotificationInitialisation().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: const Text('Splash Screen'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                  PaddedElevatedButton(
                    buttonText:
                    'Download Screen',
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context) => SingleDownloadScreen(),
                      ));
                    },
                  ),PaddedElevatedButton(
                    buttonText:
                    'Upload Screen',
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (BuildContext context) => const UploadScreen(),
                      ));
                    },
                  ),
                 /* PaddedElevatedButton(
                    buttonText: 'Request permission (API 33+)',
                    onPressed: () => _requestPermissions(),
                  ),

                  PaddedElevatedButton(
                    buttonText:
                    'Show progress notification - updates every second',
                    onPressed: () async {
                      await _showProgressNotification();
                    },
                  ),*/



              ],
            ),
          ),
        ),
      );


}



