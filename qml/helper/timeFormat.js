function formatTime(timeInSec) {
	if (!timeInSec || timeInSec <= 0) return "0:00"
	var minutes = Math.floor(timeInSec / 60)
        if (minutes > 60) var hours = Math.floor(minutes / 60)
	var seconds = Math.floor(timeInSec % 60)
	if (seconds < 10) seconds = "0" + seconds;
        if (hours >= 0) return hours + ":" + minutes + ":" + seconds
        else return minutes + ":" + seconds
}
