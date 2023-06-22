#!/usr/bin/env bash

# --------------------------------
# Totally Simple Web Server (TSWS)
# --------------------------------
#
#  (c) 2015 Dave Fletcher
#  All Rights Reserved
#  For more information, please refer to <http://unlicense.org>

# All informative console log messages are piped to here so e.g. it could be
# quieted by setting TSWS_LOG=/dev/null or alternatively logged to a file.
# The default is $(tty) which prints logs to console.
declare -r TSWS_LOG="$(tty)"

function tsws {

  local -r host="${1:-127.0.0.1}"
  local -r port="${2:-3000}"
  local -r fifo="$(mktemp -u)"

  # Initialize the FIFO pipe.
  mkfifo -m 600 "${fifo}"
  trap "rm ${fifo}" EXIT INT TERM HUP # Auto-cleanup at exit.

  # Connect _tsws_response to STDIN. Connect STDOUT to FIFO pipe. Then listen
  # on ${host}:${port}. nc -l is "listen" and -k is "listen forever".
  printf $'tsws HTTP/1.1 on %s:%s\n' "${host}" "${port}" > ${TSWS_LOG}
  nc -kl "${host}" ${port} \
    0< <(_tsws_response "${fifo}") \
    1> >(while : ; do cat - > "${fifo}"; done) # Loop keeps pipe open.
}

# -----------------------------------------------------------------------------
# _tsws_response(fifo)
# -----------------------------------------------------------------------------
#
# Internal workhorse function for handling requests and responses for tsws.
# Do not call it directly.
#
function _tsws_response {
  local method path httpvers callback content_type status msg obf clen
  method=""
  while : ; do # Run forever.
    while read -r line; do
      line="$(sed 's/\r//g' <<< "${line}")" # Replace CRLF with /n
      if [ -n "${line}" ]; then
        # ${line} is not empty, it is either a "Request-Line" or a header
        # line. If we have no 'method' yet we assume it is a Request-Line.
        # http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html
        if [ -z "${method}" ]; then
          read -r method path httpvers <<< "${line}"
          continue
        fi
        # TODO: if we cared about any of the request headers, here is the
        # place to read them by parsing ${line}.
      else
        status=200; msg="OK"; content_type="text/plain"
        printf $'%s %s\n' "${method}" "${path}" >${TSWS_LOG}
        # Output headers, tee shows the response headers in term.
        printf $'HTTP/1.1 %s %s\n' "${status:?}" "${msg:?}" | tee ${TSWS_LOG}
        printf $'Content-Type: %s\n' "${content_type}" | tee ${TSWS_LOG}
        printf $'Connection: close\n' | tee ${TSWS_LOG}
        printf $'\n' | tee ${TSWS_LOG}
        # Output the response data.
        printf "done\n\n" | tee ${TSWS_LOG}
        method=""
      fi
    done < "$1"
  done
}

# +---------------------------------------------------------------------------+
# |                                    Main                                   |
# +---------------------------------------------------------------------------+

declare host="${1:-127.0.0.1}"
declare port="${2:-3000}"
tsws "${host}" "${port}"
