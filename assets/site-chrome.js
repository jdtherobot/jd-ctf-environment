/* ==========================================================================
   Chiral Lab — site banner injector + day/night toggle
   Drop-in: <link site-theme.css><link site-chrome.css><script defer site-chrome.js>
   Injects the britt.gg banner as the first element of <body> and wires the
   mode toggle. The chosen mode is written to <html data-mode> and persisted to
   localStorage('jdb-mode') — the SAME key the main site and planner use, so the
   day/night choice carries across britt.gg, the lab, and the financial planner.
   ========================================================================== */
(function () {
  'use strict';

  var SITE = 'https://britt.gg/';
  var LINKS = [
    { label: 'Background', href: 'https://britt.gg/#sec-background' },
    { label: 'Research Direction', href: 'https://britt.gg/#sec-research' },
    { label: 'Work', href: 'https://britt.gg/#sec-work' },
    { label: 'Projects', href: 'https://britt.gg/#sec-projects' },
  ];
  var KEY = 'jdb-mode';
  var root = document.documentElement;

  function currentMode() {
    var saved = null;
    try {
      saved = localStorage.getItem(KEY);
    } catch (e) {
      /* ignore */
    }
    return root.getAttribute('data-mode') || saved || 'day';
  }

  function applyMode(mode) {
    root.setAttribute('data-mode', mode);
    if (header) {
      header.setAttribute('data-night', mode === 'night' ? '1' : '0');
      if (label) label.textContent = mode;
      if (toggle) toggle.setAttribute('aria-pressed', mode === 'night' ? 'true' : 'false');
    }
  }

  // set the mode before paint to avoid a flash
  var startMode = currentMode();
  root.setAttribute('data-mode', startMode);

  var header, label, toggle;

  function build() {
    header = document.createElement('header');
    header.className = 'site-header';

    var inner = document.createElement('div');
    inner.className = 'site-header__inner';

    // brand
    var brand = document.createElement('a');
    brand.className = 'site-header__brand';
    brand.href = SITE;
    brand.setAttribute('aria-label', 'JD Britt — britt.gg home');
    brand.innerHTML =
      '<svg class="site-header__mark" viewBox="0 0 32 32" aria-hidden="true" focusable="false">' +
      '<polyline points="2,16 10,16 13,5 17,27 20,16 30,16" fill="none" stroke-width="2.6" ' +
      'stroke-linecap="round" stroke-linejoin="round"></polyline></svg>' +
      '<span class="site-header__wordmark">JD BRITT</span>';

    // section links
    var nav = document.createElement('nav');
    nav.className = 'site-header__links';
    nav.setAttribute('aria-label', 'Site sections');
    LINKS.forEach(function (l) {
      var a = document.createElement('a');
      a.href = l.href;
      a.textContent = l.label;
      nav.appendChild(a);
    });

    // day/night toggle
    var right = document.createElement('div');
    right.className = 'site-header__right';
    label = document.createElement('span');
    label.className = 'site-header__mode-label';
    toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = 'site-header__toggle';
    toggle.setAttribute('aria-label', 'Toggle day and night mode');
    toggle.innerHTML = '<span class="site-header__thumb"></span>';
    toggle.addEventListener('click', function () {
      var next = currentMode() === 'night' ? 'day' : 'night';
      try {
        localStorage.setItem(KEY, next);
      } catch (e) {
        /* ignore */
      }
      applyMode(next);
    });
    right.appendChild(label);
    right.appendChild(toggle);

    inner.appendChild(brand);
    inner.appendChild(nav);
    inner.appendChild(right);
    header.appendChild(inner);
    document.body.insertBefore(header, document.body.firstChild);

    applyMode(startMode);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', build);
  } else {
    build();
  }
})();
