import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toopdbq/card/FbCard.dart';
import 'package:toopdbq/main.dart';

import '../common/user.dart';
import 'Card.dart';
import 'VwCardFull.dart';

class StackedCardViewItem extends StatefulWidget {
  final bool isDraggable;
  StackedCard? card;
  final Function(double)? onSlideUpdate;
  final Function(SlideDirection)? onSlideComplete;
  final double scale;

  StackedCardViewItem({Key? key,
    this.isDraggable: true,
    required this.card,
    required this.onSlideUpdate,
    required this.onSlideComplete,
    this.scale: 1.0,
  }) : super(key: key);

  @override
  _StackedCardViewItemState createState() => _StackedCardViewItemState();
  // {
  //   if(card == null ){
  //     return
  //   }else{
  //     return _StackedCardViewItemStateTrue();
  //   }
  // }
}

// class _StackedCardViewItemState extends State<StackedCardViewItem>{
//   @override
//   Widget build(BuildContext context) {
//     return Center();
//   }
// }

class _StackedCardViewItemState extends State<StackedCardViewItem> with TickerProviderStateMixin{
  GlobalKey itemKey = GlobalKey(debugLabel: 'item_key');
  /// カード（以下、コンテナと呼びます）の現在位置を保持するための変数
  Offset containerOffset = const Offset(0.0, 0.0);
  Offset? dragStartPosition;
  Offset? dragCurrentPosition;
  Offset? slideBackStartPosition;

  late AnimationController slideBackAnimation;
  late AnimationController slideOutAnimation;
  Tween<Offset>? slideOutTween;
  SlideDirection? slideOutDirection;
  double colorLike = 0;
  double colorNope = 0;

