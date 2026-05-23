using Toybox.Activity;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.UserProfile;
using Toybox.WatchUi;

class PowerZoneField extends WatchUi.DataField {

    private const SAMPLE_COUNT = 3;
    private const COLOR_ORANGE = 0xFF8800;
    private const COLOR_DEFAULT_BG = Graphics.COLOR_WHITE;

    private var _powerSamples;
    private var _sampleIndex;
    private var _sampleSize;
    private var _threeSecondPower;
    private var _zone;
    private var _zoneLabel;
    private var _zoneColor;
    private var _zones;

    function initialize() {
        DataField.initialize();

        _powerSamples = [ null, null, null ];
        _sampleIndex = 0;
        _sampleSize = 0;
        _threeSecondPower = null;
        _zone = 0;
        _zoneLabel = "NO POWER";
        _zoneColor = COLOR_DEFAULT_BG;
        _zones = null;

        loadPowerZones();
    }

    function compute(info as Activity.Info) as Void {
        if (info == null) {
            return;
        }

        if (info has :currentPower && info.currentPower != null) {
            addPowerSample(info.currentPower);
            updateZone();
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var fgColor = readableTextColor(_zoneColor);
        var value = (_threeSecondPower == null) ? "--" : _threeSecondPower.format("%d");

        dc.setColor(fgColor, _zoneColor);
        dc.clear();
        dc.drawText(width / 2, (height * 7) / 100, Graphics.FONT_XTINY, _zoneLabel, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, (height * 36) / 100, Graphics.FONT_NUMBER_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function addPowerSample(power as Lang.Number) as Void {
        _powerSamples[_sampleIndex] = power;
        _sampleIndex = (_sampleIndex + 1) % SAMPLE_COUNT;

        if (_sampleSize < SAMPLE_COUNT) {
            _sampleSize++;
        }

        var total = 0;
        for (var i = 0; i < _sampleSize; i++) {
            total += _powerSamples[i];
        }

        _threeSecondPower = (total + (_sampleSize / 2)) / _sampleSize;
    }

    private function loadPowerZones() as Void {
        try {
            _zones = UserProfile.getPowerZones(Activity.SPORT_CYCLING);
        } catch (ex) {
            _zones = null;
        }
    }

    private function updateZone() as Void {
        if (_zones == null || _zones.size() < 2) {
            loadPowerZones();
        }

        if (_zones == null || _zones.size() < 2 || _threeSecondPower == null) {
            _zone = 0;
            _zoneLabel = "POWER";
            _zoneColor = COLOR_DEFAULT_BG;
            return;
        }

        _zone = zoneForValue(_threeSecondPower, _zones);
        _zoneLabel = zoneLabel("PWR", _zone);
        _zoneColor = zoneColor(_zone);
    }

    private function zoneForValue(value as Lang.Number, zones as Lang.Array) as Lang.Number {
        if (value < zones[0]) {
            return 0;
        }

        for (var i = 1; i < zones.size(); i++) {
            if (value <= zones[i]) {
                return i;
            }
        }

        return zones.size() - 1;
    }

    private function zoneLabel(prefix as Lang.String, zone as Lang.Number) as Lang.String {
        if (zone == 0) {
            return prefix + " <Z1";
        }

        return prefix + " Z" + zone.format("%d");
    }

    private function zoneColor(zone as Lang.Number) as Lang.Number {
        if (zone == 1) {
            return Graphics.COLOR_BLUE;
        } else if (zone == 2) {
            return Graphics.COLOR_GREEN;
        } else if (zone == 3) {
            return Graphics.COLOR_YELLOW;
        } else if (zone == 4) {
            return COLOR_ORANGE;
        } else if (zone >= 5) {
            return Graphics.COLOR_RED;
        }

        return COLOR_DEFAULT_BG;
    }

    private function readableTextColor(bgColor as Lang.Number) as Lang.Number {
        if (bgColor == COLOR_DEFAULT_BG || bgColor == Graphics.COLOR_YELLOW || bgColor == Graphics.COLOR_GREEN) {
            return Graphics.COLOR_BLACK;
        }

        return Graphics.COLOR_WHITE;
    }
}
