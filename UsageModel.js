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

function visibleEntries(pool, counts, threshold) {
  var incomplete = [];
  var complete = [];
  var source = Array.isArray(pool) ? pool : [];
  var usage = counts || {};

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

    if (row.complete) {
      complete.push(row);
    } else {
      incomplete.push(row);
    }
  }

  return incomplete.concat(complete);
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
