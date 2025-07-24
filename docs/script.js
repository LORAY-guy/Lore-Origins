function toggleFullscreen()
{
    const iframe = document.getElementById("game_drop");

    if (iframe && iframe.requestFullscreen) {
        iframe.requestFullscreen();
    } else if (iframe && iframe.webkitRequestFullscreen) {
        iframe.webkitRequestFullscreen();
    } else if (iframe && iframe.mozRequestFullScreen) {
        iframe.mozRequestFullScreen();
    } else if (iframe && iframe.msRequestFullscreen) {
        iframe.msRequestFullscreen();
    }
}

document.addEventListener("DOMContentLoaded", () => {
    const gameContainer = document.getElementById("game-container");
    const unsupportedMessage = document.getElementById("unsupported-message");
    const mainBox = document.getElementById("main-box");
    const toggleFullscreenButton = document.getElementById("fullscreen-button");

    function createGameIframe() {
        const iframe = document.createElement("iframe");
        iframe.id = "game_drop";
        iframe.allowFullscreen = true;
        iframe.allow = "fullscreen *; web-share";
        iframe.allowTransparency = true;
        iframe.mozallowfullscreen = true;
        iframe.msallowfullscreen = true;
        iframe.webkitallowfullscreen = true;
        iframe.src = "https://html-classic.itch.zone/html/14394340/index.html";
        iframe.style.width = "1280px";
        iframe.style.height = "720px";
        iframe.style.borderRadius = "16px";
        iframe.style.border = "none";
        iframe.style.marginTop = "20px";
        gameContainer.appendChild(iframe);
    }

    function isDesktopPlatform() {
        if (navigator.userAgentData) {
            return navigator.userAgentData.getHighEntropyValues(["platform"]).then(ua => {
                const platform = ua.platform.toLowerCase();
                return platform.includes("windows") || platform.includes("mac") || platform.includes("linux");
            });
        } else {
            const ua = navigator.userAgent.toLowerCase();
            return Promise.resolve(
                ua.includes("windows") || ua.includes("macintosh") || ua.includes("linux") || ua.includes("x11")
            );
        }
    }

    isDesktopPlatform().then(isDesktop => {
        if (isDesktop) {
            createGameIframe();
        } else {
            unsupportedMessage.style.display = "block";
            toggleFullscreenButton.style.display = "none";
            mainBox.style.height = "240px";
        }
    });
});