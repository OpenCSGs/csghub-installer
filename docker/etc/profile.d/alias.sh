csghub-ctl() {
    case "$1" in
        status)
            command supervisorctl status | grep -v -w init-job
            ;;
        jobs)
            command supervisorctl status | grep init-job
            ;;
        tail)
            if [[ "$2" == "-f" && $# -eq 2 ]] || [[ $# -eq 1 ]]; then
              /usr/bin/logger
            else
              has_f=false
              for arg in "$@"; do
                  if [[ "$arg" == "-f" ]]; then
                      has_f=true
                      break
                  fi
              done

              if [ "$has_f" = false ]; then
                  command supervisorctl "$1" -f "${@:2}"
              else
                  command supervisorctl "$@"
              fi
            fi
            ;;
        *)
            command supervisorctl "$@"
            ;;
    esac
}