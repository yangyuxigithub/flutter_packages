import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:particle_text/particle_text_painter.dart';

class ParticleHeader extends Header {

  GlobalKey _key = new GlobalKey();

  ParticleHeader() : super(extent: 120, triggerDistance: 120);

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {

    _handleRefreshState(refreshState);

    return Container(
      child: ParticleText(text: '慧停车+', height: pulledExtent, key: _key),
    );
  }

  /*状态处理*/
  _handleRefreshState(RefreshMode refreshState) {

    ParticleTextState state = _key.currentState;

    if (refreshState == RefreshMode.refresh) {
      state.bomb();
    }

    if (refreshState == RefreshMode.done) {
      state.recovery();
    }

  }
}
