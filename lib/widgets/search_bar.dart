import 'dart:async';
import 'package:flutter/material.dart';

typedef Future<List<T>> ResultsCallback<T>(String pattern);
typedef Widget ItemBuilder<T>(BuildContext context, T objectData);
typedef void ResultSelectionCallback<T>(T suggestion);

class SearchBar<T> extends StatefulWidget {
  final String searchHintText;
  final ResultsCallback resultsCallback;
  final ItemBuilder itemBuilder;
  final ResultSelectionCallback resultSelectionCallback;

  SearchBar(
      {this.searchHintText = 'Search ....',
      @required this.resultsCallback,
      @required this.itemBuilder,
      @required this.resultSelectionCallback});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState<T> extends State<SearchBar<T>> {
  List<T> _results = [];
  TextEditingController _textEditingController = new TextEditingController();
  VoidCallback _textEditingControllerListener;
  final FocusNode _searchFocusNode = FocusNode();

  ResultSelectionCallback<T> _resultSelectionCallback;

  @override
  void initState() {
    super.initState();
    _initTextEditingController();
    this._resultSelectionCallback = (T result) {
      setState(() {
        _textEditingController.text = '';
        _searchFocusNode.unfocus();
        widget.resultSelectionCallback(result);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: new Column(
        children: <Widget>[
          _initTextFieldContainer(),
          SizedBox(
            height: 5.0,
          ),
          _initResultsListContainer(context)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(this._textEditingControllerListener);
    super.dispose();
  }

  void _initTextEditingController() {
    _initTextEditingControllerListener();
    _textEditingController.addListener(this._textEditingControllerListener);
  }

  void _initTextEditingControllerListener() {
    this._textEditingControllerListener = () {
      setState(() {
        if (_textEditingController.text.length >= 1) {
          widget.resultsCallback(_textEditingController.text).then((results) {
            _results = results;
          });
        } else {
          _results = [];
        }
      });
    };
  }

  //Create a SearchView
  Widget _initTextFieldContainer() {
    return new Container(
      height: 42.0,
      decoration: BoxDecoration(
          border: new Border.all(
            width: .5,
            color: Colors.grey[300],
          ),
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: new Offset(-1.0, 5.0),
              blurRadius: 5.0,
            )
          ],
          color: Colors.white),
      child: new TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon:
                Icon(_textEditingController.text.isNotEmpty || _searchFocusNode.hasFocus ? Icons.clear : Icons.search),
            color: Colors.grey[600],
            onPressed: () {
              if (_textEditingController.text.isNotEmpty || _searchFocusNode.hasFocus) {
                _textEditingController.text = '';
                _searchFocusNode.unfocus();
              }
            },
          ),
          // suffixIcon: Icon(
          //   Icons.mic,
          //   color: Colors.grey[600],
          // ),
          hintText: widget.searchHintText,
          hintStyle: new TextStyle(color: Colors.grey[300]),
          border: InputBorder.none,
        ),
        textAlign: TextAlign.left,
        focusNode: _searchFocusNode,
      ),
    );
  }

  Widget _initResultsListContainer(BuildContext context) {
    if (_results.length > 0) {
      return new Expanded(
        child: new ListView(
          padding: EdgeInsets.zero,
          primary: false,
          children: _results.map((T result) {
            return InkWell(
              child: widget.itemBuilder(context, result),
              onTap: () {
                _resultSelectionCallback(result);
              },
            );
          }).toList(),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }
}
