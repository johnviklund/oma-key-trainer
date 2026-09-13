import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "oma-key-trainer"

  readonly property bool opened: trainerLoader.item ? trainerLoader.item.opened === true : false
  readonly property var usageService: bar?.shell?.serviceFor("oma-key-trainer") ?? null

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function injectTrainer() {
    if (!trainerLoader.item) return
    trainerLoader.item.shell = root.bar ? root.bar.shell : null
    trainerLoader.item.usageService = root.usageService
  }

  function open() {
    if (root.usageService) root.usageService.refresh()
    if (trainerLoader.item) trainerLoader.item.open("{}")
  }

  function close() {
    if (trainerLoader.item) trainerLoader.item.close()
  }

  function toggleTrainer() {
    if (root.opened) root.close()
    else root.open()
  }

  onBarChanged: injectTrainer()
  onUsageServiceChanged: injectTrainer()

  Loader {
    id: trainerLoader
    active: true
    visible: false
    source: Qt.resolvedUrl("KeyTrainer.qml")
    onLoaded: root.injectTrainer()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰧑"
    tooltipText: "Open Keybindings Trainer"

    onPressed: function(mouseButton) {
      if (!root.bar || mouseButton !== Qt.LeftButton) return
      root.toggleTrainer()
    }
  }
}
