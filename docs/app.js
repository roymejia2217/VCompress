/**
 * VCompress Landing Page Logic
 * Fetches release data from GitHub API and renders it using Pico CSS components.
 */

const REPO_OWNER = 'roymejia2217';
const REPO_NAME = 'VCompress';
const API_URL = `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases`;

// DOM Elements
const latestReleaseCard = document.getElementById('latest-release-card');
const releaseHistoryContainer = document.getElementById('release-history');
const themeToggle = document.getElementById('themeToggle');
const themeIcon = document.getElementById('themeIcon');

/**
 * Main entry point
 */
async function init() {
    initTheme();
    try {
        const releases = await fetchReleases();
        
        if (!releases || releases.length === 0) {
            renderError('No se encontraron lanzamientos disponibles.');
            return;
        }

        // The API returns releases sorted by creation date (newest first) by default
        const latestRelease = releases[0];
        const historyReleases = releases.slice(1);

        renderLatestRelease(latestRelease);
        renderHistory(historyReleases);

    } catch (error) {
        console.error('Error initializing app:', error);
        renderError('Error al conectar con GitHub. Por favor, intenta más tarde.');
    }
}

/**
 * Initialize Theme
 */
function initTheme() {
    const savedTheme = localStorage.getItem('vcompress-theme');
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    let theme = 'light';
    if (savedTheme) {
        theme = savedTheme;
    } else if (systemPrefersDark) {
        theme = 'dark';
    }
    
    applyTheme(theme);

    themeToggle.addEventListener('click', (e) => {
        e.preventDefault();
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        applyTheme(newTheme);
    });
}

/**
 * Apply Theme
 * @param {string} theme - 'light' or 'dark'
 */
function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('vcompress-theme', theme);
    
    if (theme === 'dark') {
        themeIcon.className = 'ph ph-sun';
    } else {
        themeIcon.className = 'ph ph-moon';
    }
}

/**
 * Fetches releases from GitHub API
 * @returns {Promise<Array>} List of releases
 */
async function fetchReleases() {
    const response = await fetch(API_URL);
    if (!response.ok) {
        throw new Error(`GitHub API Error: ${response.status}`);
    }
    return await response.json();
}

/**
 * Renders the primary "Latest Release" card
 * @param {Object} release - The release object
 */
function renderLatestRelease(release) {
    // Remove loading state
    latestReleaseCard.removeAttribute('aria-busy');
    latestReleaseCard.innerHTML = ''; // Clear loading text

    // Header: Tag + Name
    const header = document.createElement('header');
    header.innerHTML = `
        <hgroup>
            <h3><i class="ph ph-rocket-launch"></i> ${release.name || release.tag_name}</h3>
            <p class="release-meta">
                <i class="ph ph-calendar"></i> ${formatDate(release.published_at)} • 
                <span data-tooltip="Etiqueta de versión"><i class="ph ph-tag"></i> ${release.tag_name}</span>
            </p>
        </hgroup>
    `;

    // Body: Release Notes (Markdown-ish content)
    const body = document.createElement('div');
    const cleanBody = (release.body || 'Sin notas de lanzamiento.').replace(/\r\n/g, '<br>');
    body.innerHTML = `<p>${cleanBody}</p>`;

    // Footer: Assets (Download Buttons)
    const footer = document.createElement('footer');
    if (release.assets && release.assets.length > 0) {
        release.assets.forEach(asset => {
            const btn = createDownloadButton(asset, true);
            footer.appendChild(btn);
        });
    } else {
        footer.innerHTML = '<small><i class="ph ph-warning"></i> No hay archivos adjuntos en este lanzamiento.</small>';
    }

    latestReleaseCard.appendChild(header);
    latestReleaseCard.appendChild(body);
    latestReleaseCard.appendChild(footer);
}

/**
 * Renders the list of older releases
 * @param {Array} releases - List of older releases
 */
function renderHistory(releases) {
    if (releases.length === 0) {
        releaseHistoryContainer.innerHTML = '<p><i class="ph ph-info"></i> No hay versiones anteriores.</p>';
        return;
    }

    releases.forEach(release => {
        const details = document.createElement('details');
        const summary = document.createElement('summary');
        
        summary.innerHTML = `<i class="ph ph-git-commit"></i> ${release.tag_name} <small>(${formatDate(release.published_at)})</small>`;
        
        const content = document.createElement('article');
        content.innerHTML = `
            <small>${(release.body || '').replace(/\r\n/g, '<br>')}</small>
            <hr>
            <h6><i class="ph ph-download-simple"></i> Descargas:</h6>
        `;

        if (release.assets && release.assets.length > 0) {
            const assetList = document.createElement('div');
            assetList.classList.add('grid');
            release.assets.forEach(asset => {
                assetList.appendChild(createDownloadButton(asset, false));
            });
            content.appendChild(assetList);
        } else {
            content.innerHTML += '<small>No disponible.</small>';
        }

        details.appendChild(summary);
        details.appendChild(content);
        releaseHistoryContainer.appendChild(details);
    });
}

/**
 * Creates a styled download button
 * @param {Object} asset - The asset object
 * @param {boolean} isPrimary - Whether it's the main CTA
 * @returns {HTMLElement} Anchor element
 */
function createDownloadButton(asset, isPrimary) {
    const a = document.createElement('a');
    a.href = asset.browser_download_url;
    a.role = 'button';
    a.target = '_blank';
    
    // Style tweaks
    if (!isPrimary) {
        a.classList.add('outline', 'secondary');
        a.style.fontSize = '0.8rem';
        a.style.padding = '0.5rem';
    } else {
        a.classList.add('download-btn');
    }

    const size = formatSize(asset.size);
    
    a.innerHTML = `<i class="ph ph-download-simple"></i> Descargar <small>(${size})</small>`;
    
    return a;
}

/**
 * Formats a date string
 * @param {string} dateString 
 * @returns {string} Formatted date
 */
function formatDate(dateString) {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(dateString).toLocaleDateString('es-ES', options);
}

/**
 * Formats bytes to MB/KB
 * @param {number} bytes 
 * @returns {string}
 */
function formatSize(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

/**
 * Renders an error message in the main card
 * @param {string} msg 
 */
function renderError(msg) {
    latestReleaseCard.removeAttribute('aria-busy');
    latestReleaseCard.innerHTML = `<div class="error-message"><i class="ph-fill ph-warning-circle"></i> ${msg}</div>`;
}

// Start app
init();