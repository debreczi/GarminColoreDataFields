using Toybox.Application;
using Toybox.WatchUi;

class PowerZoneApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new PowerZoneField() ];
    }
}
