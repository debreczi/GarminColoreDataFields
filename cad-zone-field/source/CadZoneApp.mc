using Toybox.Application;
using Toybox.WatchUi;

class CadZoneApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new CadZoneField() ];
    }
}
