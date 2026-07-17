// --- Smart Campus Complaint Portal Javascript ---

document.addEventListener("DOMContentLoaded", () => {
    // 1. Theme Switcher (Dark/Light Mode)
    initTheme();

    // 2. Notifications System (AJAX Poll & Display)
    initNotifications();



    // 4. Drag & Drop File Upload Preview
    initDragAndDrop();

    // 5. Setup sidebar responsive toggle
    initSidebarToggle();
});

// Theme Switcher Logic
function initTheme() {
    const toggleBtn = document.querySelector(".theme-toggle-btn");
    if (!toggleBtn) return;

    const currentTheme = localStorage.getItem("theme") || "light";
    document.documentElement.setAttribute("data-theme", currentTheme);
    updateThemeIcon(toggleBtn, currentTheme);

    toggleBtn.addEventListener("click", () => {
        let theme = document.documentElement.getAttribute("data-theme");
        let newTheme = theme === "dark" ? "light" : "dark";
        document.documentElement.setAttribute("data-theme", newTheme);
        localStorage.setItem("theme", newTheme);
        updateThemeIcon(toggleBtn, newTheme);
    });
}

function updateThemeIcon(btn, theme) {
    const icon = btn.querySelector("i");
    if (!icon) return;
    if (theme === "dark") {
        icon.className = "bi bi-sun-fill";
    } else {
        icon.className = "bi bi-moon-stars-fill";
    }
}

// Notifications AJAX Logic
function initNotifications() {
    const bellBtn = document.querySelector(".notification-bell-btn");
    const dropdown = document.querySelector(".notifications-dropdown");
    const markReadBtn = document.querySelector(".mark-read-btn");
    
    if (!bellBtn || !dropdown) return;

    // Toggle dropdown
    bellBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        dropdown.style.display = dropdown.style.display === "block" ? "none" : "block";
    });

    // Close dropdown on click outside
    document.addEventListener("click", () => {
        dropdown.style.display = "none";
    });

    dropdown.addEventListener("click", (e) => {
        e.stopPropagation();
    });

    // Fetch notifications
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/", 2)) || "";
    const fetchUrl = contextPath + "/notifications";

    function loadNotifications() {
        fetch(fetchUrl)
            .then(res => {
                if (res.status === 401) return []; // Unauthorized
                return res.json();
            })
            .then(data => {
                const countBadge = bellBtn.querySelector(".badge-count");
                const list = dropdown.querySelector(".notifications-list");
                
                if (!list) return;

                if (data.length > 0) {
                    if (countBadge) {
                        countBadge.textContent = data.length;
                        countBadge.style.display = "flex";
                    }
                    
                    list.innerHTML = "";
                    data.forEach(n => {
                        const item = document.createElement("div");
                        item.className = "notification-item";
                        item.innerHTML = `
                            <div>${n.message}</div>
                            <span class="notification-item-time">${formatDate(n.createdAt)}</span>
                        `;
                        list.appendChild(item);
                    });
                } else {
                    if (countBadge) countBadge.style.display = "none";
                    list.innerHTML = `<div class="notification-empty">No new notifications</div>`;
                }
            })
            .catch(err => console.error("Error fetching notifications:", err));
    }

    // Mark as read
    if (markReadBtn) {
        markReadBtn.addEventListener("click", () => {
            fetch(fetchUrl, { method: "POST" })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        loadNotifications();
                    }
                })
                .catch(err => console.error("Error marking read:", err));
        });
    }

    // Initial load and poll every 30 seconds
    loadNotifications();
    setInterval(loadNotifications, 30000);
}



// Drag and Drop Logic for File Upload Previews
function initDragAndDrop() {
    const uploadZone = document.getElementById("upload-zone");
    const fileInput = document.getElementById("images");
    const previewGrid = document.querySelector(".image-preview-grid");

    if (!uploadZone || !fileInput) return;

    // Click triggers input click
    uploadZone.addEventListener("click", () => {
        fileInput.click();
    });

    // Hover animations
    ["dragover", "dragenter"].forEach(eventName => {
        uploadZone.addEventListener(eventName, (e) => {
            e.preventDefault();
            uploadZone.classList.add("dragover");
        }, false);
    });

    ["dragleave", "drop"].forEach(eventName => {
        uploadZone.addEventListener(eventName, (e) => {
            e.preventDefault();
            uploadZone.classList.remove("dragover");
        }, false);
    });

    // Handle dropped files
    uploadZone.addEventListener("drop", (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        fileInput.files = files;
        handleFilePreviews(files);
    });

    // Handle input change files
    fileInput.addEventListener("change", (e) => {
        handleFilePreviews(fileInput.files);
    });

    function handleFilePreviews(files) {
        if (!previewGrid) return;
        previewGrid.innerHTML = "";

        if (files.length === 0) {
            previewGrid.style.display = "none";
            return;
        }

        previewGrid.style.display = "grid";
        Array.from(files).forEach(file => {
            if (!file.type.startsWith("image/")) return;

            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onloadend = () => {
                const card = document.createElement("div");
                card.className = "image-preview-card";
                card.innerHTML = `<img src="${reader.result}" alt="${file.name}" />`;
                previewGrid.appendChild(card);
            };
        });
    }
}

// Sidebar responsive toggle
function initSidebarToggle() {
    const toggle = document.querySelector(".sidebar-responsive-toggle");
    const sidebar = document.querySelector(".sidebar");
    if (!toggle || !sidebar) return;

    toggle.addEventListener("click", (e) => {
        e.stopPropagation();
        sidebar.classList.toggle("show");
    });

    document.addEventListener("click", () => {
        sidebar.classList.remove("show");
    });

    sidebar.addEventListener("click", (e) => {
        e.stopPropagation();
    });
}

// Helper date formatter
function formatDate(timestampStr) {
    if (!timestampStr) return "";
    try {
        const date = new Date(timestampStr);
        return date.toLocaleDateString(undefined, {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    } catch (e) {
        return timestampStr;
    }
}
