function check_webcam
    if test (lsof /dev/video0 | count) -gt 3
        echo "{\"text\":\"󰖠\", \"tooltip\":\"webcam is used\", \"alt\":\"Webcam\"}"
    end
end
