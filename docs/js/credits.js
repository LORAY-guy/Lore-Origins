var lorayMan = null;
var lorayUpSrc = 'img/credits/LORAY-up.gif';
var lorayIdleSrc = 'img/credits/LORAY-idle.gif';

var soundsData = null;
var cachedAudioObjects = [];

document.addEventListener('DOMContentLoaded', function() {
    lorayMan = document.getElementById('loray-man');
    
    if (!lorayMan) {
        console.error("loray-man element not found!");
        return;
    }

    loadSounds();
    startLorayDance();
    
    lorayMan.addEventListener('click', function() {
        clearTimeout(lorayMan.timeoutId);
        clearTimeout(lorayMan.idleTimeoutId);

        playRandomSound();

        lorayMan.src = lorayUpSrc + '?t=' + new Date().getTime(); // resets animation
        lorayMan.style.transform = 'translateY(-50px) scaleX(-4.0) scaleY(4.0)';
        lorayMan.style.animation = 'none';
        lorayMan.timeoutId = setTimeout(() => {
            if (lorayMan.src.includes(lorayUpSrc)) {
                lorayMan.src = lorayIdleSrc;
                lorayMan.style.transform = 'translateY(0) scaleX(-4.0) scaleY(4.0)';
                startLorayDance();
            }
        }, 500);
        
        showCredits();
    });
});

function startLorayDance()
{
    var isFlipped = false;

    function dance() {
        if (lorayMan && lorayMan.src.includes(lorayIdleSrc)) {
            isFlipped = !isFlipped;
            if (isFlipped) {
                lorayMan.style.transform = 'translateY(0) scaleX(4.0) scaleY(4.0)';
            } else {
                lorayMan.style.transform = 'translateY(0) scaleX(-4.0) scaleY(4.0)';
            }

            lorayMan.idleTimeoutId = setTimeout(dance, 400);
        }
    }

    lorayMan.idleTimeoutId = setTimeout(dance, 400);
}

// Neocities cannot host mp3 files, so little workaround
function loadSounds()
{
    fetch('sounds.json')
        .then(response => response.json())
        .then(data => {
            soundsData = data;
            precacheSounds();
        })
        .catch(error => {
            console.error('Error loading sounds:', error);
        });
}

function precacheSounds()
{
    if (!soundsData || !soundsData.sounds) {
        console.warn('No sounds data to precache');
        return;
    }
    
    soundsData.sounds.forEach((sound, index) => {
        var audio = new Audio(sound.data);
        audio.volume = 0.05;
        audio.preload = 'auto';

        audio.onerror = function() {
            console.warn('Failed to cache audio:', sound.id, sound.data);
        };
        
        cachedAudioObjects.push(audio);
    });
}

function playRandomSound()
{
    if (!cachedAudioObjects || cachedAudioObjects.length === 0) {
        console.warn('Sounds not cached yet');
        return;
    }
    
    var soundIndex = Math.floor(Math.random() * cachedAudioObjects.length);
    var audio = cachedAudioObjects[soundIndex];
    
    // Reset audio to beginning in case it was played before
    audio.currentTime = 0;
    
    audio.play().catch(function(error) {
        console.warn('Failed to play cached audio:', error);
    });
}

function showCredits()
{
    const mainBox = document.getElementById("main-box");
    const creditsBox = document.getElementById("credits-box");

    mainBox.style.opacity = "";
    mainBox.style.transform = "";
    mainBox.classList.remove("sliding-out");
    mainBox.classList.add("sliding-out");

    setTimeout(() => {
        mainBox.style.display = "none";
        creditsBox.style.display = "flex";

        creditsBox.classList.remove("sliding-in");

        setTimeout(() => {
            creditsBox.classList.add("sliding-in");
            mainBox.classList.remove("sliding-out");
            lorayMan.onclick = hideCredits;
        }, 50);
    }, 250);
}

function hideCredits()
{
    const mainBox = document.getElementById("main-box");
    const creditsBox = document.getElementById("credits-box");

    creditsBox.classList.remove("sliding-in");

    setTimeout(() => {
        creditsBox.style.display = "none";
        mainBox.style.display = "flex";

        mainBox.style.opacity = "0";
        mainBox.style.transform = "translateX(-100px) scale(0.95)";

        setTimeout(() => {
            mainBox.style.opacity = "1";
            mainBox.style.transform = "translateX(0) scale(1)";
            lorayMan.onclick = showCredits;
        }, 50);
    }, 250);
}