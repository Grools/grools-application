#!/usr/bin/env bash
echo 'Name;EvidenceFor;Type;isPresent;Source;Label;Description' > "${2}"
label=""
evidenceFor=""
type="EXPERIMENTATION"
isPresent="T"
source="LABGeM"
name=""
description=""
{
  read
  while IFS=';' read -r accession desc
  do
    if [[ ${accession:-empty} != "empty" && ${desc:-empty} != "empty" ]]; then
        name=${accession}
        evidenceFor=${accession}
        label=${accession}
        description=${desc}
        echo 'Exp_'${name}';'${evidenceFor}';'${type}';'${isPresent}';'${source}';Exp_'${label}';'${description} >> "${2}"
    fi
  done
} < $1
