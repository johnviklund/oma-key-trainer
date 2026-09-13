import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null
  property bool opened: false

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property color scrim: Color.menu.scrim
  property var borderSpec: Border.surfaceSpec(
    "menu", "border", border, Math.max(1, Style.space(2)))
  property string fontFamily: Style.font.menuFamily
  property int contentSpacing: Style.spacing.md
  property int rowHeight: Math.max(Style.space(42), Style.font.body + Style.spacing.rowPaddingX * 2)
  property int keyColumnWidth: Style.space(180)
  readonly property int cardWidth: Math.min(Style.space(640), panel.width - Style.gapsOut * 2)
  readonly property int cardHeight: Math.min(Style.space(640), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    root.opened = true
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "oma-key-trainer")
  }

  function loadKeybindings(raw) {
    var entries = []
    try {
      entries = JSON.parse(raw)
    } catch (error) {
      entries = []
    }

    keybindingsModel.clear()
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      keybindingsModel.append({
        id: String(entry.id || ""),
        keys: String(entry.keys || ""),
        description: String(entry.description || "")
      })
    }
  }

  ListModel {
    id: keybindingsModel
  }

  FileView {
    path: Qt.resolvedUrl("keybindings.json").toString().replace(/^file:\/\//, "")
    watchChanges: false
    onLoaded: root.loadKeybindings(text())
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "oma-key-trainer"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: Style.cornerRadius
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: Style.gapsOut
      anchors.rightMargin: Style.gapsOut
      color: root.background
      borderSpec: root.borderSpec
      padding: Style.spacing.panelPadding

      MouseArea {
        anchors.fill: parent
        onClicked: {}
      }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            root.dismiss()
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: root.contentSpacing

        PanelHero {
          id: hero
          width: parent.width
          title: "Keybindings Trainer"
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        PanelSeparator {
          id: separator
          foreground: root.foreground
        }

        ListView {
          id: keybindingList
          width: parent.width
          height: Math.max(0, parent.height - hero.implicitHeight - separator.height - parent.spacing * 2)
          model: keybindingsModel
          clip: true
          spacing: Style.space(4)
          boundsBehavior: Flickable.StopAtBounds

          delegate: Item {
            required property string keys
            required property string description

            width: ListView.view.width
            height: root.rowHeight

            Row {
              anchors.fill: parent
              spacing: root.contentSpacing

              Text {
                width: root.keyColumnWidth
                anchors.verticalCenter: parent.verticalCenter
                text: keys
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true
                elide: Text.ElideRight
              }

              Text {
                width: parent.width - root.keyColumnWidth - parent.spacing
                anchors.verticalCenter: parent.verticalCenter
                text: description
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                elide: Text.ElideRight
              }
            }
          }
        }
      }
    }
  }
}
