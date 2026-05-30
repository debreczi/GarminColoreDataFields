using Toybox.Activity;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.WatchUi;

class MetricGraphField extends WatchUi.DataField {

    // Supports a full-width Edge 1050 field at the largest selectable scale.
    private const SAMPLE_COUNT = 2400;

    private const COLOR_POWER = 0x00AAFF;
    private const COLOR_HEART_RATE = 0xFF4444;
    private const COLOR_CADENCE = 0x44DD44;

    private var _powerSamples;
    private var _heartRateSamples;
    private var _cadenceSamples;
    private var _sampleIndex;
    private var _sampleSize;
    private var _power;
    private var _heartRate;
    private var _cadence;

    function initialize() {
        DataField.initialize();

        _powerSamples = new [SAMPLE_COUNT];
        _heartRateSamples = new [SAMPLE_COUNT];
        _cadenceSamples = new [SAMPLE_COUNT];
        _sampleIndex = 0;
        _sampleSize = 0;
        _power = null;
        _heartRate = null;
        _cadence = null;
    }

    function compute(info as Activity.Info) as Void {
        if (info == null) {
            return;
        }

        _power = (info has :currentPower) ? info.currentPower : null;
        _heartRate = (info has :currentHeartRate) ? info.currentHeartRate : null;
        _cadence = (info has :currentCadence) ? info.currentCadence : null;

        _powerSamples[_sampleIndex] = _power;
        _heartRateSamples[_sampleIndex] = _heartRate;
        _cadenceSamples[_sampleIndex] = _cadence;

        _sampleIndex = (_sampleIndex + 1) % SAMPLE_COUNT;
        if (_sampleSize < SAMPLE_COUNT) {
            _sampleSize++;
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var secondsPerPixel = property("SecondsPerPixel") as Lang.Number;

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        if (property("ShowPower") as Lang.Boolean) {
            drawSeries(dc, _powerSamples, COLOR_POWER, property("PowerMin") as Lang.Number, property("PowerMax") as Lang.Number, property("PowerOffset") as Lang.Number, secondsPerPixel, width, height);
        }

        if (property("ShowHeartRate") as Lang.Boolean) {
            drawSeries(dc, _heartRateSamples, COLOR_HEART_RATE, property("HeartRateMin") as Lang.Number, property("HeartRateMax") as Lang.Number, property("HeartRateOffset") as Lang.Number, secondsPerPixel, width, height);
        }

        if (property("ShowCadence") as Lang.Boolean) {
            drawSeries(dc, _cadenceSamples, COLOR_CADENCE, property("CadenceMin") as Lang.Number, property("CadenceMax") as Lang.Number, property("CadenceOffset") as Lang.Number, secondsPerPixel, width, height);
        }
    }

    private function drawSeries(dc as Graphics.Dc, samples as Lang.Array, color as Lang.Number, minimum as Lang.Number, maximum as Lang.Number, offset as Lang.Number, secondsPerPixel as Lang.Number, width as Lang.Number, height as Lang.Number) as Void {
        if (_sampleSize < 2 || width < 2 || height < 2) {
            return;
        }

        if (secondsPerPixel < 1) {
            secondsPerPixel = 1;
        }

        if (maximum <= minimum) {
            maximum = minimum + 1;
        }

        var visibleSampleCount = width * secondsPerPixel;
        if (visibleSampleCount > _sampleSize) {
            visibleSampleCount = _sampleSize;
        }

        var oldestIndex = (_sampleIndex + SAMPLE_COUNT - visibleSampleCount) % SAMPLE_COUNT;
        var previousValue = null;
        var previousX = 0;
        var previousY = 0;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        for (var i = 0; i < visibleSampleCount; i++) {
            var age = visibleSampleCount - 1 - i;
            if ((age % secondsPerPixel) != 0) {
                continue;
            }

            var value = samples[(oldestIndex + i) % SAMPLE_COUNT];
            var x = width - 1 - (age / secondsPerPixel);

            if (value != null) {
                var adjustedValue = value + offset;
                if (adjustedValue < minimum) {
                    adjustedValue = minimum;
                } else if (adjustedValue > maximum) {
                    adjustedValue = maximum;
                }

                var y = height - 1 - (((adjustedValue - minimum) * (height - 1)) / (maximum - minimum));
                if (previousValue != null) {
                    dc.drawLine(previousX, previousY, x, y);
                }

                previousValue = adjustedValue;
                previousX = x;
                previousY = y;
            } else {
                previousValue = null;
            }
        }
    }

    private function property(key as Lang.String) {
        return Application.getApp().getProperty(key);
    }
}
