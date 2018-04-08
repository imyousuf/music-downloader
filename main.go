package main

import (
	"flag"
	"log"
	"os"
	"os/exec"

	"github.com/imyousuf/fs-image-manager/app"
	lumberjack "gopkg.in/natefinch/lumberjack.v2"
)

const (
	defaultConfigFilePath = "music-downloader.cfg"
)

func main() {
	configLoc := flag.String("config", defaultConfigFilePath, "Location of the configuration file")
	flag.Parse()
	config, confErr := app.GetConfiguration(*configLoc)
	if confErr != nil {
		log.Panic("Configuration error", confErr)
	}
	setupLogger(config)
	// youtube-dl -x --audio-format mp3 -q -o "%(id)s-%(title)s.%(ext)s" "video_url"
	cmd := exec.Command("youtube-dl", "-x", "--audio-format", "mp3", "-q", "-o",
		"%(id)s-%(title)s.%(ext)s", os.Args[1])
	err := cmd.Run()
	log.Printf("Command finished with error: %v", err)
}

func setupLogger(config app.LogConfig) {
	// FIXME: Add me through configuration
	if false {
		log.SetOutput(&lumberjack.Logger{
			Filename:   config.GetLogFilename(),
			MaxSize:    config.GetMaxLogFileSize(), // megabytes
			MaxBackups: config.GetMaxLogBackups(),
			MaxAge:     config.GetMaxAgeForALogFile(),             //days
			Compress:   config.IsCompressionEnabledOnLogBackups(), // disabled by default
		})
	}
}
