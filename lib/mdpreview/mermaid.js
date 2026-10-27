// This file is embedded in the HTML so file: previews need no local module server.
const blocks = document.querySelectorAll("pre.mermaid");

function showError(block, message) {
  const error = document.createElement("p");
  error.className = "mermaid-error";
  error.setAttribute("role", "status");
  error.textContent = message;
  block.before(error);
}

function diagramTheme() {
  // Let the browser convert CSS colors to sRGB and composite translucent layers.
  const canvas = document.createElement("canvas");
  canvas.width = canvas.height = 1;
  const context = canvas.getContext("2d", { willReadFrequently: true });
  const scheme = getComputedStyle(document.documentElement).colorScheme;
  const darkCanvas = scheme.includes("dark") && (
    !scheme.includes("light") || matchMedia("(prefers-color-scheme: dark)").matches
  );
  context.fillStyle = darkCanvas ? "black" : "white";
  context.fillRect(0, 0, 1, 1);
  for (const element of [document.documentElement, document.body]) {
    context.fillStyle = getComputedStyle(element).backgroundColor;
    context.fillRect(0, 0, 1, 1);
  }
  const [red, green, blue] = context.getImageData(0, 0, 1, 1).data;
  return red * 0.2126 + green * 0.7152 + blue * 0.0722 < 128 ? "dark" : "default";
}

function diagramId(index) {
  let id = `mdpreview-mermaid-${index}`;
  // Mermaid also reserves d<id> and i<id> for temporary rendering elements.
  while ([id, `d${id}`, `i${id}`].some(candidate => document.getElementById(candidate))) {
    id += "-diagram";
  }
  return id;
}

function themeVariables(theme) {
  const dark = theme === "dark";
  const text = dark ? "#cdd6f4" : "#27324b";
  return {
    darkMode: dark,
    background: dark ? "#1e1e2e" : "#ffffff",
    fontFamily: getComputedStyle(document.body).fontFamily,
    fontSize: "15px",
    primaryColor: dark ? "#313244" : "#eef2ff",
    primaryBorderColor: dark ? "#89b4fa" : "#6175b5",
    primaryTextColor: text,
    secondaryColor: dark ? "#293d40" : "#e6f4ef",
    secondaryBorderColor: dark ? "#94e2d5" : "#4d897b",
    secondaryTextColor: text,
    tertiaryColor: dark ? "#262637" : "#f4f6fa",
    tertiaryBorderColor: dark ? "#585b70" : "#bcc5d8",
    tertiaryTextColor: text,
    lineColor: dark ? "#a6adc8" : "#65718b",
    textColor: text,
    edgeLabelBackground: dark ? "#1e1e2e" : "#ffffff",
    noteBkgColor: dark ? "#443e36" : "#fff5db",
    noteBorderColor: dark ? "#f9e2af" : "#bd9851",
    noteTextColor: text,
  };
}

