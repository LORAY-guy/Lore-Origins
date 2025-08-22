const isDesktop = isDesktopPlatform();

document.addEventListener("DOMContentLoaded", () => {
    const startScreen = document.getElementById("start-screen");
    const unsupportedMessage = document.getElementById("unsupported-message");

    if (!isDesktop) {
        startScreen.style.display = "none";
        unsupportedMessage.style.display = "block";
    }
});

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

function startGame()
{
    const startScreen = document.getElementById("start-screen");
    const gameContainer = document.getElementById("game-container");
    const fullscreenButton = document.getElementById("fullscreen-button");

    if (isDesktop) {
        startScreen.style.display = "none";
        gameContainer.style.display = "flex";
        fullscreenButton.style.display = "block";

        createGameIframe();
    }
}

function downloadGame()
{
    window.open("https://gamebanana.com/mods/476070", "_blank");
}

function createGameIframe()
{
    const gameContainer = document.getElementById("game-container");
    const iframe = document.createElement("iframe");
    
    iframe.id = "game_drop";
    iframe.allowFullscreen = true;
    iframe.allow = "fullscreen *; web-share";
    iframe.allowTransparency = true;
    iframe.mozallowfullscreen = true;
    iframe.msallowfullscreen = true;
    iframe.webkitallowfullscreen = true;
    iframe.src = "https://html-classic.itch.zone/html/14742211/index.html";
    iframe.style.width = "1280px";
    iframe.style.height = "720px";
    iframe.style.borderRadius = "16px";
    iframe.style.border = "none";
    iframe.style.marginTop = "10px";
    iframe.style.marginBottom = "5px";

    gameContainer.appendChild(iframe);
}

function isDesktopPlatform()
{
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