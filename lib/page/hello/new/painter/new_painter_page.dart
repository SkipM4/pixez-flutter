import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:pixez/component/painer_card.dart';
import 'package:pixez/models/user_preview.dart';
import 'package:pixez/page/hello/new/painter/bloc/bloc.dart';

class NewPainterPage extends StatefulWidget {
  final int id;

  final String restrict;

  const NewPainterPage({Key key, this.id, this.restrict}) : super(key: key);

  @override
  _NewPainterPageState createState() => _NewPainterPageState();
}

class _NewPainterPageState extends State<NewPainterPage> {
  Completer<void> _refreshCompleter, _loadCompleter;
  EasyRefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _loadCompleter = Completer<void>();
    _refreshController = EasyRefreshController();
    BlocProvider.of<NewPainterBloc>(context)
        .add(FetchPainterEvent(widget.id, widget.restrict));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewPainterBloc, NewPainterState>(
      listener: (context, state) {
        if (state is DataState) {
          _loadCompleter?.complete();
          _loadCompleter = Completer();
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
        if (state is LoadEndState) {
          _loadCompleter?.complete();
          _loadCompleter = Completer();
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
          _refreshController.finishLoad(
            success: true,
            noMore: true,
          );
        }
      },
      child: BlocBuilder<NewPainterBloc, NewPainterState>(
        condition: (pre, now) {
          return now is DataState;
        },
        builder: (context, state) {
          if (state is DataState) {
            return EasyRefresh(
              controller: _refreshController,
              onRefresh: () {
                BlocProvider.of<NewPainterBloc>(context)
                    .add(FetchPainterEvent(widget.id, widget.restrict));
                return _refreshCompleter.future;
              },
              onLoad: () {
                BlocProvider.of<NewPainterBloc>(context)
                    .add(LoadMoreEvent(state.nextUrl, state.users));
                return _loadCompleter.future;
              },
              child: ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (BuildContext context, int index) {
                  UserPreviews user = state.users[index];
                  return PainterCard(
                    user: user,
                  );
                },
              ),
            );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }
}
