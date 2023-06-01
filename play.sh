#!/bin/bash

# Values associated with FFMPEG calling mode
ff_logLevel="fatal"             # {quiet|panic|fatal|error|warning|info|verbose|debug|trace}
ff_threads=2                    # Threads to use for encoding
ff_serviceName="No_Client"      # Name of the service (Usually client name)
ff_providerName="No_Provider"   # Name of the provider (Usually TNSChile)
ff_packetsize=1316              # Size of the packets to send

# Values associated with tsplay calling mode
ts_enable=0     # Enable TSPLAY mode

destination=""  # Destination IP address and port
video=""        # Path to the video file

# Function to show script usage
showUsage() {
    echo -e "\nUsage: $0 [-l <logLevel>] [-t <threads>] [-s <serviceName>] [-p <providerName>] [-z <packetSize>] <destination> <video>\n"
    echo "  -l  [ffmpeg only] Log level (quiet|panic|fatal|error|warning|info|verbose|debug|trace)"
    echo "  -t  [ffmpeg only] Number of threads to use for encoding (1-4)"
    echo "  -s  [ffmpeg only] Name of the service (Usually client name)"
    echo "  -p  [ffmpeg only] Name of the provider"
    echo "  -z  [ffmpeg only] Size of the packets to send"
    echo "  --tsplay  Use TSPLAY instead of FFMPEG"
    echo "  <destination>  Destination IP address and port (IP:PORT)"
    echo -e "  <video>  Path to the video file\n"
}

# Check if sufficient arguments were provided
if [[ $# -lt 2 ]]; then
    showUsage
    exit 1
fi

# Read command line argument flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -l)
            shift
            ff_logLevel="$1"
            ;;
        -t)
            shift
            # Check if Threads is numeric
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                # Check if Threads is below 4
                if [[ "$1" -le 4 ]]; then
                    ff_threads="$1"
                else
                    echo "The value for -t must be less or equal than 4."
                    showUsage
                    exit 1
                fi
            else
                echo "The value for -t must be numeric."
                showUsage
                exit 1
            fi
            ;;
        -s)
            shift
            ff_serviceName="$1"
            ;;
        -p)
            shift
            ff_providerName="$1"
            ;;
        -z)
            shift
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                # Check if Packet Size is below 1500
                if [[ "$1" -le 1500 ]]; then
                    ff_packetsize="$1"
                else
                    echo "The value for -z must be less or equal than 1500."
                    showUsage
                    exit 1
                fi
            else
                echo "The value for -z must be numeric."
                showUsage
                exit 1
            fi
            ;;
        --tsplay)
            ts_enable=1
            ;;
        *)
            if [[ -z "$destination" ]]; then
                destination="$1"
            elif [[ -z "$video" ]]; then
                video="$1"
            else
                echo "Too many arguments."
                showUsage
                exit 1
            fi
            ;;
    esac
    shift
done

# Verify if destination and video are not empty
if [[ -z "$destination" ]]; then
    echo "You must provide a destination IP address and port."
    showUsage
    exit 1
fi
if [[ -z "$video" ]]; then
    echo "You must provide a path to a video file."
    showUsage
    exit 1
fi

# Check if destination is valid
if [[ ! "$destination" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
    echo "The destination IP address and port is not valid."
    showUsage
    exit 1
fi

# Check if video file exists
if [[ ! -f "$video" ]]; then
    echo "The video file does not exist."
    showUsage
    exit 1
fi


if [[ $ts_enable -eq 0 ]]; then # Streaming using FFMPEG
    echo "Streaming video using FFMPEG with the following values:"
    echo "Log Level: $ff_logLevel"
    echo "Threads: $ff_threads"
    echo "Service Name: $ff_serviceName"
    echo "Provider Name: $ff_providerName"
    echo "Packet Size: $ff_packetsize"
    echo "Destination: $destination"
    echo "Video: $video"

    ffmpeg -loglevel $ff_logLevel -threads $ff_threads -re -fflags +genpts -stream_loop -1 -i $video -c:v copy -bsf:v h264_mp4toannexb -c:a copy -metadata service_name=$ff_serviceName -metadata service_provider=$ff_providerName -max_interleave_delta 0 -use_wallclock_as_timestamps 1 -flush_packets 1 -f mpegts udp://$destination?pkt_size=$ff_packetsize
else # Streaming using TSPLAY
    echo "Streaming video using TSPLAY with the following values:"
    echo "Destination: $destination"
    echo "Video: $video"

    tsplay -loop -1 -i $video -o udp://$destination
fi