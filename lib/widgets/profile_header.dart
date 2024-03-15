import 'dart:async';
import 'dart:typed_data';

import 'package:booker/helper/route_generator.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/helper/utils.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:html' as html;

class ProfileHeader extends StatefulWidget {

  AppUser appUser;
  bool allowEdit;
  bool useHero;
  VoidCallback? onReload;

  ProfileHeader({
    Key? key,
    required this.appUser,
    this.onReload,
    this.allowEdit = false,
    this.useHero = true,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {

  late AppUser _appUser;
  late Color appUserColor;

  static double bgImageHeight = 125.0;
  static double profileImageRadius = 60.0;
  static double profileImageBorder = 6.0;
  static double profileImageOverlayProportion = 0.5;

  html.File? _profileImage;
  html.File? _bgImage;
  bool _updatingProfileImage = false;
  bool _updatingBgImage = false;

  _getImage(String source, {required bool isProfileImage}) async {
    //html.File? image = await CommonFunctions.getImage(source);
    html.File? image = await Utils.getImageWeb();
    //print("image = $image");
    print("image=$image");
    print("image.name=${image.name}");
    //if(image?.path != ""){
    if(image.name != ""){
      setState(() {
        if(isProfileImage){
          _profileImage = image;
        }
        else{
          _bgImage = image;
        }

        if ((isProfileImage ? _profileImage : _bgImage) != null) {
          if(isProfileImage) {
            _updatingProfileImage = true;
          } else {
            _updatingBgImage = true;
          }
          _uploadImage(isProfileImage: isProfileImage);
        }
      });
    }
  }

  _uploadImage({required bool isProfileImage}) async {
    print("_uploadImage");
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref();
    Reference file = ref
        .child(Strings.COLLECTION_USERS_PUBLIC)
        .child("${_appUser.id}-${isProfileImage ? Strings.USER_URL_PROFILE_USER_IMAGE : Strings.USER_URL_PROFILE_BG_IMAGE}");

    print("file=$file");

    html.File? usedImage = isProfileImage ? _profileImage : _bgImage;

    //UploadTask task = file.putFile(_eventImage!);
    // Usar FileReader para Flutter Web
    final reader = html.FileReader();
    final completer = Completer<List<int>>();
    print("usedImage=$usedImage");
    reader.readAsArrayBuffer(usedImage as html.File);
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as List<int>);
    });
    final loaded = await completer.future;
    final data = Uint8List.fromList(loaded);
    UploadTask task = file.putData(data);
    task.then((snapshot) {
      _getImageUrl(snapshot, isProfileImage: isProfileImage);
    });
  }

  _getImageUrl(TaskSnapshot snapshot, {required bool isProfileImage}) async {
    print("_getImageUrl");
    String url = await snapshot.ref.getDownloadURL();
    print(url);
    _updateFirestoreUrlImage(url, isProfileImage: isProfileImage);
    setState(() {
      if(isProfileImage) {
        _appUser.urlProfileUserImage = url;
        _updatingProfileImage = false;
      } else {
        _appUser.urlProfileBgImage = url;
        _updatingBgImage = false;
      }
    });
  }

  _updateFirestoreUrlImage(String url, {required bool isProfileImage}) {
    Map<String, dynamic> dataToUpdate = {isProfileImage ? Strings.USER_URL_PROFILE_USER_IMAGE : Strings.USER_URL_PROFILE_BG_IMAGE: url};
    FirebaseFirestore.instance.collection(Strings.COLLECTION_USERS).doc(_appUser.id).update(dataToUpdate);
  }

  @override
  void initState() {
    _appUser = widget.appUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    appUserColor = _appUser.getUserColorResolved();

    return Container(
      color: Colors.white,
      //height: bgImageHeight + (1 - profileImageOverlayProportion) * 2 * (profileImageRadius + profileImageBorder) + (widget.allowEdit ? 36 : 0),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                child: Hero(
                  tag: widget.useHero ? "${widget.appUser.id}${Strings.USER_URL_PROFILE_BG_IMAGE}" : UniqueKey(),
                  child: Container(
                    width: double.infinity,
                    height: bgImageHeight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _appUser.urlProfileBgImage != ""
                            ? NetworkImage(_appUser.urlProfileBgImage)
                            : const AssetImage("assets/no_image.jpeg") as ImageProvider,
                      )
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if(_updatingBgImage)
                          Container(
                            color: Colors.white,
                            child: LoadingData(),
                          ),
                        if(widget.allowEdit)
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black45,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        if(widget.allowEdit)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: TextButton(
                              onPressed: (){
                                _getImage(Strings.GALLERY, isProfileImage: false);
                              },
                              child: Text(AppLocalizations.of(context)!.profile_config_change_picture, style: const TextStyle(color: Colors.white),),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 2*profileImageRadius + 8),
                child: ListTile(
                  title: Hero(
                    tag: widget.useHero ? "${widget.appUser.id}${Strings.USER_NAME}" : UniqueKey(),
                    child: Material(color: Colors.white, child: Text(_appUser.name, style: textStyleMediumBold, overflow: TextOverflow.ellipsis,))
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Hero(
                            tag: widget.useHero ? "${widget.appUser.id}${Strings.USER_USERNAME}" : UniqueKey(),
                            child: Material(color: Colors.white, child: Text(_appUser.userName, style: textStyleSmallNormal, overflow: TextOverflow.ellipsis,))
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Hero(
                            tag: widget.useHero ? "${widget.appUser.id}${Strings.USER_DESCRIPTION}" : UniqueKey(),
                            child: Material(color: Colors.white, child: Text(_appUser.description, style: textStyleSmallNormal, overflow: TextOverflow.ellipsis, maxLines: 5,))
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if(widget.allowEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                      onPressed: () async {
                        await Navigator.pushNamed(context, RouteGenerator.EDIT_PROFILE_SERVICE_PROVIDER, arguments: widget.appUser)
                            .then((value){
                              setState(() {});
                              if(widget.onReload != null) widget.onReload!();
                            });
                      },
                      child: Text("Editar", style: TextStyle(color: appUserColor),)
                  ),
                )
            ],
          ),
          Positioned(
            left: 0.0,
            top: bgImageHeight - profileImageOverlayProportion * 2 * (profileImageRadius + profileImageBorder),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: widget.useHero ? "${widget.appUser.id}${Strings.USER_URL_PROFILE_USER_IMAGE}" : UniqueKey(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: profileImageBorder,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      radius: profileImageRadius,
                      backgroundImage: _appUser.urlProfileUserImage != ""
                          ? NetworkImage(_appUser.urlProfileUserImage)
                          : const AssetImage("assets/no_profile_image.png") as ImageProvider,
                    ),
                  ),
                ),
                if(_updatingProfileImage)
                  Container(
                    width: 2 * (profileImageRadius),
                    height: 2 * (profileImageRadius),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                    ),
                    child: LoadingData(),
                  ),
                if(widget.allowEdit)
                  Container(
                    width: 2 * (profileImageRadius),
                    height: 2 * (profileImageRadius),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                        ],
                      )
                    ),
                  ),
                if(widget.allowEdit)
                  Positioned(
                    bottom: 8,
                    child: TextButton(
                      onPressed: (){
                        _getImage(Strings.GALLERY, isProfileImage: true);
                      },
                      child: Text(AppLocalizations.of(context)!.profile_config_change_picture, style: const TextStyle(color: Colors.white,),),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
