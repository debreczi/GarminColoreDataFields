using Toybox.Activity;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.WatchUi;

class GradeZoneField extends WatchUi.DataField {

    private const SAMPLE_COUNT = 8;
    private const MIN_DISTANCE_DELTA = 8.0;
    private const COLOR_ORANGE = 0xFF8800;
    private const COLOR_DARK_RED = 0x880000;
    private const COLOR_DEFAULT_BG = Graphics.COLOR_WHITE;

    private var _distances;
    private var _altitudes;
    private var _sampleIndex;
    private var _sampleSize;
    private var _grade;
    private var _label;
    private var _bgColor;

    function initialize() {
        DataField.initialize();

        _distances = [ null, null, null, null, null, null, null, null ];
        _altitudes = [ null, null, null, null, null, null, null, null ];
        _sampleIndex = 0;
        _sampleSize = 0;
        _grade = null;
        _label = "NO GRADE";
        _bgColor = COLOR_DEFAULT_BG;
    }

    function compute(info as Activity.Info) as Void {
        if (info == null) {
            return;
        }

        if (info has :elapsedDistance && info has :altitude && info.elapsedDistance != null && info.altitude != null) {
            addSample(info.elapsedDistance, info.altitude);
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var fgColor = readableTextColor(_bgColor);
        var value = (_grade == null) ? "--" : _grade.format("%.1f");

        dc.setColor(fgColor, _bgColor);
        dc.clear();
        dc.drawText(width / 2, (height * 7) / 100, Graphics.FONT_XTINY, _label, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, (height * 36) / 100, Graphics.FONT_NUMBER_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function addSample(distance as Lang.Float, altitude as Lang.Float) as Void {
        _distances[_sampleIndex] = distance;
        _altitudes[_sampleIndex] = altitude;
        _sampleIndex = (_sampleIndex + 1) % SAMPLE_COUNT;

        if (_sampleSize < SAMPLE_COUNT) {
            _sampleSize++;
        }

        if (_sampleSize < 2) {
            return;
        }

        var oldestIndex = (_sampleIndex + SAMPLE_COUNT - _sampleSize) % SAMPLE_COUNT;
        var distanceDelta = distance - _distances[oldestIndex];
        if (distanceDelta < MIN_DISTANCE_DELTA) {
            return;
        }

        _grade = ((altitude - _altitudes[oldestIndex]) / distanceDelta) * 100.0;
        updateColor();
    }

    private function updateColor() as Void {
        if (_grade < -1.0) {
            _label = "DOWN";
            _bgColor = Graphics.COLOR_BLUE;
        } else if (_grade < 3.0) {
            _label = "GRADE";
            _bgColor = COLOR_DEFAULT_BG;
        } else if (_grade < 6.0) {
            _label = "GRADE 3-6";
            _bgColor = Graphics.COLOR_GREEN;
        } else if (_grade < 9.0) {
            _label = "GRADE 6-9";
            _bgColor = Graphics.COLOR_YELLOW;
        } else if (_grade < 12.0) {
            _label = "GRADE 9-12";
            _bgColor = COLOR_ORANGE;
        } else if (_grade < 15.0) {
            _label = "GRADE 12-15";
            _bgColor = Graphics.COLOR_RED;
        } else {
            _label = "GRADE 15+";
            _bgColor = COLOR_DARK_RED;
        }
    }

    private function readableTextColor(bgColor as Lang.Number) as Lang.Number {
        if (bgColor == COLOR_DEFAULT_BG || bgColor == Graphics.COLOR_YELLOW || bgColor == Graphics.COLOR_GREEN) {
            return Graphics.COLOR_BLACK;
        }

        return Graphics.COLOR_WHITE;
    }
}
