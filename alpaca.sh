#!/bin/bash
# alpaca - Get handy Apache stats about a site
# Nathan Paton <me@tchbnl.com>
# v0.1 (Updated 6/13/2023)

# Nice text formatting
TEXT_BOLD="\e[1m"
TEXT_RESET="\e[0m"

# Help message
show_help() {
    echo -e "${TEXT_BOLD}alpaca${TEXT_RESET} shows useful Apache stats about sites.

USAGE: alpaca [DOMAIN]
    DOMAIN              Domain to fetch stats for.

    -h --help           Show this message and exit.
    -v --version        Show version information and exit."
}

# Version information
VERSION="${TEXT_BOLD}alpaca${TEXT_RESET} v0.1 (Updated 6/13/23)"

# Path to Apache domlogs
DOMLOGS="/usr/local/apache/domlogs"

fetch_stuff() {
    # Let's look for the log file we need
    # This assumes a combined access log. Adapt if you need something else.
    # TODO: Add support for calling a log directly?
    LOGFILE="$(find "${DOMLOGS}" -type f -iname "${1}.log")"

    # Check if we can find a domlog for the domain and bail if we can't
    if [[ -z "${LOGFILE}" ]]; then
        echo "No logs found for $(echo "${1}" | awk '{print tolower($0)}') under ${DOMLOGS}"
        exit
    else
        echo "Fetching stats for $(echo "${1}" | awk '{print tolower($0)}')..."
        echo -e "Log: ${LOGFILE}\n"
    fi

    # And now we do a swaperoo to a 24-hour window of this log
    # TODO: Add support for specifying a different range
    # TODO: Also add handling if for some reason this is totally empty
    # TODO: Equal column spacing
    LOGFILE="$(awk -v TIME="$(date -d '24 hours ago' '+%d/%b/%Y:%H')" -F '[:[]' '$2 ":" $3 > TIME {print}' "${LOGFILE}")"

    # Request totals for each hour
    # First we'll split this log further into days (trust me on this):
    DAYS="$(echo "${LOGFILE}" | awk -F '[:[]' '{print $2}' | sort | uniq)"

    # And then we do a for loop for each day...
    for DAY in ${DAYS}; do
        # Count the hits per hour for the day
        HITS="$(echo "${LOGFILE}" | grep -i "${DAY}" | awk -F ':' '{print $2}' | sort | uniq -c)"

        # Make it all look nice
        echo -e "🎯 ${TEXT_BOLD}Hits (${DAY}):${TEXT_RESET}"

        # More hackery to make the output align nicely
        printf "%5s" ""

        # We want to insert a new line after the 12th hour in the loop below
        HOURS="0"

        # And tada. We then do a while loop to output the hour and count side-by-side.
        # TODO: Find a way to wrap this
        echo "${HITS}" | while read -r COUNT HOUR; do
            printf "%s: %s  " "${HOUR}" "${COUNT}"

            # Increment our HOURS...
            ((HOURS++))

            # And break to a new line if we've reached the 12th
            if [[ "${HOURS}" -eq 12 ]]; then
                printf "\n%5s" ""

                # And start over
                HOURS="0"
            fi
        done

        # And this is just to add some nice spacing
        echo
        echo
    done

    # Top 10 response codes (are there even enough for 10?)
    # Looks like:
    # 200: 429 404: 30 503: 11 etc.
    # TODO: Equal column spacing
    echo -e "💬 ${TEXT_BOLD}Responses:${TEXT_RESET}"
    TOP_RESPONSES="$(echo "${LOGFILE}" | awk -F '[" ]' '{print $11}' | sort | uniq -c | sort -rn | head -n 10)"

    printf "%5s" ""

    echo "${TOP_RESPONSES}" | while read -r COUNT RESPONSE; do
        printf "%s: %s  " "${RESPONSE}" "${COUNT}"
    done

    echo

    # Top 10 URIs with response code
    echo -e "\n🔗 ${TEXT_BOLD}URIs:${TEXT_RESET}"
    # This looks weird, but it's basically:
    # 42 200 GET /elmosocks.html
    # I learned a lot about awk regex for this script
    TOP_URIS="$(echo "${LOGFILE}" | awk -F '[" ]|(HTTP)' '{print $12 " " $8 " " $7}' | sort | uniq -c | sort -rn | head -n 10)"

    echo "${TOP_URIS}" | while read -r COUNT RESPONSE URI KIND; do
        # What's this? It's a little hack to make all the columns nicely spaced.
        # We get the lengths of the longest count number and request type and
        # use printf to make it all align and look nice.
        # This is actually the first time I ever used printf besides by accident
        COUNT_WIDTH="$(echo "${TOP_URIS}" | awk '{print length($1)}' | sort -nr | head -n 1)"
        KIND_WIDTH="$(echo "${TOP_URIS}" | awk '{print length($4)}' | sort -nr | head -n 1)"

        printf "%5s%*s  %s  %*s  %s\n" "" "${COUNT_WIDTH}" "${COUNT}" "${RESPONSE}" "${KIND_WIDTH}" "${KIND}" "${URI}"
    done

    # Top 10 user agents
    # Looks like:
    # 10 "Mozilla/3.0 (compatible; NetPositive/2.1.1; BeOS)"
    echo -e "\n🧔 ${TEXT_BOLD}User Agents:${TEXT_RESET}"
    TOP_UAS="$(echo "${LOGFILE}" | awk -F '"' '{print "\"" $6 "\""}' | sort | uniq -c | sort -rn | head -n 10)"

    echo "${TOP_UAS}" | while read -r COUNT UA; do
        COUNT_WIDTH="$(echo "${TOP_UAS}" | awk '{print length($1)}' | sort -nr | head -n 1)"

        printf "%5s%*s  %s\n" "" "${COUNT_WIDTH}" "${COUNT}" "${UA}"
    done

    # Top 10 anime betrayal- I mean IPs and their PTR records
    # Looks like:
    # 37 42.180.22.7 nicereversedns.name.here
    echo -e "\n🌐 ${TEXT_BOLD}IPs:${TEXT_RESET}"

    TOP_IPS="$(echo "${LOGFILE}" | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10)"

    echo "${TOP_IPS}" | while read -r COUNT IP; do
        COUNT_WIDTH="$(echo "${TOP_IPS}" | awk '{print length($1)}' | sort -nr | head -n 1)"
        IP_WIDTH="$(echo "${TOP_IPS}" | awk '{print length($2)}' | sort -nr | head -n 1)"

        # We want to show the PTR next to the IP, but also want it to look nice
        # If dig returns no output, we set this instead for the IP
        if [[ -z "$(dig +short -x "${IP}")" ]]; then
            PTR="No PTR record found"
        else
            PTR="$(dig +short -x "${IP}" | sed 's/\.$//')"
        fi

        printf "%5s%*s  %-*s  %s\n" "" "${COUNT_WIDTH}" "${COUNT}" "${IP_WIDTH}" "${IP}" "${PTR}"
    done
}

# Command line options
while [[ "${#}" -gt 0 ]]; do
    case "${1}" in
        -h|--help)
            show_help
            exit
            ;;

        -v|--version)
            echo -e "${VERSION}"
            exit
            ;;

        -*)
            echo -e "Not sure what '${1}' is supposed to be.\n"
            show_help
            exit
            ;;

        *)
            fetch_stuff "${@}"
            exit
            ;;
    esac
done

# alpaca requires an argument to be useful
if [[ "${#}" -lt 1 ]]; then
    show_help
else
    fetch_stuff "${@}"
fi