async function saveDiagram(svg, button, status, index, background) {
  button.disabled = true;
  status.textContent = "Preparing PNG…";
  try {
    const copy = svg.cloneNode(true);
    const originals = [svg, ...svg.querySelectorAll("*")];
    const copies = [copy, ...copy.querySelectorAll("*")];
    for (const [i, element] of copies.entries()) {
      const style = getComputedStyle(originals[i]);
      // SVG images do not inherit the document's typography, including HTML labels.
      for (const property of ["font-family", "font-size", "font-weight", "font-style", "color", "line-height"]) {
        element.style.setProperty(property, style.getPropertyValue(property));
      }
    }
    for (const image of copy.querySelectorAll("image, img")) {
      const href = image.getAttribute("href") || image.getAttribute("xlink:href") || image.getAttribute("src");
      if (!href || href.startsWith("data:")) continue;
      const response = await fetch(href, { mode: "cors", credentials: "omit" });
      if (!response.ok) throw new Error("An image could not be downloaded.");
      const blob = await response.blob();
      const data = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result);
        reader.onerror = () => reject(new Error("An image could not be read."));
        reader.readAsDataURL(blob);
      });
      image.removeAttribute("xlink:href");
      image.setAttribute(image.localName === "img" ? "src" : "href", data);
    }
    const { width, height } = svg.viewBox.baseVal;
    if (!(width > 0 && height > 0)) throw new Error("The diagram has no exportable size.");
    copy.setAttribute("width", width);
    copy.setAttribute("height", height);
    copy.style.width = `${width}px`;
    copy.style.height = `${height}px`;
    copy.style.maxWidth = "none";
    const image = new Image();
    // A data URL keeps SVGs containing foreignObject labels safe to read from canvas.
    image.src = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(new XMLSerializer().serializeToString(copy))}`;
    await image.decode();
    const padding = 24;
    const canvas = document.createElement("canvas");
    const fullWidth = width + padding * 2;
    const fullHeight = height + padding * 2;
    // Bound both dimensions and memory for unusually large diagrams.
    const scale = Math.min(2, 8192 / fullWidth, 8192 / fullHeight, Math.sqrt(16777216 / (fullWidth * fullHeight)));
    canvas.width = Math.max(1, Math.floor(fullWidth * scale));
    canvas.height = Math.max(1, Math.floor(fullHeight * scale));
    const context = canvas.getContext("2d");
    context.fillStyle = background;
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.scale(scale, scale);
    context.drawImage(image, padding, padding, width, height);
    const blob = await new Promise(resolve => canvas.toBlob(resolve, "image/png"));
    if (!blob) throw new Error("The browser could not create a PNG.");
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = `${document.title.replace(/[^\p{L}\p{N}._-]+/gu, "-") || "diagram"}-diagram-${index + 1}.png`;
    document.body.append(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(link.href), 1000);
    status.textContent = "PNG saved.";
  } catch (error) {
    status.textContent = `Could not save PNG: ${error.message || error} Remote images must allow cross-origin downloads.`;
  } finally {
    button.disabled = false;
  }
}

function openLightbox(container, svg, index, theme) {
  const dialog = document.createElement("dialog");
  dialog.className = "mermaid-lightbox";
  dialog.dataset.theme = theme;
  dialog.setAttribute("aria-label", `Diagram ${index + 1}, expanded`);
  dialog.innerHTML = `
    <div class="mermaid-lightbox-bar">
      <span>Diagram ${index + 1}</span>
      <button type="button" data-save>Save PNG</button>
      <button type="button" data-close autofocus aria-label="Close expanded diagram">Close <kbd>Esc</kbd></button>
    </div>
    <div class="mermaid-lightbox-canvas"></div>
    <p class="mermaid-status" role="status"></p>`;
  document.body.append(dialog);
  // Move the SVG instead of cloning IDs; leave its space in the reader intact.
  container.style.height = `${container.getBoundingClientRect().height}px`;
  dialog.querySelector(".mermaid-lightbox-canvas").append(svg);
  const close = () => {
    container.prepend(svg);
    container.style.height = "";
    dialog.close();
    dialog.remove();
    window.removeEventListener("beforeprint", close);
    container.focus({ preventScroll: true });
  };
  dialog.querySelector("[data-close]").addEventListener("click", close);
  dialog.addEventListener("cancel", event => { event.preventDefault(); close(); });
  dialog.addEventListener("keydown", event => event.stopPropagation());
  dialog.addEventListener("click", event => {
    const rect = dialog.getBoundingClientRect();
    if (event.target === dialog && (event.clientX < rect.left || event.clientX > rect.right ||
        event.clientY < rect.top || event.clientY > rect.bottom)) close();
  });
  dialog.querySelector("[data-save]").addEventListener("click", event => {
    saveDiagram(svg, event.currentTarget, dialog.querySelector(".mermaid-status"), index,
      getComputedStyle(dialog).backgroundColor);
  });
  window.addEventListener("beforeprint", close);
  dialog.showModal();
}

function addControls(container, block, index, theme) {
  const card = document.createElement("section");
  card.className = "mermaid-block";
  card.dataset.theme = theme;
  card.setAttribute("aria-label", `Mermaid diagram ${index + 1}`);
  card.innerHTML = `
    <div class="mermaid-bar">
      <span class="mermaid-caption">Mermaid</span>
      <div class="mermaid-controls" role="group" aria-label="Diagram display">
        <button type="button" data-mode="diagram" aria-pressed="true" title="Show diagram only">Diagram</button>
        <button type="button" data-mode="code" aria-pressed="false" title="Show source code only">Code</button>
        <button type="button" data-mode="both" aria-pressed="false" title="Show diagram and source code">Both</button>
        <button type="button" data-save title="Download diagram as PNG">Save PNG</button>
      </div>
    </div>`;
  container.before(card);
  block.classList.replace("mermaid", "mermaid-source");
  block.hidden = true;
  block.tabIndex = 0;
  block.setAttribute("aria-label", "Mermaid source code");
  const status = document.createElement("p");
  status.className = "mermaid-status";
  status.setAttribute("role", "status");
  card.append(container, block, status);
  const svg = container.querySelector("svg");
  container.tabIndex = 0;
  container.setAttribute("role", "button");
  container.setAttribute("aria-label", `Expand diagram ${index + 1}`);
  container.setAttribute("aria-haspopup", "dialog");
  container.title = "Click to expand";
  container.addEventListener("click", () => openLightbox(container, svg, index, theme));
  container.addEventListener("keydown", event => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      openLightbox(container, svg, index, theme);
    }
  });
  card.querySelector(".mermaid-controls").addEventListener("click", event => {
    const button = event.target.closest("button");
    if (!button) return;
    if (button.hasAttribute("data-save")) {
      saveDiagram(svg, button, status, index, getComputedStyle(card).backgroundColor);
      return;
    }
    container.hidden = button.dataset.mode === "code";
    block.hidden = button.dataset.mode === "diagram";
    for (const mode of card.querySelectorAll("[data-mode]")) {
      mode.setAttribute("aria-pressed", String(mode === button));
    }
  });
}

async function renderDiagrams() {
  let mermaid;
  let config;
  const theme = diagramTheme();
  try {
    ({ default: mermaid } = await import(
      "https://cdn.jsdelivr.net/npm/mermaid@12.0.0/dist/mermaid.esm.min.mjs"
    ));
    const embeddedBytes = Array.from(blocks).reduce((largest, block) => Math.max(
      largest, (block.dataset.mdpreviewSource?.length || 0) - block.textContent.length,
    ), 0);
    config = {
      startOnLoad: false,
      securityLevel: "strict",
      suppressErrorRendering: true,
      theme: "base",
      look: "classic",
      themeVariables: themeVariables(theme),
      fontFamily: getComputedStyle(document.body).fontFamily,
      flowchart: { look: "classic", curve: "basis", nodeSpacing: 40, rankSpacing: 52, padding: 18 },
      sequence: { look: "classic" },
      // Embedded image bytes are not diagram syntax and can exceed the default limit.
      maxTextSize: 50000 + embeddedBytes,
    };
  } catch {
    for (const block of blocks) {
      showError(block, "Mermaid could not load. Check your network connection and reload this page.");
    }
    return;
  }

  await document.fonts.ready;
  for (const [index, block] of blocks.entries()) {
    const container = document.createElement("div");
    container.className = "mermaid-diagram";
    block.before(container);
    try {
      if (block.dataset.mdpreviewError) throw new Error(block.dataset.mdpreviewError);
      mermaid.initialize(config);
      // Read textContent so escaped arrows and labels reach Mermaid unchanged.
      const { svg, bindFunctions } = await mermaid.render(
        diagramId(index), block.dataset.mdpreviewSource || block.textContent, container,
      );
      container.innerHTML = svg;
      bindFunctions?.(container);
      addControls(container, block, index, theme);
      container.dataset.rendered = "true";
      if (theme === "dark") {
        // Print events cannot await rendering. Prepare a light SVG ahead of time.
        const printed = document.createElement("div");
        printed.className = "mermaid-print";
        // Invisible, but laid out so Mermaid can measure labels and image shapes.
        printed.style.position = "absolute";
        printed.style.visibility = "hidden";
        container.append(printed);
        try {
          mermaid.initialize({ ...config, themeVariables: themeVariables("default") });
          const { svg } = await mermaid.render(
            diagramId(`${index}-print`), block.dataset.mdpreviewSource || block.textContent,
            printed,
          );
          printed.innerHTML = svg;
          printed.hidden = true;
          printed.removeAttribute("style");
          container.dataset.printReady = "true";
        } catch {
          // Keep the usable screen diagram if a print-specific render fails.
          printed.remove();
        }
      }
    } catch (error) {
      container.remove();
      showError(block, `Mermaid could not render this diagram: ${error.message || error}`);
    }
  }
}

await renderDiagrams();
