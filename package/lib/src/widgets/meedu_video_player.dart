import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:flutter_meedu_videoplayer/src/widgets/styles/controls_container.dart';
import 'package:flutter_meedu_videoplayer/src/widgets/styles/primary/primary_list_player_controls.dart';
import 'package:flutter_meedu_videoplayer/src/widgets/styles/primary/primary_player_controls.dart';
import 'package:flutter_meedu_videoplayer/src/widgets/styles/secondary/secondary_player_controls.dart';
import '../helpers/shortcuts/intent_action_map.dart';

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    // customDebugPrint('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}

class MeeduVideoPlayer extends StatefulWidget {
  final MeeduPlayerController controller;

  final Widget Function(
    BuildContext context,
    MeeduPlayerController controller,
    Responsive responsive,
  )? header;

  final Widget Function(
    BuildContext context,
    MeeduPlayerController controller,
    Responsive responsive,
  )? bottomRight;

  final CustomIcons Function(
    Responsive responsive,
  )? customIcons;

  final List<Widget> Function(
    BuildContext context,
    MeeduPlayerController controller,
    Responsive responsive,
  )? overlays;

  ///[customControls] this only needed when controlsStyle is [ControlsStyle.custom]
  final Widget Function(
    BuildContext context,
    MeeduPlayerController controller,
    Responsive responsive,
  )? customControls;

  final Widget Function(
    BuildContext context,
    MeeduPlayerController controller,
    Responsive responsive,
  )? overlayControls;

  ///[customCaptionView] when a custom view for the captions is needed
  final Widget Function(BuildContext context, MeeduPlayerController controller,
      Responsive responsive, String text)? customCaptionView;

  /// The distance from the bottom of the screen to the closed captions text.
  ///
  /// This value represents the vertical position of the closed captions display
  /// from the bottom of the screen. It is measured in logical pixels and can be
  /// used to adjust the positioning of the closed captions within the video player
  /// UI. A higher value will move the closed captions higher on the screen, while
  /// a lower value will move them closer to the bottom.
  ///
  /// By adjusting this distance, you can ensure that the closed captions are
  /// displayed at an optimal position that doesn't obstruct other important
  /// elements of the video player interface.
  final double closedCaptionDistanceFromBottom;
  const MeeduVideoPlayer(
      {Key? key,
      required this.controller,
      this.header,
      this.bottomRight,
      this.customIcons,
      this.overlays,
      this.customControls,
      this.overlayControls,
      this.customCaptionView,
      this.closedCaptionDistanceFromBottom = 40})
      : super(key: key);

  @override
  State<MeeduVideoPlayer> createState() => _MeeduVideoPlayerState();
}

class _MeeduVideoPlayerState extends State<MeeduVideoPlayer> {
  double videoWidth(VideoPlayerController? controller) {
    double width = controller != null
        ? controller.value.size.width != 0
            ? controller.value.size.width
            : 640
        : 640;
    return width;
    // if (width < max) {
    //   return max;
    // } else {
    //   return width;
    // }
  }

  double videoHeight(VideoPlayerController? controller) {
    double height = controller != null
        ? controller.value.size.height != 0
            ? controller.value.size.height
            : 480
        : 480;
    return height;
    // if (height < max) {
    //   return max;
    // } else {
    //   return height;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: activatorsToCallBacks(widget.controller, context),
      child: Focus(
        autofocus: true,
        child: MeeduPlayerProvider(
          controller: widget.controller,
          child: Container(
              color: Colors.black,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  MeeduPlayerController _ = widget.controller;
                  if (_.controlsEnabled) {
                    _.responsive.setDimensions(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                  }

                  if (widget.customIcons != null) {
                    _.customIcons = widget.customIcons!(_.responsive);
                  }

                  if (widget.header != null) {
                    _.header = widget.header!(context, _, _.responsive);
                  }

                  if (widget.bottomRight != null) {
                    _.bottomRight =
                        widget.bottomRight!(context, _, _.responsive);
                  }

                  if (widget.overlays != null) {
                    _.overlays = widget.overlays;
                  }

                  if (widget.customControls != null) {
                    _.customControls =
                        widget.customControls!(context, _, _.responsive);
                  }

                  if (widget.overlayControls != null) {
                    _.overlayControls = widget.overlayControls!;
                  }

                  return ExcludeFocus(
                    excluding: _.excludeFocus,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RxBuilder(
                            (__) {
                          _.dataStatus.status.value;
                          _.customDebugPrint(
                              "Fit is ${widget.controller.videoFit.value}");
                          return Positioned.fill(
                            child: FittedBox(
                              clipBehavior: Clip.hardEdge,
                              fit: widget.controller.videoFit.value,
                              child: SizedBox(
                                width: videoWidth(
                                  _.videoPlayerController,
                                ),
                                height: videoHeight(
                                  _.videoPlayerController,
                                ),
                                child: _.videoPlayerController != null
                                    ? VideoPlayer(_.videoPlayerController!)
                                    : Container(),
                              ),
                            ),
                          );
                        }),
                        if (_.overlays != null)
                          ..._.overlays!(context, _, _.responsive),
                        ClosedCaptionView(
                          responsive: _.responsive,
                          distanceFromBottom:
                              widget.closedCaptionDistanceFromBottom,
                          customCaptionView: widget.customCaptionView,
                        ),
                        if (_.controlsEnabled &&
                            _.controlsStyle == ControlsStyle.primary)
                          PrimaryVideoPlayerControls(
                            responsive: _.responsive,
                          ),
                        if (_.controlsEnabled &&
                            _.controlsStyle == ControlsStyle.primaryList)
                          PrimaryListVideoPlayerControls(
                            responsive: _.responsive,
                          ),
                        if (_.controlsEnabled &&
                            _.controlsStyle == ControlsStyle.secondary)
                          SecondaryVideoPlayerControls(
                            responsive: _.responsive,
                          ),
                        if (_.controlsEnabled &&
                            _.controlsStyle == ControlsStyle.custom &&
                            _.customControls != null)
                          ControlsContainer(
                            responsive: _.responsive,
                            child: _.customControls!,
                          ),
                        if (_.overlayControls != null)
                          _.overlayControls!(context, _, _.responsive),
                      ],
                    ),
                  );
                },
              )),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MeeduPlayerProvider extends InheritedWidget {
  final MeeduPlayerController controller;

  const MeeduPlayerProvider({
    Key? key,
    required Widget child,
    required this.controller,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
