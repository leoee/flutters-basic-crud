import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basics/src/home/home-bloc.dart';

class BodyWidget {
  StreamBuilder<dynamic> getBody(HomeBloc homeBloc, var _currentSnapshots) {
    return StreamBuilder(
      stream: _currentSnapshots,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return LinearProgressIndicator();
            break;
          default:
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: EdgeInsets.all(5),
              itemBuilder: (BuildContext ctxt, int index) {
                final item = snapshot.data.documents[index];
                final itemID = snapshot.data.documents[index].documentID;

                return Dismissible(
                  direction: homeBloc.getValidDismissable(item),
                  key: Key(itemID),
                  background: Container(
                    color: Colors.green.withOpacity(0.2),
                  ),
                  onDismissed: (direction) {
                    String nextState = homeBloc.getNextState(item, direction);
                    if (nextState.isNotEmpty) {
                      homeBloc.homeService.update(itemID, "status", nextState);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "${item.data['title']}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(Icons.info),
                            onPressed: () {},
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }
}
