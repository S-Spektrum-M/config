#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# 1. Get the remote URL for 'origin'
remote_url=$(git remote get-url origin)

# 2. Check if the URL was retrieved successfully
if [ -z "$remote_url" ]; then
    echo "Error: Could not get the remote URL for 'origin'."
    echo "Please ensure you are in a git repository with a remote named 'origin'."
    exit 1
fi

# 3. Transform the SSH URL to an HTTPS URL
#    Example Input:  git@github.com:user/repo.git
#    Example Output: https://www.github.com/user/repo
https_url=$(echo "$remote_url" | sed -e 's;git@\(.*\):\(.*\);https://www.\1/\2;' -e 's/\.git$//')

echo "Opening URL: $https_url"

# 4. Open the URL in the default browser (works on macOS, Linux, and Windows Git Bash)
case "$(uname -s)" in
   Darwin) # macOS
     open "$https_url"
     ;;
   Linux)
     # Use gio open if available, otherwise fall back to xdg-open
     if command -v gio &> /dev/null; then
        gio open "$https_url"
     else
        xdg-open "$https_url"
     fi
     ;;
   CYGWIN*|MINGW32*|MSYS*|MINGW*) # Windows (Git Bash, etc.)
     start "" "$https_url" # The empty quotes are for compatibility
     ;;
   *)
     echo "Unsupported OS: $(uname -s). Please open the URL manually."
     exit 1
     ;;
esac

exit 0

