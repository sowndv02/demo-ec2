const labels = {
  machine: "Máy",
  os: "Hệ điều hành",
  architecture: "Kiến trúc",
  runtime: "Runtime",
  framework: "Framework",
  environment: "Môi trường",
  processors: "CPU",
  localPort: "Cổng",
  remoteIp: "IP client",
  uptimeSeconds: "Uptime (giây)",
  utc: "UTC"
};

const status = document.getElementById("status");
const cards = document.getElementById("cards");

async function load() {
  status.textContent = "Đang đọc thông tin máy…";
  status.className = "status";
  try {
    const response = await fetch("/api/info", { cache: "no-store" });
    if (!response.ok) throw new Error(response.statusText);
    const info = await response.json();
    cards.hidden = false;
    cards.replaceChildren(
      ...Object.keys(labels).map((key) => {
        const article = document.createElement("article");
        const name = document.createElement("span");
        const value = document.createElement("strong");
        name.textContent = labels[key];
        value.textContent = info[key] ?? "—";
        article.append(name, value);
        return article;
      })
    );
    status.textContent = "Ứng dụng phản hồi bình thường.";
    status.className = "status is-ok";
  } catch (error) {
    cards.hidden = true;
    status.textContent = "Không đọc được /api/info.";
    status.className = "status is-bad";
  }
}

document.getElementById("refresh").addEventListener("click", load);
load();
