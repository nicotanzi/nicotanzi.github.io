// Arma los links de email al cargar la página, para que la dirección
// no quede escrita en el HTML que leen los scrapers.
(function () {
  var links = document.querySelectorAll(".js-email");
  for (var i = 0; i < links.length; i++) {
    var link = links[i];
    var email =
      link.getAttribute("data-user") + "@" + link.getAttribute("data-domain");
    link.href = "mailto:" + email;
    if (link.hasAttribute("data-show")) link.textContent = email;
  }
})();
