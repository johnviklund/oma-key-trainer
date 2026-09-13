function parseCounts(raw) {
  if (!raw) {
    return {};
  }

  try {
    var document = JSON.parse(raw);
    if (!document || typeof document !== "object" || !document.counts || typeof document.counts !== "object") {
      return {};
    }

    var counts = {};
    for (var action in document.counts) {
      if (!Object.prototype.hasOwnProperty.call(document.counts, action)) {
        continue;
      }

      var count = Number(document.counts[action]);
      if (isFinite(count) && count >= 0) {
        counts[action] = Math.floor(count);
      }
    }

    return counts;
  } catch (error) {
    return {};
  }
}

function visibleEntries(pool, counts, threshold, windowSize) {
  var rows = [];
  var source = Array.isArray(pool) ? pool : [];
  var usage = counts || {};
  var targetWindow = Number(windowSize);

  if (!isFinite(targetWindow) || targetWindow < 1) {
    targetWindow = source.length;
  } else {
    targetWindow = Math.floor(targetWindow);
  }

  for (var index = 0; index < source.length; index += 1) {
    var entry = source[index];
    var rawCount = Number(usage[entry.action]);
    var count = isFinite(rawCount) && rawCount >= 0 ? Math.floor(rawCount) : 0;
    var row = {
      id: entry.id,
      keys: entry.keys,
      description: entry.description,
      action: entry.action,
      count: count,
      complete: count >= threshold,
    };

    rows.push(row);
  }

  var windowEnd = rows.length;
  var incompleteCount = 0;
  for (var i = 0; i < rows.length; i += 1) {
    if (!rows[i].complete) {
      incompleteCount += 1;
    }
    if (incompleteCount >= targetWindow) {
      windowEnd = i + 1;
      break;
    }
  }

  var pulled = [];
  var initial = [];
  var complete = [];
  for (var rowIndex = 0; rowIndex < windowEnd; rowIndex += 1) {
    var visibleRow = rows[rowIndex];
    if (visibleRow.complete) {
      complete.push(visibleRow);
    } else if (rowIndex >= targetWindow) {
      pulled.unshift(visibleRow);
    } else {
      initial.push(visibleRow);
    }
  }

  return pulled.concat(initial, complete);
}

function allLearned(rows) {
  if (!rows || rows.length === 0) {
    return false;
  }

  for (var index = 0; index < rows.length; index += 1) {
    if (!rows[index].complete) {
      return false;
    }
  }

  return true;
}
