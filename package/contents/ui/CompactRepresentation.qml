import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../code/parser.js" as Parser

// Panel view: one two-ring radial gauge per provider
// (outer ring = session left, inner ring = weekly left).
Item {
    id: compact

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property int gaugeSize: compact.vertical
        ? Math.min(compact.width, Kirigami.Units.gridUnit * 2.4)
        : Math.min(compact.height, Kirigami.Units.gridUnit * 2.4)
    readonly property int count: Math.max(1, root.models.length)
    readonly property var labels: Parser.providerLabels(root.models)

    Layout.minimumWidth: compact.vertical ? compact.gaugeSize : compact.count * (compact.gaugeSize + gaugeGrid.spacing)
    Layout.minimumHeight: compact.vertical ? compact.count * (compact.gaugeSize + gaugeGrid.spacing) : compact.gaugeSize

    Grid {
        id: gaugeGrid
        anchors.centerIn: parent
        columns: compact.vertical ? 1 : compact.count
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: root.models.length === 0
            source: Qt.resolvedUrl("../icons/codexbar.svg")
            width: compact.gaugeSize
            height: compact.gaugeSize
            opacity: root.loading ? 0.5 : 1
        }

        Repeater {
            model: root.models

            delegate: RadialGauge {
                id: meter
                required property var modelData
                readonly property var rings: Parser.gaugeRings(modelData)
                readonly property int centerPercent: Parser.gaugeCenterPercent(modelData)
                readonly property string hoverLabel: compact.labels[modelData.id]
                    || Parser.shortName(modelData.id)

                width: compact.gaugeSize
                height: compact.gaugeSize
                outerColor: root.sessionColor
                innerColor: root.weeklyColor
                outerPercent: rings.outerIdx >= 0
                    ? modelData.windows[rings.outerIdx].usedPercent : -1
                innerPercent: rings.innerIdx >= 0
                    ? modelData.windows[rings.innerIdx].usedPercent : -1
                centerText: meter.hovered
                    ? meter.hoverLabel
                    : (modelData.error
                        ? "!"
                        : (meter.centerPercent >= 0 ? String(meter.centerPercent) : ""))
                centerTextScale: meter.hovered
                    ? (meter.hoverLabel.length <= 1
                        ? 0.36
                        : (meter.hoverLabel.length === 2 ? 0.30 : 0.22))
                    : 0.34
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
