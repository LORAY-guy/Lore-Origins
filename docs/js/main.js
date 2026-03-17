window.isMobile = function()
{
    const hasTouch = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    const noHover = window.matchMedia("(any-hover:none)").matches;
    const userAgent = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile/i.test(navigator.userAgent);
    
    // Specific iOS detection that Chrome can't fake
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) || 
                  (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1) ||
                  (window.DeviceMotionEvent && 'ontouchstart' in window && navigator.maxTouchPoints > 0);

    const isChromeIOS = /CriOS/.test(navigator.userAgent) || 
                        (navigator.userAgent.includes('Chrome') && isIOS);
    
    const mobileScreenSize = window.innerWidth <= 768 || window.innerHeight <= 1024;
    const touchAndSmall = hasTouch && mobileScreenSize;
    
    return hasTouch || noHover || userAgent || isIOS || isChromeIOS || touchAndSmall;
};

document.addEventListener("DOMContentLoaded", () => {
    const playButton = document.getElementById("play-button");
    
    if (window.isMobile() || /iPhone|iPad|iPod|Android|Mobile/i.test(navigator.userAgent)) {
        playButton.textContent = "MOBILE NOT SUPPORTED";
        playButton.style.backgroundColor = "#ff4444";
        playButton.style.cursor = "not-allowed";
        playButton.style.opacity = "0.7";
        playButton.style.transition = "none";
        playButton.style.transform = "none";
        playButton.style.pointerEvents = "auto";

        playButton.addEventListener('mouseenter', function(e) {
            e.preventDefault();
        });
        
        playButton.addEventListener('mouseleave', function(e) {
            e.preventDefault();
        });
        
        playButton.onclick = function() {
            alert("Sorry! This game requires a desktop computer with keyboard controls. Please visit this page from a Windows, macOS, or Linux computer to play.");
        };
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

function isFirefoxBrowser()
{
    return /Firefox/i.test(navigator.userAgent);
}

function getGameUrl(isWidescreen = false)
{
    if (isWidescreen) {
        return "https://html-classic.itch.zone/html/16838032/index.html";
    }

    return "https://html-classic.itch.zone/html/16838017/index.html";
}

function startGame(isWidescreen = false)
{
    const startScreen = document.getElementById("start-screen");
    const gameContainer = document.getElementById("game-container");
    const fullscreenButton = document.getElementById("fullscreen-button");

    if (window.isMobile() || /iPhone|iPad|iPod|Android|Mobile/i.test(navigator.userAgent)) {
        console.warn("Game start blocked: Mobile device detected");
        alert("❌ Mobile devices are not supported! Please use a desktop computer.");
        return;
    }

    if (isFirefoxBrowser()) {
        const gameUrl = getGameUrl(isWidescreen);
        window.open(gameUrl, "_blank", "noopener,noreferrer");
        alert("Firefox blocks embedded itch.io pages. The game has been opened in a new tab.");
        return;
    }

    startScreen.style.display = "none";
    gameContainer.style.display = "flex";
    fullscreenButton.style.display = "block";

    createGameIframe(isWidescreen);
}

function downloadGame()
{
    window.open("https://gamebanana.com/mods/476070", "_blank");
}

function viewPatchNotes()
{
    window.location.href = "patch-notes.html";
}

function createGameIframe(isWidescreen = false)
{
    if (window.isMobile()) {
        console.warn("Iframe creation blocked: Mobile device detected");
        return;
    }
    
    const gameContainer = document.getElementById("game-container");
    const iframe = document.createElement("iframe");
    
    iframe.id = "game_drop";
    iframe.allowFullscreen = true;
    iframe.allow = "fullscreen *; web-share";
    iframe.allowTransparency = true;
    iframe.mozallowfullscreen = true;
    iframe.msallowfullscreen = true;
    iframe.webkitallowfullscreen = true;
    iframe.src = getGameUrl(isWidescreen);

    function setIframeDimensions(isWidescreen = false) {
        const mainBox = document.getElementById("main-box");
        const mainBoxRect = mainBox.getBoundingClientRect();
        const mainBoxWidth = mainBoxRect.width;
        const availableWidth = mainBoxWidth - 40;
        const actualWidth = isWidescreen ? 1920 : 1280;
        
        if (window.innerWidth <= 768) {
            iframe.style.width = "100%";
            iframe.style.height = Math.min(window.innerWidth * 0.5625, 400) + "px";
        } else {
            const maxWidth = Math.min(actualWidth, availableWidth);
            const maxHeight = maxWidth * (9/16);
            
            iframe.style.width = maxWidth + "px";
            iframe.style.height = maxHeight + "px";
        }
    }

    setIframeDimensions(isWidescreen);
    
    iframe.style.borderRadius = "16px";
    iframe.style.border = "none";
    iframe.style.marginTop = "10px";
    iframe.style.marginBottom = "5px";

    gameContainer.appendChild(iframe);

    window.addEventListener('resize', setIframeDimensions);

    if (window.visualViewport) {
        window.visualViewport.addEventListener('resize', setIframeDimensions);
    }
}

if (window.visualViewport) {
    window.visualViewport.addEventListener('resize', () => {
        // if zoom >= 150% && zoom < 80%, hide the man
        const lorayMan = document.getElementById("loray-man");
        if (lorayMan) {
            lorayMan.style.display = ((window.screen.width < 1280 || window.screen.width > 2560) ? "none" : "block");
        }
    });
}