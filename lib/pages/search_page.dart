import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/helper/helper_functions.dart';
import 'package:flutter_chat/pages/chat_page.dart';
import 'package:flutter_chat/service/database_service.dart';
import 'package:flutter_chat/widgets/widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String username = "";
  User? user;
  bool isJoined = false;

  @override
  void initState() {
    getCurrentUserIdAndName();
    super.initState();
  }

  getCurrentUserIdAndName() async {
    await HelperFunctions.getUserNameFromSP().then((value) {
      setState(() {
        username = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Search",
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups...",
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : groupList(),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    await DatabaseService()
        .searchByName(searchController.text)
        .then((snapshot) {
      setState(() {
        searchSnapshot = snapshot;
        _isLoading = false;
        hasUserSearched = true;
      });
    });
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                  username,
                  searchSnapshot!.docs[index]["groupId"],
                  searchSnapshot!.docs[index]["groupName"],
                  searchSnapshot!.docs[index]["admin"]);
            },
          )
        : Container();
  }

  Widget groupTile(
      String username, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(username, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, groupName, username);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      username: username));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.red, "Left the group $groupName");
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Join Now",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  joinedOrNot(
      String username, String groupId, String groupName, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUsedJoined(groupName, groupId, username)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }
}
