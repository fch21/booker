import 'package:booker/helper/stripe_functions.dart';
import 'package:booker/models/subscription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:booker/helper/strings.dart';
import 'package:booker/models/app_user.dart';

class UserFirebase {
  static User? getCurrentUser() {
    print("getCurrentUser");
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
  }

  static Future<AppUser> getCurrentUserData() async {
    User? firebaseUser = getCurrentUser();
    String? userId = firebaseUser?.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot snapshot = await db.collection(Strings.COLLECTION_USERS).doc(userId).get();

    AppUser user = AppUser.fromDocumentSnapshot(snapshot);
    if(user.isServiceProvider){
      await user.initUserSubscription();
    }

    return user;
  }

  static Future<String> getUserImageUrl() async {
    User? firebaseUser = getCurrentUser();
    String? userId = firebaseUser?.uid;

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref();
    Reference imageRef = ref.child(Strings.COLLECTION_USERS).child("${userId ?? ""}.jpg");

    return await imageRef.getDownloadURL();
  }
}
