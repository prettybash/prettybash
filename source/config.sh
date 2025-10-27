#!/bin/bash

# Store data as a key=value pair
# Parameter $1 <STRING> | path/to/config/file
# Parameter $2 <STRING> | name of the data array (associative)
set_config()
{
  if [ -z ${1+x} ]; then
    echo "Runtime Error : Invalid argument. 'set_config <STRING> <ASSOCIATIVE_ARRAY>'" >&2
    exit 1
  fi

  # Print app details as a comment, this line also makes the config file reset and
  # if the file does not exist, it will create a new one in the provided path
  echo "# $APP_NAME - $APP_VERSION" > "$1"

  local -n array_reference="$2"

  # Write all configurations, key=value pair per line
  for key in "${!array_reference[@]}"
  do
    echo "$key=${array_reference[$key]}" >> "$1"
  done
}

# Read the data set by `set_config()`
# Parameter $1 <STRING> | path/to/config/file
# Parameter $2 <STRING> | name of the associative array for returned data
get_config()
{
  if [ -z ${1+x} ]; then
    echo "Runtime Error : Invalid argument. 'get_config <STRING> <ASSOCIATIVE_ARRAY>'" >&2
    exit 1
  fi

  local -n array_reference="$2"

  while IFS= read -r line;
  do
    # Remove leading spaces
    line="${line#"${line%%[![:space:]]*}"}"
    # Remove trailing spaces
    line="${line%"${line##*[![:space:]]}"}"
    # Skip comments
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    # Skip empty lines
    [[ -z "$line" ]] && continue
    # Parse key=value pairs
    if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      value="${BASH_REMATCH[2]}"
      array_reference["$key"]+="$value"
    fi
  done < $1
}

# Stores data as a list
# Parameter $1 <STRING> | path/to/config/file
# Parameter $2 <STRING> | name of the data array
set_config_list()
{
  if [ -z ${1+x} ]; then
    echo "Runtime Error : Invalid argument. 'set_config_list <STRING> <ARRAY>'" >&2
    exit 1
  fi

  # Print app details as a comment, this line also makes the config file reset and
  # if the file does not exist, it will create a new one in the provided path
  echo "# $APP_NAME - $APP_VERSION" > "$1"

  local -n array_reference="$2"

  # Write all configurations, one per line.
  for element in "${array_reference[@]}"
  do
    echo "$element" >> "$1"
  done
}

# Read the data set by `set_config_list()`
# Parameter $1 <STRING> | path/to/config/file
# Parameter $2 <STRING> | name of the array for returned data
get_config_list()
{
  if [ -z ${1+x} ]; then
    echo "Runtime Error : Invalid argument. 'get_config_list <STRING> <ARRAY>'" >&2
    exit 1
  fi

  local -n array_reference="$2"

  while read -r line;
  do
    # Remove leading spaces
    line="${line#"${line%%[![:space:]]*}"}"
    # Remove trailing spaces
    line="${line%"${line##*[![:space:]]}"}"
    # Skip comments
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    # Skip empty lines
    [[ -z "$line" ]] && continue
    array_reference+=("$line")
  done < $1
}
