#!/bin/bash

# Script to extract coordinates from Google Maps shortened URLs

echo "Extracting TRUE BLACK store coordinates from Google Maps..."
echo ""

# Array of stores and their Google Maps links
declare -A stores
stores["Kompally"]="https://maps.app.goo.gl/UZovsCeFc7HGFqq7A"
stores["The Loft"]="https://maps.app.goo.gl/cPzk3ywVn2NR1LRX7"
stores["Film Nagar"]="https://maps.app.goo.gl/cLLPKwfMGc4AiLoy9"
stores["Jubilee Hills"]="https://maps.app.goo.gl/zpnvGV4xZfNunEH78"
stores["Kokapet"]="https://maps.app.goo.gl/x5AkavJ1FrTxy7yQ7"

for store in "${!stores[@]}"; do
    url="${stores[$store]}"
    echo "Processing: $store"
    echo "URL: $url"

    # Follow redirect and extract coordinates
    redirect_url=$(curl -sL -w "%{url_effective}" -o /dev/null "$url")

    # Extract coordinates from URL (format: 3d[latitude]!4d[longitude])
    if [[ $redirect_url =~ 3d([0-9.]+).*4d([0-9.]+) ]]; then
        lat="${BASH_REMATCH[1]}"
        lon="${BASH_REMATCH[2]}"
        echo "  Latitude: $lat"
        echo "  Longitude: $lon"
    else
        echo "  ⚠️  Could not extract coordinates"
    fi
    echo ""
done

echo "✅ Done! Update the migration file with these coordinates."
