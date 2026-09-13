import QtQuick
import Quickshell
import Quickshell.Io
import "UsageModel.js" as UsageModel

Item {
  id: root

  // Injected by omarchy-shell when it creates this kept-loaded service.
  property var shell: null
  property var manifest: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string stateDir: home + "/.local/state/omarchy/oma-key-trainer"
  readonly property string countsPath: stateDir + "/counts.json"
  readonly property int completionThreshold: 10
  readonly property var visibleEntries: visibleEntriesModel

  property var poolEntries: []
  property var counts: ({})
  property bool allLearned: false

  function loadPool(raw) {
    try {
      var parsed = JSON.parse(raw)
      root.poolEntries = Array.isArray(parsed) ? parsed : []
    } catch (error) {
      root.poolEntries = []
    }
    root.rebuild()
  }

  function loadCounts(raw) {
    root.counts = UsageModel.parseCounts(raw)
    root.rebuild()
  }

  function rebuild() {
    var rows = UsageModel.visibleEntries(root.poolEntries, root.counts, root.completionThreshold)
    visibleEntriesModel.clear()
    for (var i = 0; i < rows.length; i += 1) {
      visibleEntriesModel.append(rows[i])
    }
    root.allLearned = UsageModel.allLearned(rows)
  }

  function refresh() {
    keybindingsFile.reload()
    countsFile.reload()
  }

  function statusJson() {
    var complete = 0
    for (var i = 0; i < visibleEntriesModel.count; i += 1) {
      if (visibleEntriesModel.get(i).complete) complete += 1
    }
    return JSON.stringify({
      pool: visibleEntriesModel.count,
      complete: complete,
      allLearned: root.allLearned
    })
  }

  ListModel {
    id: visibleEntriesModel
  }

  FileView {
    id: keybindingsFile
    path: Qt.resolvedUrl("keybindings.json").toString().replace(/^file:\/\//, "")
    watchChanges: false
    onLoaded: root.loadPool(text())
  }

  FileView {
    id: countsFile
    path: root.countsPath
    watchChanges: false
    printErrors: false
    onLoaded: root.loadCounts(text())
  }

  FileView {
    id: stateDirWatcher
    path: root.stateDir
    watchChanges: true
    printErrors: false
    onFileChanged: countsFile.reload()
  }

  Component.onCompleted: refresh()

  IpcHandler {
    target: "oma-key-trainer"

    function status(): string {
      return root.statusJson()
    }
  }
}
