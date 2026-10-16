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
      theme,
      fontFamily: getComputedStyle(document.body).fontFamily,
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
    container.style.overflowX = "auto";
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
      block.remove();
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
          mermaid.initialize({ ...config, theme: "default" });
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
