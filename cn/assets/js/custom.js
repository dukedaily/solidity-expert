require(["gitbook"], function (gitbook) {
  gitbook.events.bind("page.change", function () {
    // Save the current position of the page in the session storage
    sessionStorage.setItem("scrollPosition", window.scrollY);
  });

  gitbook.events.bind("page.change", function () {
    // Restore the current position of the page from the session storage
    var scrollPosition = sessionStorage.getItem("scrollPosition");
    if (scrollPosition !== null) {
      window.scrollTo(0, scrollPosition);
      sessionStorage.removeItem("scrollPosition");
    }
  });
});
