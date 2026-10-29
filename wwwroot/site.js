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

const dbLabels = {
  connected: "Kết nối",
  database: "Database",
  serverAddress: "Địa chỉ RDS",
  version: "PostgreSQL",
  pingCount: "Số lần ghi",
  message: "Chi tiết"
};

const dbStatus = document.getElementById("db-status");
const dbCards = document.getElementById("db-cards");

function renderCards(target, labels, info) {
  target.hidden = false;
  target.replaceChildren(
    ...Object.keys(labels)
      .filter((key) => info[key] !== undefined && info[key] !== null && info[key] !== "")
      .map((key) => {
        const article = document.createElement("article");
        const name = document.createElement("span");
        const value = document.createElement("strong");
        name.textContent = labels[key];
        value.textContent = info[key];
        article.append(name, value);
        return article;
      })
  );
}

async function loadDb() {
  dbStatus.textContent = "Đang kiểm tra PostgreSQL…";
  dbStatus.className = "status";
  try {
    const response = await fetch("/api/db", { cache: "no-store" });
    if (!response.ok) throw new Error(response.statusText);
    const info = await response.json();
    renderCards(dbCards, dbLabels, {
      ...info,
      connected: info.connected ? "Được" : "Không"
    });
    dbStatus.textContent = info.connected
      ? "EC2 đã ghi một dòng vào RDS."
      : "Chưa kết nối được RDS.";
    dbStatus.className = info.connected ? "status is-ok" : "status is-bad";
  } catch (error) {
    dbCards.hidden = true;
    dbStatus.textContent = "Không đọc được /api/db.";
    dbStatus.className = "status is-bad";
  }
}

document.getElementById("refresh").addEventListener("click", () => {
  load();
  loadDb();
});
load();
loadDb();
