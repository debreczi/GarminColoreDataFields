using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;

class MetricGraphApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new MetricGraphField() ];
    }

    function getSettingsView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] or Null {
        return [ new MetricGraphSettingsView(), new MetricGraphSettingsDelegate() ];
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}
