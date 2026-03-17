function goBack()
{
    window.location.href = 'index.html';
}

async function loadPatchNotes()
{
    const container = document.getElementById('patch-notes-container');
    const loading = document.getElementById('loading');
    
    try {
        const response = await fetch('patch-notes.json');

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        loading.style.display = 'none';

        const patchNotesHTML = createPatchNotesHTML(data.patches);
        container.innerHTML = patchNotesHTML;
        
    } catch (error) {
        console.error('Error loading patch notes:', error);
        container.innerHTML = `
            <div class="error-message">
                ❌ Failed to load patch notes. Please try again later.
                <br><small>Error: ${error.message}</small>
            </div>
        `;
    }
}

function createPatchNotesHTML(patches)
{
    if (!patches || patches.length === 0) {
        return '<div class="error-message">No patch notes available.</div>';
    }

    return patches.map(patch => {
        const changesHTML = patch.changes.map(change => `
            <li class="change-item">
                <span class="change-type ${change.type}">${change.type}</span>
                <span class="change-description">${escapeHtml(change.description)}</span>
            </li>
        `).join('');
        
        return `
            <div class="patch-entry">
                <div class="patch-header">
                    <h2 class="patch-version">v${escapeHtml(patch.version)}</h2>
                    <span class="patch-date">${formatDate(patch.date)}</span>
                </div>
                <h3 class="patch-title">${escapeHtml(patch.title)}</h3>
                <ul class="changes-list">
                    ${changesHTML}
                </ul>
            </div>
        `;
    }).join('');
}

function formatDate(dateString)
{
    try {
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    } catch (error) {
        return dateString;
    }
}

function escapeHtml(text)
{
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

document.addEventListener("DOMContentLoaded", () => {
    loadPatchNotes();

    const container = document.getElementById('patch-notes-container');
    if (container) {
        container.style.scrollBehavior = 'smooth';
    }
});
