#!/usr/bin/env bash

# --------------------------------
# Totally Simple Web Server (TSWS)
# --------------------------------
#
#  (c) 2015 Dave Fletcher
#  All Rights Reserved
#
#  This is free and unencumbered software released into the public domain.
#
#  Anyone is free to copy, modify, publish, use, compile, sell, or
#  distribute this software, either in source code form or as a compiled
#  binary, for any purpose, commercial or non-commercial, and by any
#  means.
#


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
        # ${line} is empty, so we received two consecutive CRLF.
        # Process the request.
        #
        # Currently all "files" served up by the server are functions in this
        # script that return content. This shows how dynamic content can be
        # served and keeps this example all in one single file. It should be
        # easy to adapt this to also read real files from disk Hint: obf below
        # and use `file` to get content_type.
        #callback="www$(sed -e 's/\//_/g' -e 's/\./_/g' <<< "${path}")"
        #[ "${callback}" = "www_" ] && callback="www_index"
        #content_type="${callback}_Content_Type"
        #content_type="${!content_type}"
        #[ -z "${content_type}" ] && content_type="text/plain"
        status=200; msg="OK"; content_type="text/plain"
        obf="$(mktemp -u)"
        echo "${path}" >> "${obf}"
        echo "done ${path}" >> "${obf}"
        clen=$(cat "${obf}"|wc -c)



        # Show request in term.
        printf $'%s %s\n' "${method}" "${path}" >${TSWS_LOG}
        # Output headers, tee shows the response headers in term.
        printf $'HTTP/1.1 %s %s\r\n' "${status:?}" "${msg:?}" | tee ${TSWS_LOG}
        printf $'Content-Length: %s\r\n' "${clen}" | tee ${TSWS_LOG}
        printf $'Content-Type: %s\r\n' "${content_type}" | tee ${TSWS_LOG}
        printf $'Connection: close\r\n' | tee ${TSWS_LOG}
        printf $'\r\n' | tee ${TSWS_LOG}
        # Output the response data.
        cat "${obf}"
        rm "${obf}"
        echo "" > ${TSWS_LOG}  # cleanup
        method=""
      fi
    done < "$1"
  done
}



# +---------------------------------------------------------------------------+
# |                                    Main                                   |
# +---------------------------------------------------------------------------+

declare host="${1:-0.0.0.0}"
declare port="${2:-3000}"
declare -gr TSWS_LOG="/tmp/log"

tsws "${host}" "${port}"
