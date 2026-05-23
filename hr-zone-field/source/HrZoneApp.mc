using Toybox.Application;
using Toybox.WatchUi;

class HrZoneApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new HrZoneField() ];
    }
}
