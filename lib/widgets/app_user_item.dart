import 'package:booker/helper/strings.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:flutter/material.dart';

class AppUserItem extends StatefulWidget {

  AppUser appUser;
  VoidCallback onTapItem;
  bool compact;

  AppUserItem({Key? key, required this.appUser, required this.onTapItem, this.compact = false,}) : super(key: key);

  @override
  _AppUserItemState createState() => _AppUserItemState();
}

class _AppUserItemState extends State<AppUserItem> {

  static double profileImageRadius = 60.0;
  static double profileImageBorder = 6.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/no_image.jpeg"), context);
    });
  }

  @override
  Widget build(BuildContext context) {

    print("widget.appUser.urlProfileBgImage = ${widget.appUser.urlProfileBgImage}");

    if(!widget.compact){
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: widget.onTapItem,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    children: [
                      Material(
                        elevation: 0,
                        child: Hero(
                          tag: "${widget.appUser.id}${Strings.USER_URL_PROFILE_BG_IMAGE}",
                          child: SizedBox(
                            height: 150,
                            //width: 120,
                            child: Container(
                                child: widget.appUser.urlProfileBgImage != ""
                                    ? Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.horizontal(left: Radius.circular(8.0), right: Radius.circular(8.0)),
                                          //color: Colors.black12,
                                          color: Colors.white,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(8.0), right: Radius.circular(8.0)),
                                          child: Image.network(
                                            widget.appUser.urlProfileBgImage,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {

                                              return Stack(
                                                children: [
                                                  if(loadingProgress != null)
                                                    Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    ),
                                                  Positioned.fill(
                                                    child: AnimatedOpacity(
                                                        duration: const Duration(milliseconds: 500),
                                                        opacity: loadingProgress == null ? 1 : 0,
                                                        child: child
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.horizontal(left: Radius.circular(8.0), right: Radius.circular(8.0)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage("assets/no_image.jpeg")
                                          )
                                        ),
                                      )
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0.0,
                        bottom: 0.0,
                        child: Hero(
                          tag: "${widget.appUser.id}${Strings.USER_URL_PROFILE_USER_IMAGE}",
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: profileImageBorder,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              //backgroundColor: Colors.grey.shade300,
                              backgroundColor: Colors.white,
                              radius: profileImageRadius,
                              backgroundImage: widget.appUser.urlProfileUserImage != ""
                                  ? NetworkImage(widget.appUser.urlProfileUserImage)
                                  : const AssetImage("assets/no_profile_image.png") as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Hero(
                          tag: "${widget.appUser.id}${Strings.USER_NAME}",
                          child: Material(color: Colors.white, child: Text(widget.appUser.name, style: textStyleMediumBold,))
                      ),
                      trailing: Column(
                        children: [
                          Hero(
                              tag: "${widget.appUser.id}${Strings.USER_USERNAME}",
                              child: Material(color: Colors.white, child: Text(widget.appUser.userName, style: textStyleSmallNormal,))
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Hero(
                            tag: "${widget.appUser.id}${Strings.USER_DESCRIPTION}",
                            child: Material(color: Colors.white, child: Text(widget.appUser.userName, style: textStyleSmallNormal,))
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }


    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onTapItem,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                children: <Widget>[
                  Hero(
                    tag: "${widget.appUser.id}${Strings.USER_URL_PROFILE_BG_IMAGE}",
                    child: SizedBox(
                      height: 80,
                      width: 120,
                      child: Container(
                            child: widget.appUser.urlProfileBgImage != ""
                                ? Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.horizontal(left: Radius.circular(8.0)),
                                      color: Colors.black12,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8.0)),
                                      child: Image.network(
                                        widget.appUser.urlProfileBgImage,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: standartTheme.primaryColor,
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8.0)),
                                    child: Image.asset(
                                      "assets/no_image.jpeg",
                                      fit: BoxFit.fill,
                                    ),
                                  )
                        ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.appUser.name,
                            style: textStyleMediumBold,
                          ),
                          Text(widget.appUser.userName),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