  @override
  void initState() {
    super.initState();
    slideBackAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..addListener(() => setState(() {
        containerOffset = Offset.lerp(
            slideBackStartPosition,
            const Offset(0.0, 0.0),
            Curves.elasticOut.transform(slideBackAnimation.value)
        )!;
        if (widget.onSlideUpdate != null) {
          widget.onSlideUpdate!(containerOffset.distance);
        }
      }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStartPosition = null;
            dragCurrentPosition = null;
            slideBackStartPosition = null;
          });
        }
      });
    slideOutAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )
      ..addListener(() => setState(() {
        if(slideOutTween != null) {
          containerOffset = slideOutTween!.evaluate(slideOutAnimation);
        }
        if (widget.onSlideUpdate != null) {
          widget.onSlideUpdate!(containerOffset.distance);
        }
      }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if(slideOutDirection == null)return;
          setState(() {
            dragStartPosition = null;
            dragCurrentPosition = null;
            slideOutTween = null;
            if(slideOutDirection == SlideDirection.Right )_onLike();
            if(widget.onSlideComplete != null) {
              widget.onSlideComplete!(slideOutDirection!);
            }
          });
        }
      });
    if (widget.isDraggable) {
      //widget.card.addListener(_slideFromExternal);
    }
  }

  void _slideFromExternal(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.Left:
        _slideLeft();
        break;
      case SlideDirection.Right:
        _onLike();
        _slideRight();
        break;
      case SlideDirection.Up:
        _slideUp();
        break;
    }
  }

  void _onLike(){
    if(UserMt.mid != null && UserMt.tokenMy != null) {
      FbCard.like(widget.card!.uid);
    }
  }
  /// 左にスワイプされた際の処理です
  void _slideLeft() {
    if (slideOutAnimation.isAnimating) {
      return;
    }

    setState((){
      final screenSize = MediaQuery.of(context).size;
      dragStartPosition = _randomDragStartPosition();
      slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(screenSize.width * -2, 0.0));
      slideOutAnimation.forward(from: 0.0);
      slideOutDirection = SlideDirection.Left;
    });

  }

  /// 右にスワイプされた際の処理です
  void _slideRight() {
    if (slideOutAnimation.isAnimating) {
      return;
    }
    setState((){
      final screenSize = MediaQuery.of(context).size;
      dragStartPosition = _randomDragStartPosition();
      slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(screenSize.width * 2, 0.0));
      slideOutAnimation.forward(from: 0.0);
      slideOutDirection = SlideDirection.Right;
    });
  }

  /// 上にスワイプされた際の処理です
  void _slideUp() {
    if (slideOutAnimation.isAnimating) {
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    setState((){
      dragStartPosition = _randomDragStartPosition();
      slideOutTween = Tween(begin: const Offset(0.0, 0.0), end: Offset(0.0, screenSize.height * -2));
      slideOutAnimation.forward(from: 0.0);
      slideOutDirection = SlideDirection.Up;
    });

  }

  Offset _randomDragStartPosition() {
    final screenSize = MediaQuery.of(context).size;

    final itemContext = itemKey.currentContext;
    final itemTopLeft = (itemContext?.findRenderObject() as RenderBox).localToGlobal(const Offset(0.0, 0.0));
    final dragStartY = screenSize.height * (Random().nextDouble() < 0.5 ? 0.25 : 0.75) + itemTopLeft.dy;
    final dragStartX = screenSize.width / 2 + itemTopLeft.dx;

    return Offset(dragStartX, dragStartY);
  }

  @override
  void dispose() {
    slideBackAnimation.dispose();
    slideOutAnimation.dispose();

    //widget.card.removeListener(_slideFromExternal);

    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isDraggable) {
      return;
    }
    dragStartPosition = details.globalPosition;

    if (slideBackAnimation.isAnimating) {
      slideBackAnimation.stop();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isDraggable) {
      return;
    }

    setState(() {
      /// details.globalPosition はデバイス上の絶対位置です
      dragCurrentPosition = details.globalPosition;
      /// 現在のドラッグ位置からドラッグ開始位置を減算して、コンテナの移動量を計算します
      if(dragStartPosition != null && dragCurrentPosition != null) {
        containerOffset = (dragCurrentPosition! - dragStartPosition!);
        double opacity = containerOffset.distance > 200 ? 1 :
        1 - containerOffset.distance/200;
        if(containerOffset.dx > 0){
          colorLike = 1 - opacity;
          colorNope = 0;
        }else{
          colorLike = 0;
          colorNope = 1 - opacity;
        }
      }

      /// リスナーが設定されている場合、移動した距離（対角距離）を渡して実行します
      if (widget.onSlideUpdate != null) {
        widget.onSlideUpdate!(containerOffset.distance);
      }
    });
  }

  /// ドラッグの終了処理です
  /// コンテナのドラッグが解除された際に実行します
  void _onPanEnd(DragEndDetails details) {
    if (!widget.isDraggable && context.size == null) {
      return;
    }
    /// ドラッグされた方向をベクトル成分(x, y)として計算します
    /// Offset.distance は(0, 0)から現在位置の対角距離です
    /// Offset(xの移動量, yの移動量) / 移動した距離（対角距離）、なので
    /// 右下ベクトルの場合、xy共に正    (e.g. (0.5, 0.5)
    /// 右上ベクトルの場合、xが正、yが負 (e.g. (0.5, -0.5)
    /// 左下ベクトルの場合、xが負、yが正 (e.g. (-0.5, 0.5)
    /// 左上ベクトルの場合、xy共に負    (e.g. (-0.5, -0.5)
    final dragVector = containerOffset / containerOffset.distance;

    /// コンテナサイズと移動量を用いてどのエリアにドラッグされたかを判定します
    /// xの移動量(cardOffset.dx)がコンテナサイズの45%を超えたら右、-45%を下回ったら左
    /// yの移動量(cardOffset.dy)がコンテナサイズの-40%を下回ったら上
    final isInLeftRegion = (containerOffset.dx / context.size!.width) < -0.45;
    final isInRightRegion = (containerOffset.dx / context.size!.width) > 0.45;
    //final isInTopRegion = (containerOffset.dy / context.size!.height) < -0.40;


    setState(() {
      colorLike = 0;
      colorNope = 0;
      if (isInLeftRegion || isInRightRegion) {
        /// 左か右エリアの場合の処理です
        /// Tweenの開始位置は現在のコンテナのドラッグ位置を設定します
        /// 終了位置は、コンテナ幅 x 2 * ドラッグされたベクトル成分で算出します（方向ベクトルを増幅させる形）
        /// ドラッグした方向（軌道）を維持し、その移動量を加味した点を終点に置くことで、コンテナを投げ飛ばす感覚を表現します

        slideOutTween = Tween(begin: containerOffset, end: dragVector * (2 * context.size!.width));
        slideOutAnimation.forward(from: 0.0);
        slideOutDirection = isInLeftRegion ? SlideDirection.Left : SlideDirection.Right;
      // } else if (isInTopRegion) {/// 上エリアの場合の処理です
      //   /// 終了位置は、コンテナの高さ x 2 * ドラッグされたベクトル成分で算出します
      //   slideOutTween = Tween(begin: containerOffset, end: dragVector * (2 * context.size!.height));
      //
      //   /// スライドアウトアニメーションを先頭フレームから実行します
      //   slideOutAnimation.forward(from: 0.0);
      //
      //   /// 最終的にスライドされた方向を通知用にセットします
      //   slideOutDirection = SlideDirection.Up;

      } else {
        /// どのエリアにも該当しない場合の処理です
        /// スライドバックアニメーションの開始点を現在のドラッグ位置に設定します
        slideBackStartPosition = containerOffset;

        /// スライドバックアニメーションを先頭フレームから実行します
        slideBackAnimation.forward(from: 0.0);
      }
    });
  }

  /// ドラッグした際の回転角を計算します
  double _rotation() {
    final RenderBox? renderBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && dragStartPosition != null) {
        final Size size = renderBox.size;
        final Offset offset = renderBox.localToGlobal(Offset.zero);

        /// コンテナの中央より上の場合は時計回り(1)、下の場合は半時計回り(-1)に設定します
        final rotationCornerMultiplier = dragStartPosition!.dy >=
            offset.dy + (size.height / 2) ? -1 : 1;

        /// ドラッグされた移動量に応じて回転角を増減させます
        /// 最大で pi / 8 = 22.5 radian の傾きを返却します
        final angle = (pi / 8) * (containerOffset.dx / size.width);

        /// 回転角を返却します
        return angle * rotationCornerMultiplier;
      } else {
        /// ドラッグが開始されていない場合は 0 radian を返却します
        return 0.0;
      }
  }

  /// ドラッグした際の回転角の起点となるポジションを計算します
  /// ドラッグが開始されていない場合は x, y 共に0を返却します
  /// ドラッグ開始位置からドラッグ可能エリア左上の位置を減算し、ドラッグ可能エリア内におけるオフセットを計算します
  Offset _rotationOrigin() {
    final RenderBox? renderBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (dragStartPosition != null && renderBox != null) {
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      return dragStartPosition! - offset;
    } else {
      return const Offset(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.card == null ? Center() : getChild();
  }
  final GlobalKey _widgetKey = GlobalKey();

  Widget getChild() {
    return Container(
      key: _widgetKey,
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      width : MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 1.6,
      child: Transform(
          transform:
          /// xy 軸の移動を設定します
          Matrix4.translationValues(containerOffset.dx, containerOffset.dy, 0.0)
          /// z 軸方向の回転を制御します
            ..rotateZ(_rotation())
          /// コンテナのスケールを設定します
            ..scale(widget.scale, widget.scale),
          /// Transform 処理の原点となる座標を設定します
          origin: _rotationOrigin(),
          /// scale が 1.0 でない場合のみ（背後のカードのみ）、 alignment を center に設定します
          alignment: widget.scale != 1.0 ? Alignment.center : null,
          child: SizedBox(
            key: itemKey,
            width : MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 1.6,
            //padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: getCardContent()
            ),
          ),
        ),
      );
  }
  Widget getCardContent() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 2.0,
            )
          ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildBackground(),
              _buildStamp(),
              _buildProfile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    /// プロフィール写真の表示、切り替え動作に関しては`PhotoView`クラスへ委託します
    return widget.card!.imgPoster == null ? Center() :
    Image(image: widget.card!.imgPoster!,fit: BoxFit.cover);
  }

  Widget _buildStamp(){
    return Container(
      child: Column(
        children: [
          Stack(
            children: [
              Row(children: [
                Spacer(),
                _buildStampText('NOPE',-10,Colors.pink.withOpacity(colorNope)),
              ]),
              Row(children: [
                _buildStampText("LIKE",10,Colors.greenAccent.withOpacity(colorLike)),
                Spacer(),
              ],)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStampText(String text,double angle,Color color){
    return Transform.rotate(
        angle: angle * pi / 180,
        child: Container(
          child: Text(
            text,
            style: TextStyle(
            color: color,
            fontSize: 90,
              fontWeight: FontWeight.w900
          ),
        ),
      ),
    );
  }

  /// 名前、プロフィール文の配置を行います
  Widget _buildProfile() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ]
            )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  wdRowName(),
                  wdRowProfile(),
                  wdRowBtn()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget wdRowName(){
    return(Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Text(
        widget.card!.name,
        style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 3,
      ),
    ));
  }

  Widget wdRowProfile(){
    return(Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        widget.card!.profile,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
        maxLines: 5,
      ),
    ));
  }

  Widget wdRowBtn(){
    return(Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Spacer(),
          glWdIconUser(widget.card!.urlIcon,50),
          const Spacer(),
          wdActionBtn(60,30,Icons.close_outlined,Colors.pink,colorNope,(){
            colorNope = 0.8;
            _slideLeft();
          }),
          const Spacer(),
          wdActionBtn(60,30,Icons.favorite,Colors.greenAccent,colorLike,(){
            colorLike = 0.8;
            _onLike();
            _slideRight();
          }),
          const Spacer(),
          wdActionBtn(50,26,Icons.article_outlined,Colors.lightBlue,0, (){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => VwCardFull(card: widget.card!,onFromExternal: _slideFromExternal),
              //以下を追加
              fullscreenDialog: true,
            )).then((result){
              if(result == null)return;
              if(result){
                _slideLeft();
              }else{
                _slideRight();
              }
            });
          }),
          const Spacer(),
        ],
      ),
    ));
  }

  Widget wdActionBtn(double size,double sizeIcon,IconData icon,Color color,double bgOp,Function() onPres){
    return(Container(
      width: size,
      height: size,
      child: FloatingActionButton(
        heroTag: 'hero${icon.toString()}',
        backgroundColor: color.withOpacity(bgOp),
        shape: CircleBorder(
          side: BorderSide(
            color: color, //色
            width: 1, //太さ
          ),
        ),
        onPressed: onPres,
        child: Icon(
          icon,
          color: color,
          size: sizeIcon,
        ),
      ),
    ));
  }
}