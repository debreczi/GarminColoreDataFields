using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.WatchUi;

class MetricGraphSettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.clearClip();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_SMALL, "Press Menu\nfor graph settings", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class MetricGraphSettingsDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Lang.Boolean {
        WatchUi.pushView(new MetricGraphSettingsMenu(), new MetricGraphSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class MetricGraphSettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title=>"Graph Settings" });

        addItem(new WatchUi.MenuItem("History", valueLabel("SecondsPerPixel", " sec/px"), "SecondsPerPixel", null));

        addItem(new WatchUi.ToggleMenuItem("Show power", null, "ShowPower", property("ShowPower") as Lang.Boolean, null));
        addItem(new WatchUi.MenuItem("Power min", valueLabel("PowerMin", " W"), "PowerMin", null));
        addItem(new WatchUi.MenuItem("Power max", valueLabel("PowerMax", " W"), "PowerMax", null));
        addItem(new WatchUi.MenuItem("Power offset", signedValueLabel("PowerOffset", " W"), "PowerOffset", null));

        addItem(new WatchUi.ToggleMenuItem("Show heart rate", null, "ShowHeartRate", property("ShowHeartRate") as Lang.Boolean, null));
        addItem(new WatchUi.MenuItem("HR min", valueLabel("HeartRateMin", " bpm"), "HeartRateMin", null));
        addItem(new WatchUi.MenuItem("HR max", valueLabel("HeartRateMax", " bpm"), "HeartRateMax", null));
        addItem(new WatchUi.MenuItem("HR offset", signedValueLabel("HeartRateOffset", " bpm"), "HeartRateOffset", null));

        addItem(new WatchUi.ToggleMenuItem("Show cadence", null, "ShowCadence", property("ShowCadence") as Lang.Boolean, null));
        addItem(new WatchUi.MenuItem("Cadence min", valueLabel("CadenceMin", " rpm"), "CadenceMin", null));
        addItem(new WatchUi.MenuItem("Cadence max", valueLabel("CadenceMax", " rpm"), "CadenceMax", null));
        addItem(new WatchUi.MenuItem("Cadence offset", signedValueLabel("CadenceOffset", " rpm"), "CadenceOffset", null));
    }

    private function valueLabel(key as Lang.String, suffix as Lang.String) as Lang.String {
        return (property(key) as Lang.Number).format("%d") + suffix;
    }

    private function signedValueLabel(key as Lang.String, suffix as Lang.String) as Lang.String {
        var value = property(key) as Lang.Number;
        return ((value > 0) ? "+" : "") + value.format("%d") + suffix;
    }

    private function property(key as Lang.String) {
        return Application.getApp().getProperty(key);
    }
}

class MetricGraphSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(menuItem as WatchUi.MenuItem) as Void {
        var key = menuItem.getId() as Lang.String;

        if (menuItem instanceof WatchUi.ToggleMenuItem) {
            Application.getApp().setProperty(key, (menuItem as WatchUi.ToggleMenuItem).isEnabled());
            WatchUi.requestUpdate();
            return;
        }

        var menu;
        if (key.equals("SecondsPerPixel")) {
            menu = new MetricGraphHistoryMenu();
        } else if (key.equals("PowerMin")) {
            menu = new MetricGraphValueMenu("Power minimum", key, 0, 500, 25, " W");
        } else if (key.equals("PowerMax")) {
            menu = new MetricGraphValueMenu("Power maximum", key, 100, 1500, 25, " W");
        } else if (key.equals("PowerOffset")) {
            menu = new MetricGraphValueMenu("Power offset", key, -200, 200, 10, " W");
        } else if (key.equals("HeartRateMin")) {
            menu = new MetricGraphValueMenu("HR minimum", key, 0, 200, 5, " bpm");
        } else if (key.equals("HeartRateMax")) {
            menu = new MetricGraphValueMenu("HR maximum", key, 100, 250, 5, " bpm");
        } else if (key.equals("HeartRateOffset")) {
            menu = new MetricGraphValueMenu("HR offset", key, -100, 100, 5, " bpm");
        } else if (key.equals("CadenceMin")) {
            menu = new MetricGraphValueMenu("Cadence minimum", key, 0, 150, 5, " rpm");
        } else if (key.equals("CadenceMax")) {
            menu = new MetricGraphValueMenu("Cadence maximum", key, 50, 250, 5, " rpm");
        } else {
            menu = new MetricGraphValueMenu("Cadence offset", key, -100, 100, 5, " rpm");
        }

        WatchUi.pushView(menu, new MetricGraphValueMenuDelegate(key, menuItem), WatchUi.SLIDE_UP);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class MetricGraphValueMenu extends WatchUi.Menu2 {

    function initialize(title as Lang.String, key as Lang.String, minimum as Lang.Number, maximum as Lang.Number, step as Lang.Number, suffix as Lang.String) {
        Menu2.initialize({ :title=>title });

        for (var value = minimum; value <= maximum; value += step) {
            addItem(new WatchUi.MenuItem(formatValue(value, suffix), null, value, null));
        }
    }

    private function formatValue(value as Lang.Number, suffix as Lang.String) as Lang.String {
        return ((value > 0) ? "+" : "") + value.format("%d") + suffix;
    }
}

class MetricGraphHistoryMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title=>"History" });

        addItem(new WatchUi.MenuItem("1 second per pixel", null, 1, null));
        addItem(new WatchUi.MenuItem("2 seconds per pixel", null, 2, null));
        addItem(new WatchUi.MenuItem("3 seconds per pixel", null, 3, null));
        addItem(new WatchUi.MenuItem("5 seconds per pixel", null, 5, null));
    }
}

class MetricGraphValueMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _key;
    private var _parentItem;

    function initialize(key as Lang.String, parentItem as WatchUi.MenuItem) {
        Menu2InputDelegate.initialize();
        _key = key;
        _parentItem = parentItem;
    }

    function onSelect(menuItem as WatchUi.MenuItem) as Void {
        var value = menuItem.getId() as Lang.Number;
        Application.getApp().setProperty(_key, value);
        _parentItem.setSubLabel(value.format("%d"));
        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
