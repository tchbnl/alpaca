alpaca() {
TEXT_BOLD="\e[1m"
TEXT_RESET="\e[0m"
show_help() {
echo -e "${TEXT_BOLD}alpaca${TEXT_RESET} shows useful Apache stats about sites.

USAGE: alpaca [DOMAIN]
    DOMAIN              Domain to fetch stats for.
    -h --help           Show this message and exit.
    -v --version        Show version information and exit."
}
VERSION="${TEXT_BOLD}alpaca${TEXT_RESET} v0.1 (Updated 6/11/23)"
DOMLOGS="/usr/local/apache/domlogs"
fetch_stuff() {
LOGFILE="$(find "${DOMLOGS}" -type f -iname "${1}.log")"
if [[ -z "${LOGFILE}" ]]; then
echo "No logs found for $(echo "${1}" | awk '{print tolower($0)}') under ${DOMLOGS}"
return
else
echo "Fetching stats for $(echo "${1}" | awk '{print tolower($0)}')..."
echo -e "Log: ${LOGFILE}\n"
fi
LOGFILE="$(awk -v TIME="$(date -d '24 hours ago' '+%d/%b/%Y:%H')" '$4 > TIME {print}' "${LOGFILE}")"
DAYS="$(echo "${LOGFILE}" | awk -F '[:[]' '{print $2}' | sort | uniq)"
for DAY in ${DAYS}; do
HITS="$(echo "${LOGFILE}" | grep -i "${DAY}" | awk -F ':' '{print $2}' | sort | uniq -c)"
echo -e "🎯 ${TEXT_BOLD}Hits (${DAY}):${TEXT_RESET}"
printf "%5s" ""
echo "${HITS}" | while read -r COUNT HOUR; do
printf "%s: %s " "${HOUR}" "${COUNT}"
done
echo
echo
done
echo -e "💬 ${TEXT_BOLD}Responses:${TEXT_RESET}"
TOP_RESPONSES="$(echo "${LOGFILE}" | awk -F '[" ]' '{print $11}' | sort | uniq -c | sort -rn | head -n 10)"
printf "%5s" ""
echo "${TOP_RESPONSES}" | while read -r COUNT RESPONSE; do
printf "%s: %s " "${RESPONSE}" "${COUNT}"
done
echo
echo -e "\n🔗 ${TEXT_BOLD}URIs:${TEXT_RESET}"
TOP_URIS="$(echo "${LOGFILE}" | awk -F '[" ]|(HTTP)' '{print $12 " " $8 " " $7}' | sort | uniq -c | sort -rn | head -n 10)"
echo "${TOP_URIS}" | while read -r COUNT RESPONSE URI KIND; do
COUNT_WIDTH="$(echo "${TOP_URIS}" | awk '{print length($1)}' | sort -nr | head -n 1)"
KIND_WIDTH="$(echo "${TOP_URIS}" | awk '{print length($4)}' | sort -nr | head -n 1)"
printf "%5s%*s %s %*s %s\n" "" "${COUNT_WIDTH}" "${COUNT}" "${RESPONSE}" "${KIND_WIDTH}" "${KIND}" "${URI}"
done
echo -e "\n🧔 ${TEXT_BOLD}User Agents:${TEXT_RESET}"
TOP_UAS="$(echo "${LOGFILE}" | awk -F '"' '{print "\"" $6 "\""}' | sort | uniq -c | sort -rn | head -n 10)"
echo "${TOP_UAS}" | while read -r COUNT UA; do
COUNT_WIDTH="$(echo "${TOP_UAS}" | awk '{print length($1)}' | sort -nr | head -n 1)"
printf "%5s%*s %s\n" "" "${COUNT_WIDTH}" "${COUNT}" "${UA}"
done
echo -e "\n🌐 ${TEXT_BOLD}IPs:${TEXT_RESET}"
TOP_IPS="$(echo "${LOGFILE}" | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10)"
echo "${TOP_IPS}" | while read -r COUNT IP; do
COUNT_WIDTH="$(echo "${TOP_IPS}" | awk '{print length($1)}' | sort -nr | head -n 1)"
IP_WIDTH="$(echo "${TOP_IPS}" | awk '{print length($2)}' | sort -nr | head -n 1)"
if [[ -z "$(dig +short -x "${IP}")" ]]; then
PTR="No PTR record found"
else
PTR="$(dig +short -x "${IP}" | sed 's/\.$//')"
fi
printf "%5s%*s %-*s %s\n" "" "${COUNT_WIDTH}" "${COUNT}" "${IP_WIDTH}" "${IP}" "${PTR}"
done
}
while [[ "${#}" -gt 0 ]]; do
case "${1}" in
-h|--help)
show_help
return
;;
-v|--version)
echo -e "${VERSION}"
return
;;
-*)
echo -e "Not sure what '${1}' is supposed to be.\n"
show_help
return
;;
*)
fetch_stuff "${@}"
return
;;
esac
done
if [[ "${#}" -lt 1 ]]; then
show_help
else
fetch_stuff "${@}"
fi
}
