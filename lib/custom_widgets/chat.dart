import 'package:app/constants.dart';
import 'package:app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  MessageListState createState() => MessageListState();
}

class MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
    final userDao = Provider.of<UserDao>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kPrimaryColor),
              ),
            ),
            child: const Text(
              "Pôle sport",
              style: TextStyle(
                fontSize: 20,
                color: kPrimaryColor,
              ),
            ),
          ),
          _getMessageList(userDao),
        ],
      ),
    );
  }

  Widget _getMessageList(UserDao messageDao) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: messageDao.getMessageStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildList(context, snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20.0),
      // 2
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final message = Message.fromSnapshot(snapshot);
    return MessageWidget(
      message.text,
      message.date,
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String message;
  final DateTime date;

  const MessageWidget(this.message, this.date, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, top: 5, right: 1, bottom: 2),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.grey[350]!,
                  blurRadius: 2.0,
                  offset: const Offset(0, 1.0))
            ], borderRadius: BorderRadius.circular(50.0), color: Colors.white),
            child: MaterialButton(
              disabledTextColor: Colors.black87,
              padding: const EdgeInsets.only(left: 18),
              onPressed: null,
              child: Wrap(
                children: <Widget>[
                  Row(
                    children: [
                      Text(message),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  DateFormat('yyyy-MM-dd, kk:mma').format(date).toString(),
                  style: const TextStyle(color: Colors.grey),
                )),
          ),
        ],
      ),
    );
  }
}
