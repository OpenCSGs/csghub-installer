#!/usr/bin/env bash

NAMESPACE="default"
RELEASE="csghub"

log() {
  local log_level="$1"
  local message="$2"
  local green="\033[0;32m"
  local yellow="\033[0;33m"
  local red="\033[0;31m"
  local reset="\033[0m"
  local color="$reset"
  local timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

  case "$log_level" in
    INFO) color=$green ;;
    WARN) color=$yellow ;;
    ERRO) color=$red ;;
  esac

  echo -e "${color}[${timestamp}] [${log_level}] ${message}${reset}"
  [[ "$log_level" = "ERRO" ]] && return 1
}

exists() {
  local item="$1"
  shift
  local array=("$@")

  for element in "${array[@]}"; do
    if [[ "$element" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

calculateChecksums() {
  local objectType="$1"
  local objectName="$2"
  local checksumType="$3"
  local checksumsVarName="$4"
  local revisions=($(kubectl -n "${NAMESPACE}" rollout history "${objectType}/${objectName}" 2>/dev/null | grep -E '^[0-9]' | tail -n 2 | awk '{print $1}'))
  local checksum

  for revision in "${revisions[@]}"; do
    checksum=$(kubectl -n "${NAMESPACE}" rollout history "${objectType}/${objectName}" --revision="${revision}" -ojsonpath="{.spec.template.metadata.annotations.checksum/${checksumType}}" | sort | base64)
    if [ -n "$checksum" ]; then
      eval "${checksumsVarName}+=(\"$checksum\")"
    fi
  done
}

restartDependencies() {
  local objectType="$1"
  local objectName="$2"
  local annotationPath="$3"
  local configType="$4"
  local restartedVarName="$5"
  local dependency

  if [ "$4" == "config" ]; then
    configType="configmap"
  fi

  local dependencies=($(kubectl -n "${NAMESPACE}" get ${configType}/"$objectName" -ojsonpath="{${annotationPath}}" 2>/dev/null))
  dependencyType=${annotationPath##*/}
  if [ "${#dependencies[@]}" -ne 0 ]; then
    for dependency in "${dependencies[@]}"; do
      if ! exists "${dependencyType}/${dependency}" "${!restartedVarName}"; then
        kubectl -n "${NAMESPACE}" rollout restart "${dependencyType}/${dependency}"
        eval "${restartedVarName}+=(\"${dependencyType}/${dependency}\")"
        log "WARN" "[${objectType}/${objectName}] dependency ${dependencyType}/${dependency} restarted."
      else
        log "WARN" "[${objectType}/${objectName}] dependency ${dependencyType}/${dependency} already restarted."
      fi
    done
  fi
}

checkAndRestartForChange() {
  local objectType="$1"
  local objectName="$2"
  local checksumType="$3"
  local annotationPath="$4"
  local resourcesRestartedName="$5"
  local checksums=()

  calculateChecksums "$objectType" "$objectName" "$checksumType" "checksums"

  if [ "${#checksums[@]}" -lt 2 ]; then
    log "INFO" "[${objectType}/${objectName}] No ${checksumType} checksums detected."
    return
  fi

  local uniqueChecksums=($(printf "%s\n" "${checksums[@]}" | sort -u))
  if [ "${#uniqueChecksums[@]}" -eq 1 ]; then
    log "INFO" "[${objectType}/${objectName}] No ${checksumType} updates detected, no dependencies restart required."
  else
    restartDependencies "$objectType" "$objectName" "$annotationPath" "$checksumType" "resourcesRestartedName"
  fi
}

main() {
  # Deployments
  local deployments=$(kubectl -n "${NAMESPACE}" get deployments -ojsonpath='{.items[*].metadata.name}')
  local exclude_deployments=("${RELEASE}-ingress-nginx-controller" "${RELEASE}-nats")
  resourcesRestarted=()

  for deploy in $deployments; do
    if [[ ${exclude_deployments[*]} =~ ${deploy} ]]; then
        log "WARN" "[deploy/$deploy] Skipping excluded deployment."
        continue
    fi
    for configType in config secret; do
      for dependencyType in deployments statefulsets; do
        checkAndRestartForChange "deployment" "$deploy" "${configType}" ".metadata.annotations.resource\\.dependencies/${dependencyType}" "resourcesRestarted"
      done
    done
  done

  # StatsfulSets
  local statefulsets=$(kubectl -n "${NAMESPACE}" get statefulsets -ojsonpath='{.items[*].metadata.name}')
  local exclude_statefulsets=("specific-statefulset-to-exclude")

  for sts in $statefulsets; do
    if [[ ${exclude_statefulsets[*]} =~ ${sts} ]]; then
      log "INFO" "Skipping excluded statefulset: $sts"
      continue
    fi
    for configType in config secret; do
      for dependencyType in deployments statefulsets; do
        checkAndRestartForChange "statefulset" "$deploy" "${configType}" ".metadata.annotations.resource\\.dependencies/${dependencyType}" "resourcesRestarted"
      done
    done
  done
}

main