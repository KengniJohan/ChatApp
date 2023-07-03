import 'package:flutter/material.dart';
import 'package:flutter_chat/widgets/widget.dart';

import '../pages/chat_page.dart';

class GroupeTile extends StatefulWidget {
  const GroupeTile(
      {super.key,
      required this.username,
      required this.groupId,
      required this.groupName});

  final String username;
  final String groupId;
  final String groupName;

  @override
  State<GroupeTile> createState() => _GroupeTileState();
}

class _GroupeTileState extends State<GroupeTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              username: widget.username,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            widget.groupName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "join the conversation as ${widget.username}",
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
