

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:educateapp/AmplifyUpload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
class UploadScreen extends StatefulWidget {
  const UploadScreen(
      {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/';

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context)
  {
    const region = "ap-south-1";


     return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Upload Screen'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                ElevatedButton(
                  child:
                  const Text('Select File'),
                  onPressed: () {

                    // signUp();

                    //signIn();
                  //  listAllWithGuestAccessLevel();
                    downloadToLocalFile("Unknown.jpeg");

                    // just call this function

                  //   AmplifyUpload().uploadImage();
                  },
                ),


              ],
            ),
          ),
        ),
      );
}



  Future<void> listAllWithGuestAccessLevel() async {
    try {
      final result = await Amplify.Storage.list(
        options: const StorageListOptions(
          accessLevel: StorageAccessLevel.guest,
          pluginOptions: S3ListPluginOptions.listAll(),
        ),
      ).result;

      safePrint('Listed items: ${result.items}');
    } on StorageException catch (e) {
      safePrint('Error listing files: ${e.message}');
      rethrow;
    }
  }
  Future<void> signUp() async{

    try {
      Map<CognitoUserAttributeKey,String> attributes  ={
        CognitoUserAttributeKey.email : "vs1@gmail.com",
        CognitoUserAttributeKey.phoneNumber :""
      };
    SignUpResult res = await Amplify.Auth.signUp(
        username: "testuser2",
        password: "srbh@123",
    options:CognitoSignUpOptions(userAttributes: attributes) );

    print(res.toJson());

    } on AuthException catch (e) {
  print(e);
  throw (e);
  } catch (error) {
  print(error);
  throw (error);
}

  }

  Future<void> signInConfirm() async{

    try {
    SignUpResult res = await Amplify.Auth.confirmSignUp(
        username: "testuser1",
        confirmationCode: "srbh@123",);

    print(res);
  //  downloadToLocalFile("upload");
    } on AuthException catch (e) {
  print(e);
  throw (e);
  } catch (error) {
  print(error);
  throw (error);
}

  }
  Future<void> signIn() async{

    try {
      await Amplify.Auth.signOut();
    SignInResult res = await Amplify.Auth.signIn(
        username: "testuser1",
        password: "srbh@123",);

    print(res);
     fetchCognitoAuthSession();
    //listAlbum();

    } on AuthException catch (e) {
  print(e);
  throw (e);
  } catch (error) {
  print(error);
  throw (error);
}

  }

  Future<void> fetchCognitoAuthSession() async {
    try {
      final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final result = await cognitoPlugin.fetchAuthSession();
      final identityId = result.identityIdResult.value;
      //downloadToLocalFile("dummyimg.jpeg",identityId);
      safePrint("Current user's identity ID: $identityId");
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');
    }
  }
  Future<void> downloadToLocalFile(String key) async {

    final res = Amplify.Storage.getUrl(key: key);
    res.result.then((value) => debugPrint(value.url.query));
    final documentsDir = await getApplicationDocumentsDirectory();
    final filepath = documentsDir.path + 'Unknown.jpeg';
    const options = StorageDownloadFileOptions(
      // specify that the file has a protected access level
      accessLevel: StorageAccessLevel.guest,
      // specify the identity ID of the user who uploaded this file
    );
    try {

      final result = await Amplify.Storage.downloadFile(
        key: key,
        localFile: AWSFile.fromPath(filepath),
        onProgress: (progress) {
          safePrint('Fraction completed: ${progress.fractionCompleted}');
        },options: options
      ).result;

      safePrint('Downloaded file is located at: ${result.downloadedItem}');
    } on StorageException catch (e) {
      safePrint(e.toJson());
    }
  }

  @override
  void dispose() {
    super.dispose();
    // also dispose the upload call
    AmplifyUpload().dispose();

  }
}
