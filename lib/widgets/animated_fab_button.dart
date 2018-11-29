import 'package:flutter/material.dart';

class AnimatedFabButton extends StatefulWidget {
  final VoidCallback onClick;

  const AnimatedFabButton({Key key, this.onClick}) : super(key: key);

  @override
  _AnimatedFabButtonState createState() => new _AnimatedFabButtonState();
}

class _AnimatedFabButtonState extends State<AnimatedFabButton> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _colorAnimation = new ColorTween(begin: Colors.white, end: Colors.white70).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        return _buildFabCore();
      },
    );
  }

  Widget _buildFabCore() {
    double scaleFactor = 2 * (_animationController.value - 0.5).abs();
    return new FloatingActionButton(
      onPressed: _onFabTap,
      child: new Transform(
        alignment: Alignment.center,
        transform: new Matrix4.identity()..scale(1.0, scaleFactor),
        child: new Icon(
          _animationController.value > 0.5 ? Icons.close : Icons.search,
          color: _animationController.value > 0.5 ? Colors.red[800] : Colors.red,
          size: 28.0,
        ),
      ),
      backgroundColor: _colorAnimation.value,
    );
  }

  open() {
    if (_animationController.isDismissed) {
      _animationController.forward();
      widget.onClick();
    }
  }

  close() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
      widget.onClick();
    }
  }

  _onFabTap() {
    if (_animationController.isDismissed) {
      open();
    } else {
      close();
    }
  }
}
