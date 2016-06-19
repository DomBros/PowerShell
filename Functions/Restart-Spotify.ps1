# Restart Spotify
Function Restart-Spotify {
    Get-Process *spotify | Stop-Process
    Start "C:\Users\j.van.ravensberg\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Spotify.lnk"
    exit
}
