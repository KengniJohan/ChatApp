import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // Saving the userdata
  Future savingUserData(String fullname, String email) async {
    return await userCollection.doc(uid).set({
      "fullname": fullname,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }

  // Getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();

    return snapshot;
  }

  // Get user groups
  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // Creating a group
  Future createGroup(String username, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$username",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // Update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$username"]),
      "groupId": groupDocumentReference.id
    });

    // Update groupId in users collection
    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // Getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupeId) async {
    DocumentReference dr = groupCollection.doc(groupeId);
    DocumentSnapshot documentSnapshot = await dr.get();
    return documentSnapshot["admin"];
  }

  // Get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // Search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function => bool
  Future<bool> isUsedJoined(
      String groupName, String groupId, String username) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot["groups"];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // Toggling the group join/exit
  Future toggleGroupJoin(String groupId, String groupName, String username) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot["groups"];

    // if user has our groups => then remove then or also in other part re join
    if(groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups" : FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members" : FieldValue.arrayRemove(["${uid}_$username"])
      });
    } else {
      await userDocumentReference.update({
        "groups" : FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members" : FieldValue.arrayUnion(["${uid}_$username"])
      });
    }

  }

  // Send message
  sendMessage(String groupId, Map<String, dynamic> chatMessagesData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessagesData);
    groupCollection.doc(groupId).update({
      "recentMessage" : chatMessagesData['message'],
      "recentMessageSender" : chatMessagesData['sender'],
      "recentMessageTime" : chatMessagesData['time'].toString()
    });
  }
}
