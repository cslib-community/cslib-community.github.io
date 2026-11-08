// Send requests for projects that moved within www.cslib.io to their new location.
// GitHub Pages does not redirect a project site when its repository is renamed, so requests for
// the old path fall through to this site's 404 page, which loads this script.
(function () {
  var moved = {
    // cslib-community/complexitylib was renamed to cslib-community/cslib-frontier (2026-11-08).
    "/complexitylib/": "/cslib-frontier/"
  };
  var location = window.location;
  var path = location.pathname;
  for (var from in moved) {
    if (path === from.slice(0, -1) || path.indexOf(from) === 0) {
      location.replace(moved[from] + path.slice(from.length) + location.search + location.hash);
      return;
    }
  }
})();
