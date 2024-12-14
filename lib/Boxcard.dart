import 'package:flutter/material.dart';

class Boxcard extends StatefulWidget {
  final Widget boxcontent;
  final String hiddenContent;

  const Boxcard({super.key, required this.boxcontent, required this.hiddenContent});

  @override
  State<Boxcard> createState() => _BoxcardState();
}


class _BoxcardState extends State<Boxcard> {
  bool isContentVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 5.0, 30.0, 5.0 ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              isContentVisible ? Text(widget.hiddenContent) : widget.boxcontent,
              GestureDetector(
                onLongPress: () {
                  setState(() {
                    isContentVisible = true;
                  });
                },
                onLongPressUp: () {
                  setState(() {
                    isContentVisible = false;
                  });
                },
                child: Icon(Icons.visibility_outlined),
              )
            ],
          ),
        ),
        height: 90,
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white60.withOpacity(0.5),
        ),
      ),
    );
  }
}
