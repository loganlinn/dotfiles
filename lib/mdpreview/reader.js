// Embedded so the reader works offline and from file: URLs.
(() => {
  const reader = document.querySelector("body > .mdpreview-reader");
  if (!reader) return;
  const viewport = reader.firstElementChild;
  const article = viewport.firstElementChild;
  const toolbar = document.createElement("div");
  toolbar.className = "mdpreview-toolbar";
  toolbar.setAttribute("role", "region");
  toolbar.setAttribute("aria-label", "Document view");
  toolbar.innerHTML = `
    <button type="button" data-view="scroll" aria-pressed="true">Scroll</button>
    <button type="button" data-view="pages" aria-pressed="false" title="Read facing pages">Two pages</button>
    <div class="mdpreview-pagination" hidden>
      <button type="button" data-turn="-1" aria-label="Previous pages" title="Previous pages (Left arrow)">←</button>
      <span class="mdpreview-page-status" role="status" aria-live="polite" aria-atomic="true"></span>
      <button type="button" data-turn="1" aria-label="Next pages" title="Next pages (Right arrow)">→</button>
    </div>
    <button type="button" data-print>Print / PDF</button>`;
  const nav = document.querySelector('body > nav[aria-label="Documents"]');
  if (nav) toolbar.prepend(nav);
  reader.before(toolbar);

  const pagination = toolbar.querySelector(".mdpreview-pagination");
  const status = toolbar.querySelector(".mdpreview-page-status");
  const previous = toolbar.querySelector('[data-turn="-1"]');
  const next = toolbar.querySelector('[data-turn="1"]');
  let paged = false;
  let firstPage = 0;
  let pageCount = 1;
  let columns = 2;
  let stride = 0;
  let readingAnchor = null;
  let pendingLayout = 0;

  function visibleAnchor() {
    const bounds = paged ? viewport.getBoundingClientRect() : {
      left: 0, right: innerWidth, top: toolbar.getBoundingClientRect().bottom, bottom: innerHeight,
    };
    return Array.from(article.querySelectorAll("h1,h2,h3,h4,h5,h6,p,li,pre,td,img,summary"))
      .find(element => Array.from(element.getClientRects()).some(rect =>
        rect.bottom > bounds.top + 1 && rect.top < bounds.bottom &&
        rect.right > bounds.left + 1 && rect.left < bounds.right));
  }

  function pageFor(element) {
    const rect = Array.from(element.getClientRects()).find(rect => rect.width || rect.height);
    return rect ? Math.max(0, Math.floor(
      (rect.left - article.getBoundingClientRect().left + 1) / stride,
    )) : 0;
  }

  function showPage(page) {
    const lastSpread = Math.floor((pageCount - 1) / columns) * columns;
    firstPage = Math.max(0, Math.min(lastSpread, Math.floor(page / columns) * columns));
    article.style.setProperty("--reader-offset", `${-firstPage * stride}px`);
    const last = Math.min(firstPage + columns, pageCount);
    status.textContent = last === firstPage + 1
      ? `Page ${last} of ${pageCount}` : `Pages ${firstPage + 1}–${last} of ${pageCount}`;
    previous.disabled = firstPage === 0;
    next.disabled = last === pageCount;
    readingAnchor = visibleAnchor();
  }

  function layout(anchor = readingAnchor) {
    if (!paged || matchMedia("print").matches) return;
    const style = getComputedStyle(article);
    columns = Number(style.columnCount);
    const gap = parseFloat(style.columnGap);
    const bounds = article.getBoundingClientRect();
    // clientWidth rounds to whole pixels; that error compounds over long books.
    stride = (bounds.width + gap) / columns;
    const left = bounds.left;
    // Client rects cover every fragment, including the last column of a long table.
    const right = Math.max(left + 1, ...Array.from(article.children)
      .flatMap(element => Array.from(element.getClientRects(), rect => rect.right)));
    pageCount = Math.max(1, Math.ceil((right - left + gap - 1) / stride));
    showPage(anchor?.isConnected ? pageFor(anchor) : firstPage);
  }

  function scheduleLayout() {
    cancelAnimationFrame(pendingLayout);
    pendingLayout = requestAnimationFrame(() => layout());
  }

  function setView(view, remember = true) {
    const anchor = visibleAnchor();
    paged = view === "pages";
    document.documentElement.classList.toggle("mdpreview-paged", paged);
    pagination.hidden = !paged;
    for (const button of toolbar.querySelectorAll("[data-view]")) {
      button.setAttribute("aria-pressed", String(button.dataset.view === view));
    }
    if (paged) {
      window.scrollTo({ top: 0, behavior: "instant" });
      layout(anchor);
    } else {
      anchor?.scrollIntoView({ block: "start", behavior: "instant" });
    }
    if (remember) {
      try { localStorage.setItem("mdpreview-view", view); } catch { /* Storage is optional. */ }
    }
  }

  function revealHash() {
    if (!paged || !location.hash) return;
    let id;
    try { id = decodeURIComponent(location.hash.slice(1)); } catch { return; }
    const target = document.getElementById(id) || document.getElementsByName(id)[0];
    if (target && article.contains(target)) {
      showPage(pageFor(target));
      readingAnchor = target;
    }
  }

  toolbar.addEventListener("click", event => {
    const button = event.target.closest("button");
    if (!button) return;
    if (button.dataset.view) setView(button.dataset.view);
    if (button.dataset.turn) showPage(firstPage + Number(button.dataset.turn) * columns);
    if (button.hasAttribute("data-print")) window.print();
  });
  document.addEventListener("keydown", event => {
    if (!paged || event.altKey || event.ctrlKey || event.metaKey || event.defaultPrevented ||
        event.target.closest("input,textarea,select,[contenteditable]:not([contenteditable=false])")) return;
    if (event.key === " " && event.target.closest("button,a,summary")) return;
    let page;
    if (["ArrowRight", "PageDown"].includes(event.key) || (event.key === " " && !event.shiftKey)) {
      page = firstPage + columns;
    } else if (["ArrowLeft", "PageUp"].includes(event.key) || (event.key === " " && event.shiftKey)) {
      page = firstPage - columns;
    } else if (event.key === "Home") page = 0;
    else if (event.key === "End") page = pageCount - 1;
    else if (event.key === "Escape") setView("scroll");
    else return;
    event.preventDefault();
    if (page !== undefined) showPage(page);
  });
  article.addEventListener("focusin", event => {
    if (paged) {
      showPage(pageFor(event.target));
      readingAnchor = event.target;
    }
  });
  article.addEventListener("click", event => {
    const link = event.target.closest("a[href]");
    if (!paged || !link || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
    const url = new URL(link.href, location.href);
    if (url.hash && url.href.split("#")[0] === location.href.split("#")[0]) {
      // Handle a repeated click on the current hash, which has no hashchange event.
      requestAnimationFrame(revealHash);
    }
  });
  window.addEventListener("hashchange", revealHash);
  window.addEventListener("resize", scheduleLayout);
  window.addEventListener("afterprint", scheduleLayout);
  article.addEventListener("load", scheduleLayout, true);
  new MutationObserver(scheduleLayout).observe(article, {
    childList: true, subtree: true, attributes: true, attributeFilter: ["open"],
  });
  document.fonts.ready.then(scheduleLayout);
  try {
    if (localStorage.getItem("mdpreview-view") === "pages") setView("pages", false);
  } catch { /* Reading also works when file: storage is unavailable. */ }
  revealHash();
})();
