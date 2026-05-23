using Toybox.Application;
using Toybox.WatchUi;

class GradeZoneApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new GradeZoneField() ];
    }
}
