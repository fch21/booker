import 'package:booker/helper/strings.dart';
import 'package:booker/main.dart';
import 'package:booker/models/app_user.dart';
import 'package:booker/widgets/loading_data.dart';
import 'package:flutter/material.dart';

class ServiceProviderItem extends StatefulWidget {

  AppUser appUser;
  VoidCallback onTapItem;
  bool compact;

  ServiceProviderItem({Key? key, required this.appUser, required this.onTapItem, this.compact = false,}) : super(key: key);

  @override
  _ServiceProviderItemState createState() => _ServiceProviderItemState();
}

class _ServiceProviderItemState extends State<ServiceProviderItem> {

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
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8.0), right: Radius.circular(8.0)),
                                color: Colors.grey.shade100,
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8.0), right: Radius.circular(8.0)),
                                child: widget.appUser.urlProfileBgImage == ""
                                  ? Image.asset("assets/no_image.jpeg", fit: BoxFit.cover)
                                  : Image.network(
                                      widget.appUser.urlProfileBgImage,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        return Stack(
                                          children: [
                                            if(loadingProgress != null) Center(child: LoadingData()),
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
                            child: ClipOval(
                              child: Container(
                                width: 2 * profileImageRadius,
                                height: 2 * profileImageRadius,
                                color: Colors.grey.shade100,
                                child: widget.appUser.urlProfileUserImage == ""
                                    ? Image.asset(
                                        "assets/no_profile_image.png",
                                        width: 2 * profileImageRadius,
                                        height: 2 * profileImageRadius,
                                      )
                                    : Image.network(
                                        widget.appUser.urlProfileUserImage,
                                        width: 2 * profileImageRadius,
                                        height: 2 * profileImageRadius,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                          return Stack(
                                            children: [
                                              if(loadingProgress != null) Center(child: LoadingData()),
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
                            child: Material(color: Colors.white, child: Text(widget.appUser.description, style: textStyleSmallNormal, maxLines: 2, overflow: TextOverflow.ellipsis,))
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


    // not ready to use
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
