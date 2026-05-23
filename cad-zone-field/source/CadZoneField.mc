using Toybox.Activity;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.WatchUi;

class CadZoneField extends WatchUi.DataField {

    private const COLOR_ORANGE = 0xFF8800;
    private const COLOR_DEFAULT_BG = Graphics.COLOR_WHITE;

    private var _cadence;
    private var _label;
    private var _bgColor;

    function initialize() {
        DataField.initialize();

        _cadence = null;
        _label = "NO CAD";
        _bgColor = COLOR_DEFAULT_BG;
    }

    function compute(info as Activity.Info) as Void {
        if (info == null) {
            return;
        }

        if (info has :currentCadence && info.currentCadence != null) {
            _cadence = info.currentCadence;
            updateColor();
        } else {
            _cadence = null;
            _label = "NO CAD";
            _bgColor = COLOR_DEFAULT_BG;
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var fgColor = readableTextColor(_bgColor);
        var value = (_cadence == null) ? "--" : _cadence.format("%d");

        dc.setColor(fgColor, _bgColor);
        dc.clear();
        dc.drawText(width / 2, (height * 7) / 100, Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, (height * 36) / 100, Graphics.FONT_NUMBER_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function updateColor() as Void {
        if (_cadence < 70) {
            _label = "CAD <70";
            _bgColor = Graphics.COLOR_BLUE;
        } else if (_cadence < 80) {
            _label = "CAD 70-80";
            _bgColor = Graphics.COLOR_YELLOW;
        } else if (_cadence <= 95) {
            _label = "CAD 80-95";
            _bgColor = Graphics.COLOR_GREEN;
        } else if (_cadence < 105) {
            _label = "CAD 95-105";
            _bgColor = COLOR_ORANGE;
        } else {
            _label = "CAD 105+";
            _bgColor = Graphics.COLOR_RED;
        }
    }

    private function readableTextColor(bgColor as Lang.Number) as Lang.Number {
        if (bgColor == COLOR_DEFAULT_BG || bgColor == Graphics.COLOR_YELLOW || bgColor == Graphics.COLOR_GREEN) {
            return Graphics.COLOR_BLACK;
        }

        return Graphics.COLOR_WHITE;
    }
}
